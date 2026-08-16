---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-16
---

# LangGraph Store 长期记忆调研与决策建议

> 范围：为 `2026-08-16-assistant-remediation-plan.md` 的 F-9 持久记忆改造提供决策依据。资料仅采用 LangChain / LangGraph 官方文档与其维护仓库；本文不改变现有计划或代码。

## 结论

**采用 LangGraph Store 作为跨会话记忆的持久化与检索底座，但不把它称为“自动记忆”，也不再向模型注入历史原文。**

Store 只提供跨 thread 的、按 namespace 组织的 JSON 文档存取与检索；摘要、事实提取、去重、冲突处理、过期及删除都是应用层职责。官方的 `memory-template` 也是将长期记忆提取为独立的、延迟执行且会防抖的后台图，而不是由 Store 自动完成。

对 Lumos，建议采用以下组合：

1. 当前会话的短期上下文继续使用既有 LangGraph checkpointer；不把它迁入 Store。
2. 会话归档后，由后端后台任务从该会话**显式提取**一份简短摘要或有限的结构化记忆；失败时不影响会话归档与正常聊天。
3. Store 保存可解释、可查看、可删除的记忆项；新会话只按相关性/最近性取最多 5 项，作为明确标注的背景上下文注入，绝不注入原始聊天消息。
4. 用户删除会话时，删除仅由该会话产生且无其他来源的摘要/记忆项；带有多个来源的项保留其余来源。医疗事实、症状与用药事实仍以业务数据库为唯一事实源，不写入模型可自由改写的“偏好记忆”。

这保留“跨会话连续性”，同时避免当前 F-9 的原文污染和健康数据被模型摘要错误固化的问题。

## 事实核查

| 问题 | 官方事实 | 对 Lumos 的含义 |
|---|---|---|
| Store 是什么 | LangGraph 将跨会话长期记忆放在自定义 namespace 中；短期记忆则是 thread-scoped state，由 checkpointer 持久化。 | Store 不能替代现有 checkpoint，也不应把两类数据混为一层。 |
| 能做什么 | `BaseStore` 提供 `put`、`get`、`delete`、`search`、`listNamespaces`；记录是 namespace + key 下的 JSON 文档。 | 可以保存摘要、偏好和带来源的记忆项，并为会话删除实现可追踪的清理。 |
| 语义检索是否内建 | Store 支持按内容过滤；配置 embeddings 与索引字段后，`search(query)` 才以向量相似度排序。 | 语义检索是可选增强，首次实施可先按严格 namespace + 最近性/固定 key 检索；启用 embedding 前需单独确认健康文本的发送边界、模型和成本。 |
| 会不会自动压缩/总结 | 不会。官方将“何时写记忆”明确交给应用逻辑：可在主链路中写，也可用异步后台任务；长期对话压缩另需显式配置 middleware 或自建节点。 | `chatCompression` 角色可用于摘要任务，但必须定义 prompt、触发、覆盖规则和失败降级，不能仅接入 Store 就宣称解决 F-9。 |
| 官方如何做 | 官方 `memory-agent` 让模型显式调用 upsert memory；官方 `memory-template` 将记忆形成拆为后台图，并对连续消息做延迟/防抖调度。 | 应遵循 `memory-template` 的“归档后后台提取”方式，而非每一条消息都同步更新或把原文直接跨会话复制。 |

## 推荐的数据边界与生命周期

建议 namespace 体现数据主人、用途和类型，例如 `['assistant-memory', userId, 'profile']` 与 `['assistant-memory', userId, 'note']`。namespace 的具体命名可在实现时按 Lucent 已有约定收敛，关键是隔离必须以 `userId` 为边界。

### 可保存

- 用户明确或稳定表达的对话偏好，例如希望答案简短、希望先给行动步骤。
- 用户确认需要在以后继续的非医疗对话上下文。
- 每份归档会话的简短、可删除的 `conversation_summary`：会话标题、至多 5 个要点、`sourceConversationId`、创建/更新时间。

### 不应保存为 Store 长期记忆

- 症状、诊断、用药、检查结果、过敏史以及任何以主业务库为准的健康事实。
- 未经用户确认而由模型推测出的稳定偏好或健康结论。
- 原始消息全文。

健康事实必须继续通过既有的、权限受控的业务工具读取；否则 Store 的 patch/upsert 语义会让模型的错误摘要变成跨会话“事实”。

### 写入、检索、删除规则

- **写入触发**：会话归档后启动后台摘要/提取任务；连续归档或继续会话时对同一会话去重。不要让该任务阻塞 SSE 回复。
- **写入形态**：将同一会话的摘要按 `sourceConversationId` 幂等 upsert；结构化偏好必须有 schema、来源和更新时间，不能保存自由散文。
- **检索形态**：新会话开场时只取最多 5 条与当前请求相关或最近的记忆；以系统背景说明或专用 context 字段注入，不能伪装成当前用户消息。
- **删除形态**：删除会话时，以 `sourceConversationId` 清除仅来自该会话的摘要；多来源记忆只移除该来源，来源归零才删除。另提供独立的“清除长期记忆”操作，不能把删一个聊天记录误解为必然清空所有记忆。

## 取舍

| 方案 | 判断 |
|---|---|
| 继续注入最近原文 | 不采用：上下文污染、token 成本和历史健康内容暴露均未被控制。 |
| 每个会话只存一段自由文本摘要 | 可作为过渡，但不足：难以去重、删除和按相关性取用。至少应保存来源、类型、时间与受限要点。 |
| Store + 受限 profile/notes + 后台提取 | 采用：与 LangGraph 官方模板的职责拆分一致，且可对记忆实施删除、审计与质量控制。 |
| 将业务健康事实写入 Store | 不采用：会产生两套事实源，且允许模型改写健康记录。 |

## 与当前仓库的可行性

Lucent 当前锁定 `@langchain/langgraph` 1.4.2、`@langchain/langgraph-checkpoint` 1.1.1 与 `@langchain/langgraph-checkpoint-postgres` 1.0.4；已安装的 Postgres checkpoint 包导出了 `PostgresStore`。因此 Store 接入不要求为 F-9 引入新的生产依赖。现有 `chatCompression` 模型角色可服务于后台摘要，但这不改变“摘要生命周期必须由应用自行实现”的结论。

## 官方来源

- [LangGraph Memory overview（短期/长期记忆边界、profile/collection、写入时机）](https://docs.langchain.com/oss/javascript/langgraph/memory)
- [LangGraph Stores（namespace、CRUD、检索和 embedding 索引）](https://docs.langchain.com/oss/javascript/langgraph/stores)
- [LangGraph Add and manage memory（短期历史压缩需显式 middleware/逻辑）](https://docs.langchain.com/oss/javascript/langgraph/add-memory)
- [官方 `BaseStore` TypeScript 源码（实际 CRUD、search、index 合同）](https://github.com/langchain-ai/langgraphjs/blob/main/libs/checkpoint/src/store/base.ts)
- [官方 `memory-agent`（模型显式 upsert 记忆）](https://github.com/langchain-ai/memory-agent/blob/main/src/memory_agent/graph.py)
- [官方 `memory-template` 的聊天图（检索与延迟记忆形成）](https://github.com/langchain-ai/memory-template/blob/main/src/chatbot/graph.py)
- [官方 `memory-template` 的后台记忆图](https://github.com/langchain-ai/memory-template/blob/main/src/memory_graph/graph.py)
