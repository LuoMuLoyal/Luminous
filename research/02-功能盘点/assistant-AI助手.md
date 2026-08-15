---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-15
---

# AI 助手模块（assistant）功能盘点与真伪审计

> 范围：客户端 `Luminous/lib/features/assistant/`（presentation/application/data/domain）、
> `Luminous/lib/core/ai/`（app-side AI runtime seam，默认关闭）；
> 后端 `Lucent/src/modules/assistant/`（controller/agent 运行时/tools/services）、
> `Lucent/src/llm-runtime/`（模型工厂）；
> 参考：`Luminous/docs/01-product/Product_Vision.md`、`docs/00-current/Mock_Or_Deferred.md`、
> `docs/00-current/TODO.md`、`Lucent/docs/openapi.json`、`Lucent/plans/`、`Luminous/plans/`。
>
> **审计基准声明**：按审计规则，`Luminous/plans/` 与 `Lucent/plans/` 下所有计划**视为已执行完毕**，
> 按设计意图评估。因此 F-2 会话重命名/删除、F-4 Markdown 视觉模板、F-5b 重新生成/重新发送三项
> 以计划设计意图为评估对象（其设计在计划中已明确，当前仓库中对应代码位仍为占位实现，见各条目注）。
> 其余条目全部以仓库实际代码为准抽样验证。
>
> 专有名词保留英文；真伪判定采用四档：真实现 / 部分实现 / 假实现 / 死代码。

## 一、功能点总览

| 编号 | 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|---|
| F-1 | 会话管理（新建/加载/切换/抽屉分组/搜索/高亮） | 新建归档旧会话、恢复最新、切换历史、抽屉分组搜索 | 真实现 | 保留 | P0 |
| F-2 | 会话重命名与删除 | 侧边栏右键/长按重命名、删除，删除二次确认 | 真实现（按计划设计意图评估；仓库仍为占位） | 改造 | P1 |
| F-3 | SSE 流式对话 | 真实 SSE 连接后端、增量渲染、断流/空结果/服务端错误分类处理与重试 | 真实现 | 保留 | P0 |
| F-4 | Markdown 消息渲染与视觉模板 | MarkdownBody 渲染 + 统一样式工厂；标题/列表/代码块/表格视觉模板 | 真实现（按计划设计意图评估；模板升级项仓库仍为基础样式） | 改造 | P2 |
| F-5 | 消息操作（复制/重新生成/重新发送） | 复制真实可用；重新生成/重新发送恢复会话续答 | 部分实现（复制真实现；重生成两项按计划设计意图评估） | 改造 | P1 |
| F-6 | 工具调用执行层（22 个工具） | LangGraph agent↔tools 循环，LLM 决策、后端真实执行 | 真实现 | 保留 | P0 |
| F-7 | 工具调用展示（参考来源） | 在消息中展示本条回答用到的工具与来源 | 死代码（数据已传但前端不渲染，l10n 键闲置） | 改造 | P0 |
| F-8 | 上下文选择（档案/记录/睡眠/用药） | 4 源开关经后端策略过滤工具可见性与执行权限 | 真实现 | 保留 | P0 |
| F-9 | 持久记忆 | 新会话注入过往会话摘要块，跨会话连续性 | 真实现（原始文本直灌，无摘要压缩） | 改造 | P1 |
| F-10 | capabilities 开关 | 后端能力+设置合成策略，真实门控输入/工具/状态 | 真实现 | 保留 | P0 |
| F-11 | GenUI / proposedActions（HITL 提案） | 4 类提案卡片，确认/拒绝走后端 interrupt/resume，客户端执行写入 | 真实现 | 保留 | P0 |
| F-12 | GenUI 开放式渲染引擎 | 开放式组件 JSON schema + GenUIRenderer 递归渲染 | 未启动（Feature flag 默认关，无任何代码） | 冻结保留，不推进 | — |
| F-13 | AI 回答免责与安全边界 | 系统提示限界 + 知识检索信封携带 disclaimer | 部分实现（仅后端 prompt 约束，客户端零免责呈现） | 改造 | P0 |
| F-14 | 与 Today/Report 摘要联动 | 读取 historical_ai_summary 表中 Today/Report 历史 AI 摘要 | 真实现 | 保留 | P0 |
| F-15 | 药品知识检索（说明书/DrugBank/医疗问答） | 三个 PGVector 语义检索工具 + 结构化药品库搜索 | 真实现（医疗问答语料质量与免责需管控） | 保留（方向修正） | P1 |
| F-16 | 提案式写入（建/改/删记录、改设置） | 后端生成提案草稿、客户端确认后经真实 record API 写入 | 真实现（写入在客户端执行，架构分叉） | 改造 | P1 |
| F-17 | 助手状态栏/控制面板 sheet | 折叠状态栏与设置抽屉 | 死代码（3 个文件无引用，入口已迁 Settings） | 归档（保留不接入 shipping） | P2 |
| F-18 | lib/core/ai/ app-side runtime seam | 实验性 app-side AI runtime 配置 seam | 死代码/实验 seam（默认关，无消费方，未接入 shipping） | 保留（标记实验） | P2 |

真伪分布：真实现 10 项（F-1/3/6/8/9/10/11/14/15/16），部分实现 2 项（F-5/13），
死代码/未启动 5 项（F-7/12/17/18，F-2 与 F-4 按计划评估为已实现但仓库为占位）。

## 二、逐功能分析

### F-1 会话管理（新建/加载/切换/抽屉）

- 现状：`AssistantController`（`presentation/providers/conversation.dart`）提供 `loadLatestConversation`（GET latest）、`loadRecentConversations`（GET conversations）、`openConversation`（POST open）、`clearConversation`（POST latest/clear 归档当前会话后清空本地态）。抽屉 `conversation_drawer_list.dart` 按今天/近 7 天/更早三组分组、支持搜索过滤、当前会话打勾+标记、打开中禁用点击、骨架/错误/空态齐全。页面侧开抽屉为移动端不透明抽屉、桌面 320px。
- 实际作用：完整支撑"多会话持久化 + 快速切换"的聊天产品形态；新建会话=归档旧会话而非删除，历史可回。
- 真伪判定：真实现。前后端接口一一对应（openapi.json 含 capabilities/latest/conversations/open/clear/confirm/stream 共 7 个端点），抽屉状态订阅做了 select 优化避免流式 chunk 重建（`page.dart` 的 `AssistantDrawerState` 投影）。
- 结论：保留。
- 改造方案：
  - P0：无（核心链路健康）。
  - P1：抽屉"当前会话"行区分「归档中」视觉反馈（clear 为异步，未加 loading 态）；会话标题为空时提供"点击补名"入口，与 F-2 共用。

### F-2 会话重命名与删除

- 现状（按计划设计意图评估）：`2026-08-01-ai-chat-redesign-plan.md` 阶段 3 定义：后端新增 `PATCH /assistant/conversations/:id`（仅 title）与 `DELETE /assistant/conversations/:id`（软删除，`AssistantConversationStatus` 增加 `deleted`，列表默认过滤）；前端新增 `renameConversation`/`deleteConversation`，侧边栏长按/右键菜单重命名+删除，重命名本地先更新异步同步、失败回滚 toast，删除二次确认；"新对话"移至抽屉顶部。
- 注：当前仓库中该功能仍为占位——后端 openapi.json 无 PATCH/DELETE 端点（`assistant.controller.ts` 仅 7 个端点），抽屉列表 `conversation_drawer_list.dart` 无重命名/删除菜单；按审计规则以计划设计意图评估。
- 实际作用（设计意图）：解决历史会话堆积无法清理、标题全是"未命名/首条消息截断"的辨识问题，是会话长期使用的必备能力。
- 真伪判定：真实现（按计划设计意图评估）。
- 结论：改造（设计本身合理，落地时需补两个细节）。
- 改造方案：
  - P1：后端补 PATCH/DELETE 端点（软删除 + 列表过滤 `deleted`，会话表已存在，方案已在计划中明确）；前端补菜单并接 `conversation.dart` 两个新方法，复用 `runGuarded` 失败 toast。
  - P1：删除当前活跃会话后状态处理要闭环：`conversationId` 置空 + 本地清空 + 刷新列表；若删除的是最新会话，应回退到 `loadLatestConversation` 兜底而非白屏。
  - P2：标题自动生成改由后端 LLM 摘要（首条消息截断 `truncate(compact, MAX_COMPACT_LENGTH)` 常得到半截话），重命名 UI 才真正少用。

### F-3 SSE 流式对话

- 现状：前端 `LucentSseClient`（`core/network/sse.dart`）POST `/assistant/messages/stream`，解析 `chunk/result/error/done` 四类事件；`AssistantRemoteDataSource.streamMessages` 将 chunk 逐段 yield，`AssistantController` 累加到 `streamingDraft` 实时渲染（带三点动画），`result` 事件落成正式消息并刷新会话列表；SSE 请求覆盖 `receiveTimeout: Duration.zero`，默认关闭 reconnect（`reconnect: false`）。后端 `assistant.controller.ts` 用 `prepareSse/writeSseEvent/endSse` 转发 LangGraph 流式文本（`streamModelResponse` 逐 chunk 调 `onChunk`），错误分类为 `error` 事件；`onText` 回调只吞传输层错误（ECONNRESET/EPIPE 等），业务错误上抛。
- 实际作用：真实端到端流式：LLM 增量 → SSE → 前端逐字渲染，用户感知为打字机效果；断流不白屏。
- 真伪判定：真实现。失败处理完整：`AssistantSendErrorType`（server/streamInterrupted/emptyResult/unknown）→ 错误条 + `retryLastMessage`（`conversation_stack.dart` 在 `lastFailedInput != null` 时接 onRetry，重发时去重已追加的用户消息）。
- 结论：保留。
- 改造方案：
  - P1：`reconnect: false` 意味着断网重连后无补偿——建议开启有限重连（`maxReconnects: 2`），或断流时提示"继续生成"按钮复用 `retryLastMessage`（当前提示后只能整体重发）。
  - P1：流式中断时 `streamingDraft` 保留半句的体验：现在 catch 分支把 `streamingDraft` 清空，用户看到消息消失只剩错误条，建议保留残句作为失败消息内容供复制。

### F-4 Markdown 消息渲染与视觉模板

- 现状（按计划设计意图评估）：消息用 `MarkdownBody` + `MarkdownStyle.ai`（`message_bubble.dart:92-99`，`selectable: true`）；`f9e60d33 refactor(markdown)` 已建统一样式工厂覆盖 6 处渲染点；计划目标为统一设计标题、列表、代码块、引用、表格、链接的视觉模板（`TODO.md` "AI 消息 Markdown 模板升级"）。
- 注：仓库当前仍为基础 `MarkdownBody` 样式；按审计规则以计划设计意图评估。
- 实际作用（设计意图）：健康类回答常含列表（症状/用药核对）、表格（剂量对照）、引用（说明书原文），模板统一后视觉层级与可读性提升，也是与 Report/Today 摘要风格一致性的基础。
- 真伪判定：真实现（按计划设计意图评估）。
- 结论：改造。
- 改造方案：
  - P2：在现有 `MarkdownStyle.ai` 工厂上扩展标题字号阶梯/列表缩进/表格边框/引用块左侧色条；注意移动端窄屏表格横向滚动与代码块折行。
  - P2：为 AI 回答的 Markdown 输出追加客户端契约校验（如表格列数、链接域白名单），防 LLM 注入异常结构；链接默认不自动跳转（先弹确认）防钓鱼。

### F-5 消息操作（复制/重新生成/重新发送）

- 现状：长按/右键 `FContextMenu.tiles`（`message_bubble.dart:147-172`）：复制真实可用（`Clipboard.setData` + toast，用户消息 `SelectableText` 另可选中复制）；"重新生成"（助手消息）与"重新发送"（用户消息）在仓库中为 `onPress: null` 禁用项（`// TODO: wire regenerate / resend once the controller supports it`）。
- 实际作用：复制解决"引用/转存"刚需；重新生成/重新发送解决"AI 答偏了"与"发送失败重发"场景。
- 真伪判定：部分实现——复制为真实现；重新生成/重新发送按计划设计意图评估（计划未单独成文，TODO.md 记为"需后端 controller 支持后接线（Lucent assistant 尚无 regenerate/resend 接口）"），设计意图=调 `_sendMessageInternal(appendUserMessage:false)` 复用现有流式管线并持久化新轮次。
- 结论：改造。
- 改造方案：
  - P1：后端 assistant 模块补 `regenerate`/`resend` 端点（重放会话上下文：按 conversationId+messageId 回滚到该轮再流式），前端接线菜单项；最低成本方案是前端接 `retryLastMessage` 同款路径（复用现有 `streamMessages`，后端 `persistAssistantTurn` 的 `findAppendStartIndex` 已具备去重追加能力），仅需 10 行内接线。
  - P2：重新生成后旧回答保留为灰色"已替换"态（聊天软件通用交互），避免上下文跳变。

### F-6 工具调用执行层（22 个工具）

- 现状：`ASSISTANT_TOOL_NAMES` 22 个工具全部标记 implemented（`tool-types.ts`）；`AssistantToolService.executeMany` 逐一执行，知识类 7 工具（药品/说明书/DrugBank/医疗问答）带 1 小时查询缓存（按 locale+query hash）。执行链路：LangGraph `agent` 节点 `model.bindTools(defs)` → LLM 返回 tool_calls → `tools` 节点执行并追加 `ToolMessage` → 循环（`MAX_TOOL_LOOPS` 封顶）→ `respond`。意图分类（read/write/knowledge/simple_chat/mixed）走确定性关键词路由（`classify.ts`/`tool-keyword-rules.ts`，带节点级缓存），各意图进专属子图（`subgraphs/read.ts`/`write.ts`/`knowledge.ts`）。
- 抽样验证（非前端拼装）：`read.service.ts` 直接查 Prisma 用户真实数据（daily_record/health profile/current_medicine/medicine_reminder/historical_ai_summary）；`medicine/lookup.service.ts` 调真实 `CnMedicinesService`/`DrugbankMedicinesService`；`leaflet/read.service.ts` 与 `knowledge/medical.service.ts` 走真实 PGVector 语义检索；`drugbank/` 两个服务走真实向量库与实体解析。全部带 coverage/confidence/ambiguities 信封（`presenters.ts`），空结果/歧义显式标注。
- 实际作用：这是"AI 读你的数据、查真实药典"的核心真实性来源——LLM 只做决策，事实由服务端工具提供，幻觉面被约束在"表述层"。
- 真伪判定：真实现。可复现证据链：工具定义（`tool-definitions.ts`）→ 执行（`tool.service.ts`）→ 结果信封 → 注入 ToolMessage → 回答。
- 结论：保留。
- 改造方案：
  - P1：`MAX_TOOL_LOOPS` 后若仍挂起 tool_calls，`respond` 会拿"无 finalContent"兜底再生成——建议在兜底 prompt 中显式告知"工具轮次已耗尽"避免答非所问。
  - P2：工具执行时间上限（单工具超时）缺失，`executeMany` 串行执行 22 个全挂时可能拖垮流；建议 per-tool timeout + 并行化读类工具。

### F-7 工具调用展示（参考来源）

- 现状：后端 `result` 事件返回 `usedTools`，前端实体 `AssistantMessage.usedTools` 解析保存；l10n 键 `assistantUsedToolsLabel`（"参考来源"）与 `localizeToolName`（22 个工具的中文映射）齐全，但 **UI 无任何一处渲染 usedTools**（`message_bubble.dart` 不展示；`assistantUsedToolsLabel`/`localizeToolName` 除定义外零引用）。
- 实际作用（现状）：数据链路通到 UI 门口即断——用户完全看不到"这条回答用了哪些来源"。
- 真伪判定：死代码（半截链路）。工具能力清单 `capabilities.tools`（含 enabled/disabledReason）同样只进 status bar 的简化文案，不展示明细。
- 结论：改造（这是医疗产品可信度的关键缺口——用户无法核对 AI 依据）。
- 改造方案：
  - P0：助手消息底部渲染来源条：`参考来源：今日记录 · 药品说明书（布洛芬缓释胶囊）· 医疗问答`，工具名用 `localizeToolName`，点击展开该轮工具结果信封（coverage/confidence/ambiguities 只读视图）。
  - P1：知识类回答（F-15）来源条附加来源类型徽标（说明书=较高可信 / DrugBank=科学依据 / 医疗问答=低可信教育参考），与后端 prompt 中三级信任分层一致。

### F-8 上下文选择（健康档案/近期记录/睡眠/当前用药）

- 现状：Settings → AI 页 4 个开关（`settings/presentation/pages/ai.dart`，防连点竞态 `_isPatching` + 点击时最新快照）→ `user_settings` PATCH → 后端 `policy.service.evaluate` 按 `ASSISTANT_TOOL_SOURCE_MAP` 过滤出 `enabledContextSources` → 只允许对应工具（如关睡眠则 `get_sleep_summary_by_range` 不可用，`canReadSleep` 双保险）→ capabilities 透传回客户端展示开关态。
- 实际作用：用户级隐私授权真正生效——关掉的源在工具层不可见，LLM 拿不到数据（非仅 UI 隐藏）；聊天中也可通过 `propose_update_user_settings` 提案改上下文。
- 真伪判定：真实现。`selectAllowedToolsForContextSources`（`router.ts`）按源映射表过滤 + `policy.executableToolNames` 二次过滤 + 服务端 `streamMessages` 只用 policy 结果注入工具上下文。
- 结论：保留。
- 改造方案：
  - P1：开关关闭后历史消息里已展示过的旧数据仍留在会话记录中（信息不回退）——建议开关变更时 toast 提示"下次对话生效"，并考虑在设置页展示当前会话受影响的说明。
  - P2：4 个源粒度对齐产品叙事：目前"健康档案"只有档案+昵称+过敏，建议在设置页副标题写明各源实际包含字段，避免用户误判授权范围。

### F-9 持久记忆

- 现状：`assistantMemoryEnabled` 开启后，`prepare_context` 在新会话（`isNewConversation`，用户消息 ≤1 条）时调用 `conversation.service.buildMemoryBlock`：取最近 3 个会话各若干条消息（`MEMORY_CONVERSATION_LIMIT`/`MEMORY_MESSAGE_LIMIT`），以原始文本注入为 `HumanMessage`，并附"仅作连续性提示、冲突时以新会话为准"的指令。
- 实际作用：跨会话"上次聊过什么"的连续性真实生效（注入发生在服务端图内，非前端拼装）。
- 真伪判定：真实现。
- 结论：改造（原始直灌有两个隐患：隐私面与上下文污染）。
- 改造方案：
  - P1：改摘要压缩——记忆块不灌原文，改为"会话标题 + 要点摘要"（后端用 `chatCompression` role 已有配置位），减少 token 污染与隐私面；当前把整段历史当 HumanMessage 会让 LLM 误把旧话题当当前诉求。
  - P1：记忆注入失败/为空时静默降级（现状为空串即跳过，OK），但建议记忆启用时在欢迎区显示"已开启跨会话记忆"，让用户知道自己的数据被用于延续对话。
  - P2：提供"记忆擦除"入口（清空历史会话即等效），与 F-2 删除联动。

### F-10 capabilities 开关

- 现状：`getCapabilities` 合成 foundation（模型配置/rag/工具实现度）+ 用户设置 + policy，返回 `assistantEnabled/chatModelConfigured/interactiveChatReady/streamingSupported/tools[]/...`；客户端 `canSendMessages`（四条件与）门控输入框与发送；`status_bar` 展示"已准备好/准备中/已关闭/模型缺失"四态；后端 `streamMessages` 二次校验（`!settings.assistantEnabled → 403`，模型未配置 → 503）。
- 实际作用：开关真实影响行为——关闭助手后输入框禁用+提示、发送被服务端拒绝、工具全 disabled（`chat_disabled` 原因），不存在"本地开关无执行器"的假模式。
- 真伪判定：真实现（服务端策略 + 客户端门控双重生效）。
- 结论：保留。
- 改造方案：
  - P2：`capabilities.tools` 明细（22 项 enabled/disabledReason）已下发但客户端只显示状态摘要——建议与 F-7 来源条合并做"能力详情"面板，把 disabledReason 翻译成用户话术。

### F-11 GenUI / proposedActions（HITL 提案）

- 现状：后端 4 个 `propose_*` 工具（create/update/delete daily_record、update_user_settings）由规则草稿提取器（`proposal-draft-extractor.ts`，含否定词处理、白名单字段）生成带约束/预览/过期时间/快照的提案（`proposal.service.ts`）；有 checkpointer（Postgres `PostgresSaver`）且会话持久化时，图在 `write_review` 节点 `interrupt` 挂起（`review.ts`），客户端 `confirmProposals`（POST confirm，校验 pending+未过期）恢复线程；客户端确认后 `ProposalExecutionOrchestrator` 经真实 record repository 写入，再回读后端最终回复（`conversation.dart:378-437`）；驳回走 `rejected` 同样恢复线程。前端 `AssistantProposalCard` 渲染标题/摘要/理由/预览字段/状态（pending→executing→confirmed/dismissed/failed）+ 过期校验。
- 实际作用：把"AI 替你记一笔"做成必须人工确认的提案卡片——写路径永不自动执行，符合"AI 不做无确认写入"的产品安全原则；确认/驳回两端都有后端图状态机兜底，回复不谎称已写入（`review.ts` 指令："do not claim it was applied automatically"）。
- 真伪判定：真实现。抽样确认：提案生成（服务端）→ 客户端确认（真实 record API 调用，非前端拼装）→ 图恢复（真实 interrupt/resume）。
- 结论：保留（这是本模块差异化价值最高的部分）。
- 改造方案：
  - P1：写入在**客户端**执行、后端只负责"批准"（`review.ts` 注释明言 "the client still applies the real write"）——若客户端写入失败，后端线程已按 approved 收尾，出现"已确认但未写入"的裂缝。建议二选一：a) 后端 `confirm` 端点改为真实写入（服务端原子化）；b) 客户端失败时反向调用一个 `reject` 补偿接口把线程置为失败态。P1。
  - P1：提案过期后卡片应显示"已过期，请重新生成"并可一键重触发，现状 `isExpired` 仅抛错 toast。
  - P2：提案 `expiresAt` 目前取最早过期时间，过期即整批失效，建议按单条计算。

### F-12 GenUI 开放式渲染引擎

- 现状：`TODO.md` 明确 GenUI 目标（开放式组件 JSON schema + `GenUIRenderer` 递归渲染原生 Widget，Phase 2 在 `proposedActions` 增 `type:"gen_ui"`），前置为稳定版发布后启动；`runtime_config.dart` 的 `genUiEnabled` flag 默认 false；代码库中**无任何 GenUIRenderer/组件 schema 实现**。
- 实际作用：无（纯规划项，flag 只是环境变量占位）。
- 真伪判定：死代码/未启动（不是被错误启用的路径，也不是雏形——雏形即 F-11 的 proposedActions，已独立成立）。
- 结论：冻结保留。当前不删除占位和方向，也不进入近期路线图；现有固定提案卡继续承担受控写入。是否启动开放式组件树，等待独立证明用户任务、注入边界、可访问性和审计成本。
- 改造方案：
  - 当前不安排实现工作；保留 `genUiEnabled` 默认关闭，禁止把它包装成已提供能力。若将来解冻，优先从受控提案卡类型扩展开始，不直接开放任意组件树。

### F-13 AI 回答免责与安全边界

- 现状：后端侧真实且较强——系统提示（`system.prompt.ts`）五条基础安全线（不诊断/不改药方/只依据工具与用户记录/不确定明说/覆盖不足直说）、知识类子图强制"证据来源分离、检索缺失不编造"、工具信封携带 `disclaimer`（`assistant.medical_knowledge_disclaimer` i18n）、135 万 QA 导入脚本带 BLOCKED/CAUTION 关键词安全过滤、LLM 熔断+重试+超时。
- 但**客户端侧为零**：欢迎面板、消息气泡、输入区、设置页均无任何免责声明/安全提示（grep "免责/disclaimer/consult/医生" 在 assistant 前端零命中）；"参考来源"不展示（F-7），用户无从判断"这是说明书依据还是低可信问答依据"。
- 实际作用：后端尽力约束模型输出，但用户侧无任何显式边界告知——回答中"这是建议不是诊断""请咨询医生"是否出现完全取决于模型自觉。
- 真伪判定：部分实现（服务端 prompt 层真实现，客户端呈现层缺失，且 simple_chat 快路径无工具约束、无免责强制）。
- 结论：改造（医疗产品的合规与信任底线，P0）。
- 改造方案：
  - P0：欢迎面板与每条助手消息底部固定免责条："AI 回答仅供健康参考，不构成医疗诊断或用药建议；用药调整请咨询医生/药师。"（首次会话展开，之后折叠为小字）。
  - P0：知识类回答（F-15 三类来源）按来源信任级别强制附加来源标签与"低可信教育参考"提示——后端已在信封带 disclaimer，客户端需渲染而非丢弃。
  - P1：`simple_chat` 快路径强制插入一行服务端免责尾注（或客户端统一追加），避免"模型没自觉"时零边界。
  - P1：设置页"AI 隐私"区补充数据使用说明（记忆/上下文开关实际发送给 LLM 的内容范围）。

### F-14 与 Today/Report 摘要联动

- 现状：`get_today_summary_by_date`/`get_report_summary_by_range`/`get_recent_today_summaries`/`get_recent_report_summaries` 读 `historical_ai_summary` 表（`summary.repository.ts`），该表由 Today 分析与 Report 的 AI 摘要服务写入（`today-analysis/services/analysis.service.ts`、`reports/services/ai-summary/summary.service.ts` 均引用 AiSummaryHistory）。
- 实际作用：助手能引用产品核心资产（Today 主动建议摘要与 Report 回顾摘要），回答"我上周怎么样"时基于产品既有 AI 摘要而非重新自由发挥；系统提示明确"Historical AI summaries 指 Today/Report 摘要，不要与旧聊天混淆"。
- 真伪判定：真实现（跨模块真实数据读写）。
- 结论：保留。
- 改造方案：
  - P2：摘要工具返回 `confidenceNote`/`sourceVersion` 但前端信封不展示——随 F-7 来源条一并呈现"数据截至 X 日"。

### F-15 药品知识检索（说明书/DrugBank/医疗问答）

- 现状：`search_medicine_leaflets`（说明书分块向量检索，先按向量聚合解析产品再过滤 chunk，歧义阈值 0.05）、`resolve_drugbank_entity`/`get_drugbank_detail`/`search_drugbank_passages`（DrugBank 实体解析+科学证据检索）、`search_cn_medicine_products`/`get_cn_medicine_detail`（结构化中文药品库）、`search_medical_qa_corpus`（`medical_qa_embeddings` 向量表，由 `scripts/import/medicine/import-medical-qa.ts` 从 DrugDataBase 的 `医疗问答数据集一共135万条` 导入，BLOCKED/CAUTION 关键词安全过滤、答案最短长度过滤、两阶段 filter→embed）。
- 实际作用：回答药品问题时有真实证据底座；三级信任分层（说明书>DrugBank>医疗问答）写入 prompt。
- 真伪判定：真实现。但**数据质量风险**：135 万条语料源为 alpaca_zh_demo 类开放医疗问答（机器生成、质量参差），导入脚本只做关键词级过滤，无法保证医学正确性；系统提示将其标为"curated"（`system.prompt.ts` "comes from a curated medical Q&A database"）名不副实。
- 结论：保留（方向修正：说明书/审校数据优先，135 万开放语料降级为"低可信教育参考"并展示来源等级）。
- 改造方案：
  - P1：把"curated"措辞改为"开放语料、低可信教育参考"；医疗问答类回答强制最低限度免责（与 F-13 联动）。
  - P1：对 135 万条语料增加"可验证性"分层：优先只把有结构化来源（药品说明书/中国食物成分表/已审校数据）的 chunk 标记为可引用，医疗问答仅作兜底，且 top-k 减半（现 `ASSISTANT_VECTOR_DEFAULT_LIMIT` 默认条数偏高）。
  - P2：说明书/问答检索结果加"最后更新日期"与"批准文号"元数据展示，增强可信度。

### F-16 提案式写入（建/改/删记录、改设置）

- 现状：见 F-11。写入本身由客户端 `ProposalExecutionOrchestrator` 分发到 `dailyRecordRepositoryProvider`（create/update/delete）与 `userSettingsControllerProvider`（applySettingsPatch）真实执行。
- 实际作用：用户说"帮我记下今天喝了 8 杯水"→ 提案卡 → 确认 → 真实创建记录（走与手记同一条 API），可进 Today 闭环。
- 真伪判定：真实现（无"点击代替真实保存"问题——确认即真实 API 调用）。
- 结论：保留；架构上有一个"批准与写入分离"的裂缝（见 F-11 改造 P1：建议服务端执行或补偿接口）。
- 改造方案：
  - P1：写入成功后 `loadRecentConversations` 与 record 数据变更总线（`DataChangeTopic.dailyRecords`）未联动——提案写入后 Today/Record 页若已打开不会自动刷新，建议确认成功后 emit `DataChangeTopic`。
  - P2：`DailyRecordKind` 映射只有 5 种（water/meal/symptom/note/sleep），未知 kind 静默降级为 note——建议未知 kind 时拒绝生成提案而不是降级写入。

### F-17 助手状态栏/控制面板 sheet

- 现状：`status_bar.dart`、`controls_sheet.dart`、`controls_sheet_opener.dart` 三个文件在代码库中零引用（grep 仅自引用）；实际设置入口已迁移到 `Settings → AI`（`settings/presentation/pages/ai.dart`），页面顶栏齿轮直接 `context.push(Routes.settingsAi)`。
- 实际作用：无（死文件，纯历史残留）。
- 真伪判定：死代码。
- 结论：归档（不删除原则：保留代码与标记，不接入 shipping，不排期）。
- 改造方案：P2：归档处理——3 个文件及 l10n 键保留，文件头加 `// Experimental/legacy — not part of the shipping assistant path.` 标记与维护者注释（若 `assistantStatus*` 文案已被 status 简化版取代可一并标注），不接入任何入口；若半年后仍无消费方再移入归档目录（不删除），并补一条 migration log 记录归档决定。

### F-18 lib/core/ai/ app-side runtime seam

- 现状：`runtime_config.dart`/`runtime_providers.dart` 提供 `AiRuntimeEnvironment`（`LUMINOUS_EXPERIMENTAL_AI_RUNTIME` 等 env 读取，默认 none/关闭）与两个 provider；**全仓库无消费方**（grep 仅自引用）。
- 实际作用：无。`Mock_Or_Deferred.md` 明言"app-side AI runtime 实验 seam，默认关闭；不接入 shipping 流程"，`Runtime_Snapshot.md` 将其列为 AI 开发增强（配合 copilot/cursor 配置）。
- 真伪判定：死代码/实验 seam——**未被错误启用**（不是"错误启用的路径"，与后端真实链路无冲突）。
- 结论：保留（标记实验）。作为开发期占位可留，但需注意：它不承载任何产品能力，若长期无人使用应按 F-12 同口径清理。
- 改造方案：P2：文件头加 `// Experimental dev seam — not part of the shipping assistant path.` 注释与维护者姓名；半年无消费方再归档（保留代码与标记，不删除）。

## 三、后端投入错配判断

Lucent 侧 assistant 模块的工程深度明显超过 C 端产品的必要投入，分三层判断：

1. **与产品定位匹配、值得保留**（约 6-7 成投入）：22 工具真实执行层 + 结果信封（coverage/confidence/ambiguities）、上下文源策略过滤、三个 PGVector 知识库与导入管线、与 Today/Report 摘要联动、系统提示安全线、熔断/重试/指标。这些是"AI 读你的数据、查真实药典"的可信底座，是产品差异化核心，方向正确。

2. **投入与收益不匹配（错配）**（约 2-3 成）：
   - **LangGraph 图机深度**：意图分类子图（read/write/knowledge 三子图 + 校验节点 + 验证旗标 + 节点缓存 + HITL interrupt/resume + Postgres checkpoint）对"一个手机聊天入口"而言过度复杂。其中 HITL 挂起/恢复机制的价值被"写入仍在客户端执行"（F-11）这一架构决定大幅削弱——后端精心维持的图状态机，最终批准动作不落在服务端，徒增一致性裂缝。
   - **respondCache / 节点级缓存**（simple_chat 回复缓存 1h + classify 缓存 1h）在个人健康场景收益有限，却增加了状态一致性心智负担。
   - **135 万条医疗问答全量导入**：语料资产保留，但质量与"curated"表述不符（F-15）。当前不继续扩量，也不将其作为医学结论来源；说明书和审校数据优先，开放问答只作低可信教育参考。
   - 知识类工具 1 小时缓存、`streamPreGeneratedContent` 词级回放等为"演示顺滑"服务，优先级低于正确性。

3. **结论**：不是成本黑洞，工具调用、受控上下文和用户确认写入正是健康伙伴差异化底座。建议：a) 保留“提案→用户确认→真实写入”的 HITL 产品语义，工程上只在可靠性与补偿测试证明需要时调整 graph 挂起或执行位置，不为了展示复杂度继续加层；b) 医疗问答资产保留并降级为兜底数据源，修正表述与来源等级；c) 开放式 GenUI 保留但冻结；d) 缓存策略保持现状不再加码。

## 四、模块级结论

**AI 助手在定位下的价值判断：是差异化核心卖点，但当前形态（聊天框）与产品定位（主动建议卡为行动界面）存在错位，且有 3 个信任缺口必须补齐。**

- **定位匹配度**：`Product_Vision.md` 将 Assistant 与 Today 主动建议、Review 纵向洞察并列为健康伙伴的三个交付面。现状已承载解释、提案、辅助执行能力（F-11/F-14/F-16 均真实且有闭环），但个人证据展示和健康记忆治理仍不足。**保留并继续投入，按“上下文伙伴交互”而不是通用聊天产品管理。**
- **信任缺口（P0，全部在客户端呈现层）**：a) 零免责呈现（F-13）；b) 参考来源不展示（F-7）；c) 低可信语料（135 万医疗问答）没有来源级信任标记（F-15）。这三点不修，AI 回答在医疗场景随时可能误导用户，且是产品口碑的最大风险点。
- **成本黑洞判断**：不是黑洞——前端代码约 30 个文件、后端约 60 个文件，核心资产（工具层/提案/HITL）真且可用；黑洞风险在后端过度工程区（第三节），建议收敛而非加码。
- **建议动作排序**：P0 补齐免责与来源展示 → P1 提案写入服务端化（或补偿接口）+ 记忆摘要压缩 → P1 会话重命名/删除落地（后端两端点 + 前端接线）→ P1 医疗问答信任分层 → P2 归档 F-17 等确定死代码（保留不接入 shipping）；F-12 GenUI 与 F-18 实验 seam 保留冻结，不推进也不作为已交付能力。
- **一句话**：AI 链路是真实现、方向对、有闭环的底座能力；把它从“功能最重的聊天”改造成“证据最透明、能读取受控纵向上下文的伙伴交互”，才可能形成差异化。
