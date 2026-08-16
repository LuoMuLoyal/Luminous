# AI 助手(assistant)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `Luminous/research/02-功能盘点/assistant-AI助手.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 5 位。

## 一、目标与范围

范围:客户端 `Luminous/lib/features/assistant/`、`Luminous/lib/core/ai/`;后端 `Lucent/src/modules/assistant/`、`Lucent/src/llm-runtime/`。

目标:AI 链路本身是真实现、有闭环的底座能力(22 工具执行层、SSE 流式、HITL 提案、上下文策略过滤均为真),本计划不重写链路,只做三件事:

1. **补齐三大 P0 信任缺口**(全部在客户端呈现层):F-13 免责呈现、F-7 来源展示、F-15 来源级信任分层。这是医疗产品的合规与信任底线,不修则 AI 回答随时可能误导用户。
2. **落地三项"已设计、未落地"的能力**:F-2 会话重命名/删除、F-4 Markdown 视觉模板、F-5b 重新生成/重新发送。注意:这三项在调研中按"计划视为已执行"的审计口径被评为真实现,但仓库实际仍是占位/禁用状态,本计划一律视为待实施项。
3. **修复两处一致性裂缝**:F-11/F-16 提案"批准与写入分离"、F-9 持久记忆原文直灌。

范围外(冻结):F-12 GenUI 开放式渲染引擎维持冻结——`genUiEnabled` 保持默认关闭,不删除方向、不进入近期路线图、禁止包装成已交付能力;若将来解冻,优先从受控提案卡类型扩展开始。

## 二、保留不动(清单)

- F-1 会话管理核心链路(`AssistantController` + 抽屉分组/搜索,前后端 7 端点一一对应)。
- F-3 SSE 流式对话核心(`LucentSseClient` 四类事件 + 错误分类 + `retryLastMessage`)。
- F-6 工具调用执行层(22 个工具、LangGraph agent↔tools 循环、结果信封 coverage/confidence/ambiguities)。
- F-8 上下文选择(4 源开关 → `policy.service.evaluate` 服务端工具级过滤,非仅 UI 隐藏)。
- F-10 capabilities 开关(服务端策略 + 客户端门控双重生效,`canSendMessages` 四条件)。
- F-11 提案卡产品形态(4 类 `propose_*` 工具 + `write_review` interrupt/resume + 提案卡 UI,差异化价值最高部分;改造项仅修一致性裂缝,见下)。
- F-14 与 Today/Report 摘要联动(`historical_ai_summary` 表读写)。
- F-12 GenUI 开放式渲染引擎:冻结保留(见范围外)。
- 后端缓存策略(respondCache/classify 缓存/知识工具 1h 缓存):保持现状,不加码。

## 三、改造项(按优先级分组)

### P0:三大信任缺口(客户端呈现层，0.1.0 前)

#### F-13 AI 回答免责与安全边界

- 现状:后端 prompt 层强(系统提示五条安全线、知识子图"检索缺失不编造"、工具信封带 `disclaimer`、导入脚本 BLOCKED/CAUTION 过滤),但客户端呈现为零——欢迎面板、消息气泡、输入区、设置页 grep "免责/disclaimer/consult/医生" 零命中。
- 改造方案:
  - 欢迎面板与每条助手消息底部固定免责条:"AI 回答仅供健康参考,不构成医疗诊断或用药建议;用药调整请咨询医生/药师。"首次会话展开,之后折叠为小字。涉及 `message_bubble.dart`、欢迎面板组件;新增 l10n 键走 `lib/l10n/src/` 片段文件 → `dart scripts/arb_tools.dart merge` → `flutter gen-l10n`。
  - 渲染后端信封已有的 `disclaimer`(`assistant.medical_knowledge_disclaimer` i18n 键)而非丢弃,与 F-7 来源条合并呈现。
  - `simple_chat` 快路径(无工具约束)强制补免责尾注:优先客户端统一追加,保证"模型没自觉"时仍有边界(P1 可后移,但随 P0 一并设计)。
- 前后端分工:纯客户端呈现为主;后端仅在 `simple_chat` 兜底回复追加服务端尾注时改动 `respond` 节点。
- 依赖:F-7 来源条组件(免责条与来源条共用消息底部槽位)。

#### F-7 工具调用展示(参考来源条)——横切 UI 组件,本计划拥有并写全

- 现状:数据链路通到 UI 门口即断——后端 `result` 事件返回 `usedTools`,`AssistantMessage.usedTools` 已解析保存,l10n 键 `assistantUsedToolsLabel` 与 `localizeToolName`(22 个工具中文映射)齐全,但 UI 零渲染。
- 改造方案:
  - 新建来源条组件(assistant 域内共享 widget,如 `presentation/widgets/source_strip.dart`):助手消息底部渲染 `参考来源:今日记录 · 药品说明书(布洛芬缓释胶囊)· 医疗问答`,工具名走 `localizeToolName`;点击展开该轮工具结果信封(coverage/confidence/ambiguities)只读视图。
  - 该组件同时承接三处挂接(本计划内一并接线,不再分散到各条):
    - F-15:知识类回答附加来源类型徽标(说明书=较高可信 / DrugBank=科学依据 / 医疗问答=低可信教育参考),与后端三级信任分层一致(见 F-15 改造项)。
    - F-14:摘要工具返回的 `confidenceNote`/`sourceVersion` 呈现为"数据截至 X 日"。
    - F-10:`capabilities.tools` 明细(22 项 enabled/disabledReason)合并做"能力详情"面板,disabledReason 翻译成用户话术(P2,来源条落地后追加入口)。
- 前后端分工:纯客户端;后端 `usedTools` 与信封已就绪,无 API 变更。
- 依赖:无;是 F-13 免责条、F-15 信任分层的前置。

#### F-15 药品知识检索——来源级信任分层(P0 部分)

- 现状:三类检索(说明书 PGVector / DrugBank / 135 万医疗问答语料)均为真实现,三级信任分层已写入后端 prompt;但系统提示把开放语料标为 "curated medical Q&A database" 名不副实,且客户端无来源等级呈现。
- 改造方案(P0 信任分层部分):
  - 后端 `system.prompt.ts` 措辞修正:"curated" → "开放语料、低可信教育参考",明确三级信任分层(说明书 > DrugBank > 医疗问答)。
  - 客户端经 F-7 来源条强制展示来源类型徽标;医疗问答类回答叠加"低可信教育参考"提示与 F-13 免责联动,不得静默呈现为医学结论。
- 前后端分工:后端改 prompt 措辞与信封标记;客户端渲染徽标。
- 依赖:F-7 来源条。

### P1（0.1.0 前）

#### F-2 会话重命名与删除(已设计、未落地)

- 现状:设计已在 `2026-08-01-ai-chat-redesign-plan.md` 阶段 3 明确,但仓库为占位——`assistant.controller.ts` 仅 7 个端点,无 PATCH/DELETE;`conversation_drawer_list.dart` 无重命名/删除菜单。
- 改造方案:
  - 后端:新增 `PATCH /assistant/conversations/:id`(仅 title)与 `DELETE /assistant/conversations/:id`(软删除,`AssistantConversationStatus` 增加 `deleted`,列表默认过滤);改后 `pnpm export:openapi` 并重新生成客户端。
  - 前端:`conversation.dart` 补 `renameConversation`/`deleteConversation`,侧边栏长按/右键菜单接线,复用 `runGuarded` 失败 toast;重命名本地先更新、失败回滚 toast;删除二次确认;"新对话"移至抽屉顶部。
  - 删除闭环:删除当前活跃会话后 `conversationId` 置空 + 本地清空 + 刷新列表;若删除的是最新会话,回退 `loadLatestConversation` 兜底,不得白屏。
  - 顺带(F-1 P1):抽屉"当前会话"行加「归档中」loading 反馈(clear 为异步);空标题会话提供"点击补名"入口,复用同一重命名路径。
- 前后端分工:后端两端点 + 前端接线,各占一半。
- 依赖:无;F-9 P2"记忆擦除"入口依赖本项的删除能力。

#### F-5b 重新生成/重新发送(已设计、未落地)

- 现状:复制为真实现;"重新生成"(助手消息)与"重新发送"(用户消息)在 `message_bubble.dart:147-172` 为 `onPress: null` 禁用项,计划未单独成文,仅有方向性设计。
- 改造方案:
  - 最低成本路径:前端接 `retryLastMessage` 同款管线(复用 `streamMessages`,后端 `persistAssistantTurn` 的 `findAppendStartIndex` 已具备去重追加能力),设计意图为调 `_sendMessageInternal(appendUserMessage:false)` 复用现有流式管线并持久化新轮次;若该路径验证不足,后端补 `regenerate`/`resend` 端点(按 conversationId+messageId 回滚到该轮再流式)。
  - P2 追加:重新生成后旧回答保留为灰色"已替换"态,避免上下文跳变。
- 前后端分工:优先纯前端接线;端点方案需后端 + openapi 重新导出。
- 依赖:F-3 流式重发管线；断流时保留内容，由用户点击「继续生成」，不自动重连。

#### F-11/F-16 提案写入一致性裂缝(逐功能口径 P1)

- 现状:后端 `confirm` 端点只做"批准",真实写入在客户端 `ProposalExecutionOrchestrator` 执行——客户端写入失败时后端线程已按 approved 收尾,出现"已确认但未写入"裂缝。
- 改造方案:
  - 采用后端 `confirm` 端点真实写入（服务端原子化）；不引入客户端反向 `reject` 补偿接口。
  - 提案过期后卡片显示"已过期,请重新生成"并可一键重触发(现状 `isExpired` 仅抛错 toast);P2:过期按单条 `expiresAt` 计算而非整批取最早。
  - F-16 联动:提案写入成功后 emit `DataChangeTopic.dailyRecords` 数据变更总线,Today/Record 页已打开时自动刷新(跨模块契约,见第四节);P2:未知 `DailyRecordKind` 拒绝生成提案,不再静默降级为 note。
- 前后端分工:方案 a 后端为主;方案 b 前后端各半;DataChangeTopic 联动纯前端。
- 依赖:无;与 F-2 无耦合。

#### F-9 持久记忆摘要压缩

- 现状:`buildMemoryBlock` 把最近 3 个会话的原始文本直灌为 `HumanMessage`——token 污染、隐私面大,且 LLM 易误把旧话题当当前诉求。
- 改造方案:
  - 改摘要压缩:记忆块不灌原文，归档后以后台防抖任务提取「会话标题 + 可删除的结构化要点/偏好」，LangGraph Store 只负责持久化与检索，最多返回 5 条相关记忆。
  - 记忆启用时在欢迎区显示"已开启跨会话记忆",告知用户数据被用于延续对话;注入失败/为空保持静默降级(现状 OK)。
  - P2:提供"记忆擦除"入口(与 F-2 删除联动)。
- 前后端分工:后端为主(摘要生成在服务端图内);客户端仅欢迎区提示。
- 依赖:F-2(P2 擦除入口)。

#### F-15 语料治理(P1 部分)

- 改造方案:
  - 对 135 万条语料增加"可验证性"分层:优先只把有结构化来源(说明书/中国食物成分表/已审校数据)的 chunk 标记为可引用,医疗问答仅作兜底;检索结果最多保留 5 条相关记忆/证据，具体 retrieval 实现随 P1 交付验证。
  - P2:说明书/问答检索结果加"最后更新日期"与"批准文号"元数据展示(挂 F-7 来源条)。
- 前后端分工:后端检索服务与导入脚本侧;客户端仅展示元数据。
- 依赖:F-7 来源条。

#### 其余 P1 小项(逐条落地,不单独设节)

- F-3 断流补偿:不自动重连；断流时保留 `streamingDraft` 残句为失败消息内容供复制，并由用户点击「继续生成」。
- F-6 兜底 prompt:`MAX_TOOL_LOOPS` 耗尽后 `respond` 兜底生成时显式告知"工具轮次已耗尽",避免答非所问。
- F-8 上下文开关:开关变更时 toast 提示"下次对话生效"(历史消息中旧数据不回退);P2 在设置页副标题写明各源实际包含字段。
- F-13 P1 部分:设置页"AI 隐私"区补充数据使用说明(记忆/上下文开关实际发送给 LLM 的内容范围)。

### P2（0.1.0 后）

- F-4 Markdown 视觉模板(已设计、未落地):在 `MarkdownStyle.ai` 工厂上扩展标题字号阶梯/列表缩进/表格边框/引用块左侧色条;注意窄屏表格横向滚动与代码块折行;追加客户端契约校验(表格列数、链接域白名单,规则未定见不确定点),链接默认不自动跳转、先弹确认。
- F-17 助手状态栏/控制面板 sheet 归档:`status_bar.dart`/`controls_sheet.dart`/`controls_sheet_opener.dart` 三个死文件保留不删,文件头加 `// Experimental/legacy — not part of the shipping assistant path.` 标记与维护者注释,不接入任何入口;补 migration log 记录归档决定。
- F-18 `lib/core/ai/` 实验 seam:`runtime_config.dart`/`runtime_providers.dart` 文件头加 `// Experimental dev seam — not part of the shipping assistant path.` 注释,保持默认关闭。
- 各改造项中已标注的 P2 子项(F-2 标题 LLM 自动生成、F-5b 旧回答灰态、F-6 per-tool timeout + 读类工具并行化、F-9 记忆擦除、F-10 能力详情面板、F-11 单条过期、F-14 confidenceNote 展示、F-15 元数据展示、F-16 未知 kind 拒绝)。

## 四、跨计划引用与依赖

- **天气助手工具消费面**:若 assistant 工具集涉及天气查询的真实化消费面,方案见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的高德天气一节,本文不重复展开。
- **`DataChangeTopic.dailyRecords` 总线**(F-16):assistant 提案写入后 emit,消费方为 today/record 计划;本计划负责 emit 侧接线,页面刷新行为归 today(第 4 位)/ record(第 6 位)计划。
- **来源条组件**(F-7):本计划拥有并写全;F-10/F-14/F-15 的展示需求已在第三节一并接线,其他计划不重复建设。
- **桌面/Web 形态**:Flutter Desktop 与 PC Flutter Web 停止产品扩展；独立 Next.js + Tauri 桌面 MVP 在 0.1.0 后启动。桌面高级能力继续冻结，见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)，本文不展开。
- **OpenAPI 契约**:F-2/F-5b 若新增端点,须 `pnpm export:openapi`(Lucent)+ `dart run scripts/bootstrap_generated_sources.dart`(Luminous)。

## 五、本计划内执行顺序

1. F-7 来源条组件(解锁 F-13/F-15 的呈现载体)。
2. F-13 免责条 + F-15 信任分层徽标与措辞修正(P0 信任缺口收口)。
3. F-11/F-16 一致性裂缝修复 + F-9 记忆摘要压缩(P1，0.1.0 前第一梯队)。
4. F-2 会话重命名/删除落地(后端端点先行,前端接线;顺带 F-1 小项)。
5. F-5b regenerate/resend 接线 + F-3 断流补偿(共用流式重发管线,一并验证)。
6. F-15 语料可验证性分层。
7. P2 批次（0.1.0 后）:F-4 Markdown 模板 → F-17/F-18 归档标记 → 其余 P2 子项。

## 六、已决边界与保留项

- F-11/F-16 采用服务端 `confirm` 原子写入；SSE 断流保留既有内容，由用户点击「继续生成」，不自动重连。
- F-9 使用 LangGraph Store，并在归档后以后台防抖任务提取结构化记忆；医疗事实继续读取业务数据库。具体合同见决策记录与 `research/03-技术决策/` 两份调研。
- F-5b 使用 LangGraph time travel：第一版仅重生当前会话最后一条助手消息，保留旧答案为修订，并持久化 message→checkpoint 映射与幂等键。
- GenUI 继续冻结；F-4、F-17/F-18 及其余 P2 均为 0.1.0 后事项。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
