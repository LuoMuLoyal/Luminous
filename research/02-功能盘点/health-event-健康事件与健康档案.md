# 健康事件（health_event）+ 健康档案（health_context）功能盘点与真伪审计

> 范围：`Luminous/lib/features/health_event/`、`health_context/`、`report/`（事件优先回顾消费方）、`mine/`（档案编辑消费方）；后端 `Lucent/src/modules/health-events/`、`reports/`（event-review）、`user-health-context/`，以及 today-suggestion / today-analysis / medicines / assistant / admin 对事件与档案的消费面。
> 评估基准：`Luminous/docs/01-product/Product_Vision.md`、ADR-0011（事件期优先 + 稀疏记录闭环）；已删除的 product-loop 计划（健康事件、事件优先回顾）按 `docs/00-current/` 与 `docs/03-logs/migration-log/` 反推、视为已执行完毕。
> 前置审计引用：`research/02-功能盘点/today-今日建议.md` 的 F-10（Today 健康观察区块）与 F-20（health_context 快照层）已审计完毕，本文件不重复其全文；凡与事件/档案相关的补充证据在此追加。
> 全文纯中文，专有名词保留英文。

## 功能点总览

| 编号 | 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|---|
| H-1 | 事件创建（开始观察，可关联触发记录/当前用药） | 用户确认开始，后端单 active 约束 + 关联所有权校验 + 服务端权威事件 | 真实现 | 保留 | P0 |
| H-2 | 每日 check-in（好转/差不多/加重） | 每日一条、可更正、按用户时区定日期键 | 真实现 | 保留 | P0 |
| H-3 | 事件结束与结果（必选 outcome） | 结束必须选结果，幂等、不可重复结束 | 真实现 | 保留 | P0 |
| H-4 | 事件类型 kind 与症状库 | 契约有 symptom/other，UI 无选择入口恒默认 symptom；无症状库 | 部分实现（半成品字段） | 改造 | P1 |
| H-5 | 事件历史列表（Review 历史区） | status 筛选 + cursor 分页 + 空态/失败 inline 重试 | 真实现 | 保留 | P1 |
| H-6 | 事件详情/完整回顾 | 后端 GET + 客户端 provider 就绪，历史行不可点、UI 未接线 | 部分实现（链路差最后一环） | 改造 | P1 |
| H-7 | 事件编辑/修改 | 无 update API，按设计无此功能 | 不存在（设计如此） | 不做（可选 P2 补标题更正） | - |
| H-8 | 事件优先回顾（Review 四段） | 发生了什么/变化/完成/下一步，全事实性数据、无综合分、无泛化文案 | 真实现 | 保留 | P0 |
| H-9 | 事件证据链（事件↔症状记录/用药/窗口内日志） | 创建时关联并校验所有权；回顾按窗口聚合真实计数与趋势 | 真实现（UI 呈现偏浅） | 保留 | P1 |
| H-10 | 事件→Today 建议联动 | 后端事件驱动重算/缓存失效/摘要物化，但无规则消费事件内 check-in 序列 | 部分实现 | 改造 | P1 |
| H-11 | 事件闭环测量（服务端权威事件 + 管理员漏斗） | started/ended/outcome_confirmed 服务端发射、可去重可聚合 | 真实现 | 保留 | P1 |
| H-12 | 无事件空态与入口 | Review 无事件卡 + 历史承接，不生成泛化周报 | 真实现 | 保留 | P1 |
| C-1 | 档案字段真实用途核查（逐字段） | 见正文逐字段表：核心字段真用、3 个字段僵尸 | 混合 | 改造（按字段） | P1/P2 |
| C-2 | 档案编辑入口（Mine 四页 + 搜索加药 + 设置同步） | 写成功才 toast、失败入 pending sync 真实重放、错误如实 | 真实现 | 保留 | P0 |
| C-3 | Mine「档案提醒」静态假数据卡 | 硬编码 "Pollen, penicillin / 2 items"，且无渲染出口 | 假实现/死代码 | 改造 | P2 |
| C-4 | 档案完成度与 readiness gaps | 7 项完成度 + gap 引导，真实数据驱动 | 真实现（口径粗糙） | 保留 | P1 |
| C-5 | 档案→建议/风险/就诊摘要消费面 | 档案变更触发建议重算、过敏进风险检查、就诊摘要字段级隐私 | 真实现 | 保留 | P0 |

## 逐功能分析

### H-1 事件创建（开始观察，关联触发记录/当前用药）

- 现状：Today 健康观察区（F-10 已审）与 Review 无事件卡（`report/presentation/pages/page.dart:62-105` 的 `_openStart`）共用同一 `StartEventSheet` + `ActiveHealthEvent` notifier。创建时只要求短标题，可关联当日症状记录（reasonRecord）与当前用药（currentMedicineIds），选项预读失败静默降级为空列表（2 秒超时）。后端 `EventsService.create`（`Lucent/src/modules/health-events/services/events.service.ts:90-163`）做四件事：单 active 冲突校验、关联用药所有权校验（`findOwnedCurrentMedicineIds`）、关联记录所有权校验、写库成功后发 `HEALTH_EVENT_CHANGED` 领域事件并发射服务端权威 `health_event_started` 产品事件（幂等 clientEventId）。
- 实际作用：事件是产品「短期健康事件」定位的第一个用户确认动作。关联项在创建时被后端校验归属，防止把别人的药/记录挂到事件上；`POST /health-events` 幂等语义由 `(userId, clientEventId)` 唯一约束承接重试。
- 真伪判定：真实现。没有「弹窗关闭=已保存」伪语义（`dashboard_view.dart:287-293` 的 `saved` 标志与 report 页一致）；创建成功由服务端响应决定，失败保留输入可重试。
- 结论：保留。
- 改造方案：无必改项。选项预读失败静默空列表可加一行「加载失败可重试」（与 F-10 小问题一致）。
- 优先级：P0。

### H-2 每日 check-in（三选结果，每日一条可更正）

- 现状：`CheckInsService.upsertForDate`（`Lucent/src/modules/health-events/services/check-ins.service.ts:59-110`）按 `(eventId, date)` 幂等 upsert，同一自然日最多一条、可更正（覆盖写入），校验 date 格式、事件存在且 active；成功后发 `HEALTH_EVENT_CHANGED`（change=check-in）与 `health_event_outcome_confirmed` 产品事件。客户端日期键由用户 profile 时区计算（`core/utils/local_date.dart`，缺省 `Asia/Shanghai`），Today 与 Review 共用。check-in 契约是 `PUT /health-events/{id}/check-ins/{date}`，客户端 `CheckInSheet` 三选提交。
- 实际作用：稀疏记录闭环的「每天一个动作」——事件期内用户每天只做一次三选，构成 outcome 序列供回顾的趋势段使用（H-8）。
- 真伪判定：真实现。后端 live E2E 验证过「没有任何系统路径绕过用户确认写 check-in」；更正语义是覆盖而非伪造多条。
- 结论：保留。
- 改造方案：无。
- 优先级：P0。

### H-3 事件结束与结果（必选 outcome）

- 现状：`EventsService.end`（`events.service.ts:225-273`）要求 outcome 必填（improved/unchanged/worsened），校验事件存在且 active（重复结束返回 400 `already_ended`），结束时间取服务端 `now()`，时区日期键进入领域事件；发射 `health_event_ended`（result 即 outcome）。客户端 `EndEventSheet` 未选结果不可提交，成功后 `ActiveHealthEvent` 置 `AsyncData(null)` 并广播 `healthEvents` topic。
- 实际作用：事件有明确结束与结果，是回顾「事件结束→结果确认」与漏斗「ended 与 outcome_confirmed 合并为一阶段」的语义基础。
- 真伪判定：真实现。
- 结论：保留。
- 改造方案：无。
- 优先级：P0。

### H-4 事件类型 kind 与症状库

- 现状：契约与表里有 `kind`（`HealthEventKind.symptom | other`），但：客户端 `StartEventSheet` 没有任何类型选择控件（只有标题、关联用药、关联记录三组输入）；`EventsService.create` 缺省 `kind ?? symptom`；controller `toItem` 同样 `kind ?? symptom` 兜底（`health-events.controller.ts:134`）。全工程 grep 无任何「症状库 / symptom 建议词」代码（记录页与事件页均为自由文本）。Review 里 kind 只用于一个静态标签（`reviewEventKindLabel`，symptom/other）。
- 实际作用：kind 目前不产生任何行为差异——symptom 与 other 的事件在创建、check-in、回顾、建议联动上完全同路径（唯一差异是 trigger listener 对 `kind === 'other'` 的 check-in 跳过建议重算，见 H-10）。「症状库」功能不存在。
- 真伪判定：部分实现（半成品字段而非假实现——没有占位数据冒充，是直接没做完：契约留了口子，UI 不给入口）。
- 结论：改造。
- 改造方案：kind 字段保留（不删字段、不删分支），改造为回顾区"按事件类型筛选"的筛选标签——按 kind 过滤历史列表，纯 UI、零后端改造；中期增强为"症状标签集合"（事件创建时勾选症状、与记录页症状库联动），排期后做。事件期内 `kind === 'other'` 的 check-in 跳过建议重算分支保留（语义即"非症状事件不进症状建议"）。
- 优先级：P1。

### H-5 事件历史列表（Review 历史区）

- 现状：`ReviewHistorySection`（`report/presentation/widgets/sections/review_history.dart`）列出事件历史：最近在前、status 筛选（全部/进行中/已结束）、失败卡片内 inline 重试、空态真实文案。数据来自 `GET /reports/reviews`（status/cursor/limit），分页下推后端 repository（`findPageByUser`：复合 cursor `startedAt|id` 严格校验 + limit+1 探测 + 独立 count），客户端 `reviewHistoryProvider` 只缓存第一页，翻页由 presentation 直接调 repository。历史项展示标题、时段、状态/结果 chip。
- 实际作用：当前事件专题的浏览入口，替代旧 dashboard 在移动主路径中的 7/30 天统计；时间范围刻意不进该事件合同。长期日/周/月洞察应另用覆盖率合同承载，不由事件列表替代。
- 真伪判定：真实现。筛选切换沿用旧数据不闪骨架（`skipLoadingOnRefresh`），无「点击=成功」语义。
- 结论：保留。
- 改造方案：无。
- 优先级：P1。

### H-6 事件详情/完整回顾（历史行点开）

- 现状：后端 `GET /reports/reviews/{eventId}` 完整实现（`EventReviewService.buildForEvent`）；客户端 `reviewDetailProvider`（autoDispose family）与 `LucentReviewRepository.fetchReview` 全部就绪（`report/presentation/providers/review.dart:122-134`、`lucent_review.dart:82-85`）。但 `_HistoryEventRow` 是只读行（无 onTap），代码注释明言「点开查看完整回顾属于后续任务」（`review_history.dart:12`），`reviewDetailProvider` 全工程无消费方。
- 实际作用：目前为零——过去事件只能看历史列表里的摘要，完整四段回顾只能看到最近一个（current 优先 active、否则最近 ended）。完整历史回顾是事件领域的可用性缺口，但不是长期健康伙伴的总价值缺口。
- 真伪判定：部分实现（不是假实现——数据链路与 provider 都真，差 UI 接线这一环）。
- 结论：改造。
- 改造方案：历史行加 onTap → push 详情页（或底部弹层），复用 `ReviewView` 的事件头部+四段渲染（已有现成 widgets），接 `reviewDetailProvider(eventId)`；事件头部同时补 `reasonRecord` 关联展示一行（证据链，见 H-9）；成功后上报 `review_opened`（复用 `_ReviewOpenedTracker` 的 session 去重语义）。工程量小、闭环价值直接。
- 优先级：P1。

### H-7 事件编辑/修改

- 现状：后端 6 个 health-events 操作（create/active/list/get/check-in/end）中无任何 update/patch；客户端无编辑入口。事件标题只在创建时可定，结束后历史只读。
- 实际作用：无。设计意图（ADR-0011「必须由用户确认」的生命周期模型）里编辑不在范围内；历史投入也从未规划编辑。
- 真伪判定：不存在（设计如此，非假实现）。
- 结论：不做。若真实用户反馈标题笔误高频，再补 P2 的「标题更正」最小端点（仅 title，事件进行中可改），不影响生命周期语义。
- 优先级：-（P2 可选）。

### H-8 事件优先回顾（Review 四段）

- 现状：`ReviewView` 六状态（loading/active/ended/partial/error-with-cache/no-event）；四段由后端四个 section builder 组装（`Lucent/src/modules/reports/services/event-review/`）：
  - 发生了什么 `facts.service.ts`：事件窗口（时区当天 00:00 起）、关联用药数、窗口内症状记录精确计数、check-in 计数——全部真实计数，无自由文本；
  - 有什么变化 `changes.service.ts`：check-in 首末 outcome 趋势 + 饮水（canonical ml 汇总）/睡眠（payload durationMinutes）单维首末数值趋势，数据不足给 `no_observations`/`insufficient_coverage` reason code，绝不写因果句；
  - 完成了什么 `actions.service.ts`：按 reminder 槽位统计 confirmed/skipped/unconfirmed（planned/missed 归 unconfirmed，明确不算失败）+ 已完成 check-in 列表；
  - 接下来怎么办 `next-step.service.ts`：active 无今日 check-in → 提醒确认；ended → 显示 outcome；red flags 只复用已审核静态安全规则（severeAllergy/informationGap），带运行时 allowlist 自执行。
  - 每段独立 available/unknown，unknown 只显示简短缺失原因，不显示分数或红色「需关注」；覆盖率（checkIns/dailyRecords/doseLogs 三源 state/coverage/sources/observedCount）与 sourceTimestamps 如实随行。
- 实际作用：这是健康事件专题中最可信的回顾能力，也为纵向洞察提供了“事实、覆盖率、未知项”范式。它没有 AI 泛化、综合健康评分或把 unconfirmed 写成漏服，但不能替代非生病期日/周/月洞察。
- 真伪判定：真实现。抽样验证了全部四个 builder 的输入都是窗口过滤的真实数据（dedicated count 查询 + capped reader 列表），未知一律 reason code 而非补 0/补「需关注」；客户端对未知 reason code 折叠为通用文案而不是造假（`lucent_review.dart:139-142`）。
- 结论：保留（这是本模块最值得保留的资产）。定位补充：事件回顾是"纵向洞察中的专题视图"，不再统领 Review——Review 职责改版为日/周/月洞察，事件成为其中专题视图，生活维度平级。
- 改造方案：无必改项。已知限制（文档化）：red flag 为用户级静态检查、不与事件药物对齐——后续可把事件关联用药传入风险检查。
- 优先级：P0。

### H-9 事件证据链（事件↔症状记录/用药/窗口内日志）

- 现状：证据链分两层。① 关联层：创建时 reasonRecordId（当日症状记录）+ currentMedicineIds 写入，后端逐一校验所有权，结束事件后禁止建立新关联（「事件结束后保留历史关联，但禁止新的关联」）；客户端事件头部显示「关联 N 种药」计数（`event_header.dart:111-121`），但**触发记录（reasonRecord）在 UI 上无任何展示**——开始事件时选了「因为哪条记录」，之后这个选择只在后端字段里躺着。② 窗口层：回顾的 changes/actions 段按事件窗口过滤全部症状记录/饮水/睡眠/剂量日志，用真实数据构造趋势与槽位统计——这是真正意义上的证据链展示。
- 实际作用：关联层证明「事件与原因/用药的归属关系真实存在且被校验」；窗口层证明「回顾内容不是静态占位，而是事件期间真实记录的聚合」。
- 真伪判定：真实现（数据真实、校验真实），但 reasonRecordId 这条关联在用户可见面上断了（录了没展示）。
- 结论：保留。
- 改造方案：事件头部（active 与 ended 都算）把 `reasonRecordId` 解析成记录标题展示一行「由记录触发：xxx」；`whatHappened` facts 已携带 medicineIds，可顺带在 facts 参数里加 reasonRecordTitle（后端从窗口记录里按 id 取，避免客户端再造查询）。P1。
- 优先级：P1。

### H-10 事件→Today 建议联动

- 现状：后端联动真实存在——`HEALTH_EVENT_CHANGED`（create/end/check-in）触发三条链路：today-suggestion 重算（`recompute/trigger.listener.ts:88-101`，kind=other 的 check-in 显式跳过）、suggestion 缓存失效（`suggestion-cache-invalidation.listener.ts:121-128`）、today-analysis 物化触发（`today-analysis/recompute/trigger.listener.ts:50`，F-7 已审）。客户端 Today 在事件动作成功后调 `onRefresh()` 刷新 dashboard 与建议。但：today-suggestion 规则层没有任何规则消费事件内 check-in 序列——7 条规则（漏服/饮水/睡眠/症状恶化/档案/咖啡因/情绪）的信号全部来自 daily record / dose log / profile，`checkIn` 数据只流向 Review，不进建议信号；客户端 `suggestion.dart:42-47` watch 的 DataChangeTopic 列表也**不含 healthEvents**（靠 onRefresh 兜底）。
- 实际作用：事件的写入会让建议重新计算（间接联动成立），但「事件期 check-in 连续恶化→主动建议（如提醒就医/建议结束事件）」这类事件专属洞察不存在——事件数据对建议的唯一影响是触发重算本身。
- 真伪判定：部分实现（重算联动是真，事件语义进建议规则是缺）。
- 结论：改造。
- 改造方案：① 按"建议升级通知"规则（R2）：事件期内连续 2 次 check-in 为"加重"，或新记录症状 → 升级通知——经建议升级通知执行器投递（与 today-suggestion 物化同构，本地通知为主、JPush 为辅），每天最多 1 条，超出进 Today 次建议区不弹窗；信号接入：consumableSignalKinds 增加 `event_check_in_trend` 观察项，证据口径为 check-in 日期与结果序列（H-8 已有该数据基础）；② 客户端 suggestion provider 的 topic 列表补 `healthEvents`，让事件动作后建议卡与事件区块同频刷新（去掉对 onRefresh 的依赖）。
- 优先级：P1。

### H-11 事件闭环测量

- 现状：`health_event_started` / `health_event_ended` / `health_event_outcome_confirmed` 全部服务端权威发射（写库成功后才发，`events.service.ts:154-161,264-271`、`check-ins.service.ts:102-108`），确定性 clientEventId 幂等去重；管理员漏斗 `GET /product-events/funnel` 按阶段聚合（started → impression/actioned → ended/outcome → review opened），样本低于阈值抑制细节；客户端只在成功边界上报（`_ReviewOpenedTracker`、导出 success/failure 分流）。
- 实际作用：闭环测量不是摆设——漏斗能量化“事件→建议→回顾”这一领域路径（ADR-0011 的历史度量主张），但不再作为整个产品的北极星或长期伙伴假设的唯一证据。
- 真伪判定：真实现（含 `INTENTIONALLY_UNCOUNTED_EVENT_NAMES` 强制枚举防静默丢数）。
- 结论：保留。
- 改造方案：无。
- 优先级：P1。

### H-12 无事件空态与入口

- 现状：Review 无事件时显示「开始健康观察」卡 + 轻量解释 + 下方历史列表；完全没有事件时不生成任何周报或泛化内容（`review_view.dart:94-98`）；未登录 preview 隐藏开始按钮、显示登录引导。Today 侧无事件显示「开始一段健康观察」入口（F-10）。
- 实际作用：不把「无事件」包装成「无数据健康状态」，符合稀疏记录语义。
- 真伪判定：真实现。
- 结论：保留。
- 改造方案：无。
- 优先级：P1。

### C-1 档案字段真实用途核查（逐字段）

抽样方法：后端全模块 grep 各字段消费方 + 客户端全工程 grep。结论按「真用（有业务逻辑消费）/半用（仅展示/计数）/僵尸（无任何消费方或只有自写自读）」分类：

| 字段 | 后端消费方 | 客户端消费方 | 判定 |
|---|---|---|---|
| birthDate / age | today-suggestion profile 完整性信号 + medication coverage 规则（`today-suggestion/services/collectors/profile.service.ts:27-42`、`rules/medication/coverage.service.ts:21`）；clinic-summary；admin | Mine 展示、完成度 | 真用（驱动「档案不全」建议） |
| sexAtBirth | 同上（profile 完整性） | Mine 展示 | 真用 |
| heightCm | 同上（缺 heightCm 即档案不全） | Mine 展示 | 真用 |
| weightKg | 无（仅 user-health-context 自读写） | Mine 展示 + 完成度 + readiness gap | 半用（录了只在前端展示/计数） |
| bloodType | clinic-summary PDF（`summary.service.ts:482-493`）、assistant read tool、admin 列表 | clinic summary 展示、profile 编辑 | 边缘（只有展示性出口，无规则消费；产品价值低但非假数据） |
| locale / timezone | 时区决定事件/check-in/建议的日期键（`formatDateOnlyInTimezone` 贯穿事件、回顾、重算）；locale 走 i18n | 设置同步、check-in 日期键 | 真用（时区是事件语义的基石） |
| unitSystem | **无任何消费方**（grep 确认） | profile 编辑 + 设置同步，无单位换算逻辑（身高永远按 cm、体重按 kg 显示） | 僵尸字段（前后端都录了不用） |
| emergencyContactName/Phone | **无任何消费方** | profile 编辑 + Mine readiness gap 提示 | 僵尸字段（只有「填了就消 gap」这一个出口，无业务用途） |
| onboardingCompleted(At) | 仅 mapper 输出 | 仅 Mine 完成度 +1；**无任何写入方**（无 onboarding 流程，客户端从未提交该字段） | 僵尸字段（恒 false/缺省，唯一作用是完成度分母） |
| allergies | 用药风险检查 severeAllergy 规则（`risk-detection.service.ts:45,124-149`，命中 +40 风险分）、risk check LLM 上下文、assistant read tool、clinic-summary | Mine 编辑、搜索 | 真用（安全核心） |
| conditions | risk check LLM 上下文、clinic-summary、assistant；profile 信号只数 activeConditionCount 进 payload、**无规则消费** | Mine 编辑 | 半用（进上下文但不单独驱动任何建议/风险规则） |
| currentMedicines | 提醒/剂量日志/事件关联（`events.service.ts:99-106` 所有权校验）、assistant policy、risk check、clinic-summary | 提醒表单、搜索加药、Today 用药口径、事件关联选项 | 真用（跨模块核心） |
| extras | 无消费方 | 无消费方 | 死字段（自由扩展槽，从未被使用） |

- 实际作用：档案的真实价值集中在「过敏 → 用药安全」「档案缺失 → 档案不全建议」「当前用药 → 提醒/剂量/事件/就诊摘要」「时区 → 事件日期语义」四条线上；其余字段是展示性/计数性用途。
- 真伪判定：混合——核心字段真实现，`unitSystem`、`emergencyContact`、`onboardingCompleted`、`extras` 四个字段符合「录了没用」僵尸模式（后端存储 + 前端表单齐全，但零业务消费），其中 unitSystem 与 emergencyContact 还有 UI 入口让用户真实填写，比纯死字段更有误导性（用户以为填了有用）。
- 结论：改造（按字段，决策已定，不删除字段）：
  - `weightKg`：改造为"体重记录维度"——档案字段保留为当前基线，新增时间序列记录（手动 + 平台导入）；与血糖趋势、血压 vital 合并为"vital 时间序列"基建，进纵向洞察周/月单维趋势（带覆盖率标注）；体重记录入口放记录页快捷记录（P1）；
  - `conditions`：保留为档案字段，进入助手上下文（助手可读疾病史，回答"结合我的情况"问题）+ 健康事件创建时的可选关联；不进药物风险判断（MVP 门控，待规则库成熟再议）（P1）；
  - `unitSystem`：接单位制显示切换（体重 kg/lb、饮水 ml/oz）（P2）；
  - `emergencyContact`：标注延后，不排期（P2）；
  - `onboardingCompleted`：改造为引导流程状态（P2）；
  - `extras`：归档——自由扩展槽保留，标注不接入主路径，不排期（P2）。
- 优先级：P1/P2。

### C-2 档案编辑入口（Mine 四编辑页 + 搜索加药 + 设置同步）

- 现状：Mine 档案区四个入口（基本信息 `/mine/profile/edit`、过敏、慢病、当前用药）全部走 `healthContextRepository` 写接口（`health_edit_forms.dart` 四个 Notifier）；搜索页「加入当前用药」直接建 currentMedicine 并触发风险检查预览（`search/presentation/pages/page.dart:100-140`）；设置页 locale/timezone/unitSystem 同步到 profile（`settings/presentation/providers/profile_sync.dart`）。写路径统一：远程成功 → 更新本地快照缓存；网络失败 → 请求序列化入 `pending_sync` 队列由 SyncWorker 真实重放 + 向 UI 抛错（F-20 已审快照层，此处确认写入口全部经过该链路）。
- 实际作用：档案数据的全部写入入口，无一绕过缓存-同步体系。
- 真伪判定：真实现。保存成功边界在后端响应之后（toast 仅在 `saved` 状态出现时弹出），编辑页失败显示错误文案不假装成功。
- 结论：保留。
- 改造方案：无。
- 优先级：P0。

### C-3 Mine「档案提醒」静态假数据卡

- 现状：`mine/data/repositories/lucent.dart:126-152` 的 `_buildAlerts` 构造三条 `MineStatusCard`：过敏卡是 `const` 硬编码（title/subtitle/badge 全部静态），其 l10n 文案为「Allergies / Pollen, penicillin / 2 items」（`app_en.arb:2717-2719`）——**无论用户有没有过敏、有几个，都显示花粉/青霉素/2 项**；用药卡 badge 随 currentMedicineCount 切换，隐私卡全静态。且全工程 grep 确认 `dashboard.alerts` 在 presentation 层**没有任何渲染方**（Mine 页只渲染 archiveEntries 与 completion）。
- 实际作用：无。这是审计清单第 1 条（占位数据补空）的又一实例：静态假数据驻留在生产 repository 路径，只是恰好没有 UI 出口；一旦 Mine 页后续渲染 alerts 区，就会把「你有 2 项过敏：花粉、青霉素」当成事实展示给用户。
- 真伪判定：假实现/死代码。
- 结论：改造。去掉硬编码静态数据（"Pollen, penicillin / 2 items" 三条静态卡不再充当事实展示），改造为真实"档案提醒"卡：接真实健康档案（过敏/当前用药/档案缺口），由后端档案完整性计算驱动，成为 Mine 档案状态主卡的组成部分；`MineDashboard.alerts` 字段保留为真实数据出口，不再驻留静态占位。
- 优先级：P2。

### C-4 档案完成度与 readiness gaps

- 现状：Mine 头部完成度（7 项：onboardingCompleted/过敏数/用药数/出生日期/身高/性别/体重，`lucent.dart:107-124`）+ readiness gap 列表（基本信息/性别/体重/过敏/用药/紧急联系人六类，`account_hero.dart:186-211,344-366`），全部由真实 snapshot 驱动；archive 四项条目的完成状态（`archive.dart` 与 `_buildProfile`）同样真实。
- 实际作用：档案录入的进度反馈与下一步引导。
- 真伪判定：真实现（数据真实）。口径粗糙：完成度按「有值」而非「有用」（emergencyContact 填了就 +0 但它本来无用途——见 C-1；`basicInfoCompleted` 要求 birthDate+heightCm+sexAtBirth 三件套，weightKg 单独计项）。
- 结论：保留。
- 改造方案：完成度口径与 C-1 的字段决策对齐（unitSystem 接显示切换、emergencyContact 标注延后、onboardingCompleted 改造为引导流程状态后，同步调整分母与 gap 列表，完成度按"有用"而非"有值"）；gap 描述与编辑页路由对应关系保持。
- 优先级：P1。

### C-5 档案→建议/风险/就诊摘要消费面

- 现状：档案变更（`HEALTH_CONTEXT_CHANGED`）触发 today-suggestion 重算（`trigger.listener.ts:66-76`）与缓存失效；过敏（active）进入用药风险检查的 severeAllergy 静态规则与 LLM 上下文（`risk-context-builder.service.ts`）；currentMedicines/allergies/conditions/birthDate/bloodType 进入就诊摘要（`clinic-summary/summary.service.ts:137-195`），就诊摘要支持字段级隐私选择（事件概况/症状/用药槽位/饮水/睡眠/备注，默认不含自由文本）与可撤销分享；assistant `get_user_profile` 读取档案（read tool）。客户端 Today 的「档案不全」建议、Today 健康观察关联用药选项、F-20 快照层的消费方（Today dashboard/用药确认）全部真实接线。
- 实际作用：档案不是「录了放着」——过敏/缺失字段/当前用药分别驱动安全、建议、回顾三个产品面。
- 真伪判定：真实现。
- 结论：保留。就诊摘要消费面随"更多"入口降级——就诊摘要/PDF/分享移入"更多"，作为用户主动寻找的次级出口（surface=more），功能保留、入口下移，字段级隐私改造按需跟进。
- 改造方案：无。
- 优先级：P0。
