---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-16
---

# LangGraph Time Travel 与助手重新生成调研

> 范围：为助手的“重新生成 / 重新发送”决策提供依据。仅使用 LangChain / LangGraph 官方文档；本文不改动计划或运行时代码。

## 决策结论

**采用 LangGraph Time Travel 实现显式的“重新生成”，但不能把它当作 SSE 断流的自动重试或“继续生成”。**

Time Travel 是有 checkpoint 的图从历史状态进行 replay 或 fork 的正式机制，适合用户明确请求“从此处重新回答、接受答案可能不同”的场景。它不会把外部副作用回滚，也不会自动去重；checkpoint 后的 LLM、API 请求和 interrupt 都会再次执行。因此应把它设计为受控分支能力，而不是为当前流式请求增加一个隐形重放。

对于 Lumos 的医疗助手，推荐合同如下：

1. **重新生成**：第一版仅针对当前会话的最后一条、已持久化的助手消息。服务器从该回答进入 `respond` 节点前的 checkpoint 重放；原回答保留为 revision，新回答以 `replacesMessageId` 关联并成为当前可见版本。此时复用同一 `thread_id`，因为 LangGraph 的 fork 是同 thread 内的新 checkpoint branch，并不自动复制到新 thread。客户端必须明确标注这是一次新生成，不能伪造为原回答。
2. **继续生成**：保持为断流后的用户显式操作，不使用 Time Travel。若现有一次图执行已结束或没有可继续的 stream，服务端以正常新请求生成；绝不承诺它是原输出的字节级续写。
3. **安全边界**：fork 后可重新运行的节点只允许纯计算、LLM 与只读工具；所有数据库写入、消息落库、通知等副作用必须放在受控的、带稳定请求/动作 ID 的幂等应用层操作中。写提案仍先 interrupt 审核，确认后的实际健康数据写入使用独立原子确认接口，不能依赖 replay 达成去重。

这接受“Time Travel 更正规”的判断，但前提是先补齐 checkpoint ↔ 持久消息映射与分支会话模型；以当前代码直接重放会混淆图状态和 Prisma 会话历史。

## 官方机制与必要前提

| 项目 | 官方事实 | Lumos 需要满足的条件 |
|---|---|---|
| 持久化 | Checkpointer 将单个 thread 的图状态保存为 checkpoints；Time Travel 依赖它。 | 使用生产级 `PostgresSaver`，不得在 saver 不可用时降级执行“重新生成”。 |
| 定位 | `thread_id` 是 checkpoint 状态的持久指针；snapshot config 包含 `thread_id`、`checkpoint_ns`、`checkpoint_id`。`getStateHistory()` 用于定位旧 checkpoint。 | 将受控的 `threadId`、`checkpointNs`、`checkpointId` 与生成的 `AssistantMessage.id` 原子地记录，且先验证 `conversationId` / message 属于调用用户。 |
| Replay | 向 `invoke` 传入旧 checkpoint config 后，checkpoint 之前的节点不再执行，之后的 LLM、API、interrupt 会重新执行。 | “重新生成”必须接受结果可能不同；不能用于自动补发，不能把 replay 当作恢复已经中断的字节流。 |
| Fork | 对旧 checkpoint `updateState()` 后会创建一个新 branch checkpoint；再以该 config `invoke(null, ...)` 继续。原历史不被回滚或改写。 | 第一版在同一 `thread_id` 内保留原回答 revision，只允许重生最后回答。任意历史消息的重生需要另行设计产品分支与 checkpoint 的跨 thread 归属，不能假定 `updateState` 会创建新的 `thread_id`。 |
| Interrupt | Time Travel 经过 interrupt 时会再次触发；resume 也会从含 interrupt 的节点开头重跑。 | 确认/拒绝不能在 fork 中继承为已经发生的业务写入；若重新到审核点，必须显式再确认。 |

## 当前 Lucent 适配性核查

已经具备的基础：

- 依赖已锁定 `@langchain/langgraph` `1.4.2`、`@langchain/langgraph-checkpoint` `1.1.1` 和 `@langchain/langgraph-checkpoint-postgres` `1.0.4`（`Lucent/package.json`）。
- `AssistantCheckpointerService` 已初始化 `PostgresSaver`；运行时以 `conversationId` 作为 `configurable.thread_id`，并用 `getState` + `Command({ resume })` 驱动现有提案审核（`Lucent/src/modules/assistant/agent/checkpointer.service.ts`、`runtime.service.ts`）。

当前尚不满足 Time Travel 的产品合同：

- 没有保存 `checkpoint_id` / `checkpoint_ns`，也没有 `AssistantMessage` 与“生成前 checkpoint”的映射，所以不能可靠定位某一条回答应该从哪里 fork。
- 运行时没有 `getStateHistory`、`updateState` 或 replay/fork 路径；公开 API 也没有 message 级重新生成合同。
- `AssistantConversation` 的 Prisma 消息持久化与 LangGraph checkpoint 分离；当前写入通过 `persistAssistantTurn()` 查找最新 active conversation，而非将一次图执行明确绑定到输入的 `conversationId`。在此基础上重放会造成会话/图状态归属不清。
- 图包含 read、knowledge 与 write-proposal 子图。官方明确说明 checkpoint 之后的 API 请求与 interrupt 均会再执行；健康数据写入和通知不能因重放产生重复。

## 推荐最小服务端合同

仅在上述映射与分支模型落地后开放：

```ts
POST /api/v1/user/assistant/conversations/:conversationId/messages/:messageId/regenerate

// 语义（非最终 DTO）
{
  idempotencyKey: string; // 客户端生成，防止双击/网络重试创建两个分支
}

// 返回 SSE 的最终 result
{
  conversationId: string;       // 原会话；图 fork 仍在同一 thread_id
  regeneratedFromMessageId: string;
  replacesMessageId: string;    // 新 revision 关联旧回答，旧回答保持可审计
  role: 'assistant';
  content: string;
  generatedAt: string;
}
```

执行顺序：授权并锁定原消息 → 验证它是当前会话最后一条已完成 assistant 消息 → 读取该回答进入 `respond` 前的 checkpoint config → 用该 config `invoke(null, ...)` replay（不重跑此前的工具节点）→ 将新 revision、`replacesMessageId` 与本次 checkpoint 映射在应用层持久化。需要编辑 graph state 才使用 `updateState` 创建 fork；对同一 `(userId, messageId, idempotencyKey)` 必须幂等返回同一 revision。

第一版只允许重新生成**最新一条已完成的 assistant 消息**。对任意历史消息重生会使其后的用户/助手消息失去线性因果关系，必须先定义产品分支浏览、切换与归档规则，以及分支如何取得独立 `thread_id` 后再开放。

## 副作用规则

官方对 interrupt 的要求同样适用于本方案：含 interrupt 的节点会从头执行，interrupt 之前的副作用必须幂等；推荐将副作用移到 interrupt 后或拆到单独节点。Time Travel 还会重新执行 checkpoint 之后的 API 请求与 interrupts。

因此：

- 读取健康档案、药品知识、RAG 检索可重跑，但要记录其结果来源与生成时间，不将旧结果伪称为当前事实。
- 受控提案只生成草稿；重复草稿需有 generation/action identity，不得自动写入健康记录。
- 已确认的业务写入只能由原子、幂等的服务端确认端点执行；该端点不是图 replay 节点的隐式副作用。
- SSE 连接断开不触发 time travel。客户端保留已有文本并提供“继续生成”；最终持久化仍以收到完整 `result` 事件为准。

## 官方来源

- [Use time-travel（replay / fork、checkpoint 后节点重跑、`getStateHistory` 与 `updateState`）](https://docs.langchain.com/oss/javascript/langgraph/use-time-travel)
- [Use checkpointers（thread、snapshot config 中的 `thread_id` / `checkpoint_ns` / `checkpoint_id`）](https://docs.langchain.com/oss/javascript/langgraph/checkpointers)
- [Interrupts（持久化与同一 `thread_id` 恢复）](https://docs.langchain.com/oss/javascript/langgraph/interrupts)
- [Interrupts：interrupt 前副作用必须幂等](https://docs.langchain.com/oss/javascript/langgraph/interrupts#side-effects-called-before-interrupt-must-be-idempotent)
