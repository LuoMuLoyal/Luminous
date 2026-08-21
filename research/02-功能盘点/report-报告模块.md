# 报告模块（report）功能盘点与真伪审计

- 审计日期：2026-08-15
- 审计范围：Luminous `lib/features/report/`（客户端）+ Lucent `src/modules/reports/`、`src/modules/data-export/`、`src/modules/health-events/`（后端）
- 评估基准：`docs/01-product/Product_Vision.md`（综合评分与泛化 AI 报告退出；有覆盖率说明的日/周/月纵向洞察是健康伙伴核心，事件回顾是其中一种专题）
- 判定口径：以代码实际为准；`plans/` 已删计划视为已执行完毕；不重复已审计模块（today / platform-capabilities / scan-search / engineering-backend）

## 总览表

| # | 功能点 | 一句话作用 | 真伪判定 | 结论 | 优先级 |
|---|--------|-----------|---------|------|--------|
| 1 | 事件回顾主视图（四段 + 事件头部） | 以健康事件为单位回答「发生了什么/有什么变化/完成了什么/接下来怎么办」 | 真实现 | 保留 | — |
| 2 | 回顾四段 unknown 语义 | 缺失段显示 reasonCode 本地化原因，不伪装 0 分/红色告警 | 真实现 | 保留 | — |
| 3 | 无事件状态处理 | 显示「开始健康观察」入口 + 历史，不生成周报 | 真实现 | 保留 | — |
| 4 | 事件交互闭环（开始/check-in/结束） | 复用 health_event sheet，DataChangeBus 自动刷新回顾 | 真实现 | 保留 | — |
| 5 | 回顾历史列表 | 事件历史 + status 筛选（合同 status/cursor/limit） | 部分实现（仅第一页 20 条，无翻页 UI） | 改造 | P1 |
| 6 | 回顾呈现测量（review_opened） | 呈现边界打点，session 去重 | 真实现 | 保留 | — |
| 7 | 就诊摘要 preview（脱敏） | 姓名 mask、年龄非 birthDate、仅诊断年份 | 真实现 | 保留 | — |
| 8 | 就诊摘要字段级隐私选择（六项） | 事件概况/症状变化/用药槽位/饮水/睡眠/备注 开关 | 部分实现（饮水/睡眠/备注三开关无实际内容门控） | 改造 | P1 |
| 9 | 可撤销分享（7 天 TTL） | 持久化授权记录、token 仅哈希、撤销即失效 | 真实现 | 保留 | — |
| 10 | 分享管理列表 | 创建/到期/访问次数/最近访问/撤销态，无访问者身份 | 真实现 | 保留 | — |
| 11 | 公开分享页 + 公开 PDF | 免认证读分享、信封兼容、过期/撤销 404 | 真实现 | 保留 | — |
| 12 | 就诊摘要占位数据问题（_fillMissingSections） | 曾以空默认值伪装「未选择/未返回」为「空数据」 | 已修复（代码中不存在） | 已修复 | — |
| 13 | 就诊摘要测量 | previewed/exported 客户端边界 + 服务端 share_created/opened/revoked | 真实现 | 保留 | — |
| 14 | Legacy AI 周报/月报生成（SSE 流） | 手动触发的泛化总结、真实增量流、范围切换缓存 | 真实现（仅 legacy 页可达） | 改造（周/月纵向洞察生成器） | P2 |
| 15 | AI 周报无事件/数据不足防护 | 数据不足时不得强行生成泛化周报 | 已消除（主路径无入口 + legacy 页 readiness 门控） | 已修复 | — |
| 16 | AI 摘要用户开关 | user setting 关闭时前后端双拒绝 | 真实现 | 保留 | — |
| 17 | 月度/打印 PDF 导出 | PIN 安全提升 + 队列生成 + COS 存储 + 通知 | 真实现 | 保留 | — |
| 18 | 导出成功 ≠ 医生查看/获益的口径 | 分享文案不暗示已收到，测量按请求真实状态收敛 | 已消除（文案与测量均收敛） | 已修复 | — |
| 19 | Legacy dashboard 兼容页（/report/legacy） | 旧周报视图兼容入口 | 真实现（计划内保留至兼容期结束） | 改造（纵向洞察视图） | P2 |
| 20 | 综合健康评分 | 跨维度权重打分 | 主路径已移除；legacy 页与后端仍存在 | 改造（洞察对象，不合成总分） | P2 |
| 21 | 健康趋势/统计图表（legacy） | fl_chart 单指标折线、真实聚合 | 部分实现（legacy scalar 序列存在 unknown→0 映射） | 改造（observedMetric 口径） | P2 |
| 22 | 建议历史回顾（legacy） | 建议生命周期状态列表 + 详情面板 | 真实现（仅 legacy 页） | 改造（Review「建议历史」详情视图） | P2 |

统计：功能点 22 项。真实现 14 项；部分实现 2 项（历史翻页、字段级隐私门控）；已修复的历史假实现 3 项（占位数据、泛化周报、导出等同获益——均已在 2026-08-13/14 收口）；legacy 残留 5 项（#14/#19/#20/#21/#22）统一改为「改造为纵向洞察」口径，不删除功能与代码；无当前存在的假实现，无死代码级「点击代替真实保存」。

---

## 逐功能分析

### 1. 事件回顾主视图（ReviewView）

**现状**：`/report` 主路径装配 `ReviewView`（`presentation/widgets/views/review_view.dart`）：事件头部（active 显示「进行中」+ 今日 check-in 入口 + 结束入口；ended 显示用户确认 outcome）+ 四段（whatHappened / keyChanges / completedActions / nextStep，fixed 顺序）+ 历史。后端 `EventReviewService`（`services/event-review/review.service.ts`）经 health-events ownership façade 与 daily-records / dose-logs reader ports 真实聚合事件窗口数据，四段由独立 section service 构建（facts/changes/actions/next-step），计数来自 uncapped 专属查询，趋势消费 capped reader list。客户端 mapper（`data/repositories/lucent_review.dart`）将 state/coverage/source 的未知值映射为显式 `unknown` 成员并保留 reasonCode 原文。

**实际作用**：这是当前事件专题回顾的全部主路径——以事件为单位陈述真实事实，不做因果推断、不合成结论。它不再代表长期 `Review` 的全部职责；非生病期日/周/月纵向洞察仍需另建。

**真伪判定**：真实现。抽样验证：facts.service.ts 只输出事件身份 + 症状/check-in 计数，绝不输出自由文本；next-step.service.ts 只输出固定规则（active_check_in / event_ended + 已审核静态 redFlag 结构数据，显式 allowlist `REVIEWED_RED_FLAG_RULES`）；changes.service.ts 对无观察输出 `no_observations`、有观察不足输出 `insufficient_coverage`，方向缺失由客户端 `reviewTrendDirectionLabel` 如实显示「方向未知」。

**结论**：保留。补充定位（已决策）：事件回顾是纵向洞察中的专题视图，不再统领 Review——事件是「伙伴的密集介入方式」，降为纵向洞察中的专题，生活维度平级；Review 职责改版为日/周/月纵向洞察，事件回顾作为其中专题视图嵌入（kind 改筛选标签）。

**改造方案**：无（无需改动）。

### 2. 回顾四段 unknown 语义

**现状**：客户端 `ReviewSectionCard` + `ReviewUnknownReason` 对 unknown 段渲染 reasonCode 本地化文案（`no_observations` / `insufficient_coverage` / `no_completed_actions`，未知码折叠为通用文案），不显示 0 分或红色「需关注」。测试矩阵（zh/en、dark、2x 字体）断言无 `report-score-hero`、无整页 readiness 锁、无默认导出矩阵。

**实际作用**：把「数据缺失」如实呈现为缺失原因，杜绝把缺失伪装成行为未发生。

**真伪判定**：真实现（主路径）。抽样验证：`what_happened.dart` / `key_changes.dart` 的 `isAvailable` 双条件（state==available && facts.code 匹配），不匹配一律走 `ReviewUnknownReason`；实体层 `ReviewSectionState.unknown` 与 `ReviewCoverageLevel.unknown` 均为显式成员，生成 DTO 反序列化层将未知枚举折叠为 `unknown_default_open_api` 占位并保留原文而非折叠成 null。

**结论**：保留。

**改造方案**：无。

### 3. 无事件状态处理

**现状**：`reviewCurrentProvider` 无事件返回空信封 → 客户端 `_StartObservationCard`（「开始健康观察」入口 + 轻量解释）+ 下方 `ReviewHistorySection` 历史；完全没有事件时只给解释。`page.dart` 的 `_openStart` 预读 health context 的当前用药选项与当天症状记录选项随创建请求转发（失败静默降级为空列表），创建成功后 DataChangeBus 自动刷新。

**实际作用**：无事件时引导用户开始观察，而不是产出无意义内容。

**真伪判定**：真实现。抽样验证：`review_view.dart` 中 `review == null` 分支仅渲染入口卡与历史，无任何 AI 周报/泛化内容；当前后端实现 `buildCurrent` 无事件返回 null（旧成功 envelope），非 404。

**结论**：保留。

**改造方案**：无。

### 4. 事件交互闭环（开始 / check-in / 结束）

**现状**：check-in / 结束 / 开始观察均复用 health_event 的 bottom sheet 与 `ActiveHealthEvent` notifier；服务端成功后发射 `healthEvents` DataChangeTopic，`reviewCurrentProvider` / `reviewHistoryProvider` watch 后自动刷新。集成 e2e（`review_closed_loop_e2e_test.dart`）打通「开始事件 → Record 写症状 → Medicine 确认槽位 → Review 看到更新 → 结束确认结果 → Review 变无事件 + 历史出现好转」。

**实际作用**：回顾页与记录/用药模块形成真实闭环，非静态展示。

**真伪判定**：真实现。抽样验证：`page.dart` 的 `_openCheckIn` / `_openEnd` 调用 notifier 的真实 API；review provider 的 `ref.watch(dataChangeVersionProvider(...))` 三条 topic 均在。

**结论**：保留。

**改造方案**：无。

### 5. 回顾历史列表（部分实现）

**现状**：`reviewHistoryProvider`（keepAlive）加载第一页（limit 20），status 筛选由 `reviewHistoryStatusProvider` 驱动重建重取；`review_history.dart` 只渲染 provider 返回的 items，**没有任何「加载更多」UI**；repository 与后端 cursor 分页合同（`startedAt|id` 复合 cursor、严格格式校验、has-more 探测）均已实现，但 presentation 层未消费 `nextCursor`。

**实际作用**：事件超过 20 条后，更早的历史永久不可达。

**真伪判定**：部分实现——服务端与 repository 的分页能力真实存在（`encodeCursor`/`resolveCursor` 带格式校验），但 UI 无翻页入口，功能对用户只呈现 20 条。

**结论**：改造。

**改造方案**：
- P1：`review_history.dart` 增加「加载更多」按钮（或滚动触底），调用 repository `fetchHistory(status, cursor: nextCursor)`，追加渲染并防重入；「全部」筛选下 nextCursor 可用，active/ended 筛选下同样可用。
- P2：若事件量少（当前阶段 20 条足够覆盖数月使用），可接受延后，但需在 TODO 记录。

### 6. 回顾呈现测量（review_opened）

**现状**：`_ReviewOpenedTracker` 在回顾数据实际呈现（AsyncData 过渡 + ticker 启用 + 已登录）时上报 `review_opened`，session 去重，`ProductEvent` sealed union 白名单属性，无健康内容字段。

**真伪判定**：真实现（服务端 product-events 存储 + 管理员漏斗）。与已审计的 engineering-backend 结论一致。

**结论**：保留。

### 7. 就诊摘要 preview（脱敏）

**现状**：`POST /reports/clinic-summary/preview` 由 `ClinicSummaryService.buildClinicSummary` 真实聚合用户 profile（`maskName` 张**、`calculateAge` 而非 birthDate、仅诊断年份）、allergies（isActive）、conditions（status active）、currentMedicines（isCurrent）、findings/coverage（复用 event review 结构化事实，无 review 时返回固定 `insufficient_coverage`，**不编造泛化结论**）。客户端 `clinic_summary.dart` provider 用 raw Dio 解 `{code,message,data}` 信封（生成客户端无法消费信封——已文档化）。

**实际作用**：就诊时按需使用的脱敏摘要，覆盖 preview/PDF/share 三条路径的同一过滤视图（`applySelectedFields` 单一出口，字段漂移被锁死）。

**真伪判定**：真实现。抽样验证：`summary.service.ts` `buildFindings` 只搬运 event review 的 fact code / reasonCode，无 review 时固定 `insufficient_coverage`；`applySelectedFields` 对未选 section 置 `undefined`（own property），序列化时字段被省略，任何输出路径都无法泄漏。

**结论**：保留。定位：就诊摘要 preview 与分享、PDF/打印同为用户主动寻找的次级出口，入口移入「更多」，功能保留、入口下移；字段级隐私改造见 #8。

**改造方案**：无。

### 8. 就诊摘要字段级隐私选择（部分实现）

**现状**：预览弹窗 `_FieldSelectionPanel` 提供六项开关（事件概况/症状变化/用药槽位/饮水/睡眠/备注），默认不选备注；切换即时重新请求 preview；分享创建前显示 7 天有效期与「链接持有者可查看」，创建后锁定开关。

**问题**：六项中只有三项（event_overview→profile、symptom_changes→conditions、medication_slots→currentMedicines）真正门控内容。`summary-view.ts` 的 `CLINIC_SUMMARY_SHARE_FIELD_SECTIONS` 明确注释：`water` / `sleep` / `notes` 映射为空数组——饮水/睡眠数据在 `findings`（单数组）与 `coverage`（恒包含）中，**不受开关控制**；**notes 在摘要 DTO 中根本不存在**（`ClinicSummaryDto` 无任何备注字段，服务端从未读取事件/记录的备注文本），无论开关如何，摘要都不含备注。

**实际作用**：UI 呈现六个开关，其中三个对内容无任何影响；用户以为「关掉饮水」摘要里就没有饮水数据（实际 findings/coverage 仍含），以为「打开备注」会包含自由文本（实际永不包含）。这是界面承诺与真实行为不一致。

**真伪判定**：部分实现——不是数据造假，但开关语义对用户是部分虚假承诺；服务端映射注释如实记录（`Selecting only the un-mapped fields yields a metadata-only summary`），客户端未向用户说明。

**结论**：改造。

**改造方案**：
- P1（二选一，推荐 a）：
  - a. 诚实化：六开关缩减为三个有效开关（事件概况/症状变化/用药槽位），移除饮水/睡眠/备注开关；或保留开关但注明「饮水/睡眠/备注不包含在摘要中」，并在 l10n 说明。
  - b. 改造为真实字段级脱敏：预览时按开关过滤字段——服务端把水/睡眠/备注做成真实 section（读 daily-records 汇总 + 事件备注），让开关名副其实；工作量大，与「就诊摘要为次级出口」的定位不符，不推荐。
- P1：`ClinicSummaryContent` 对未映射字段的开关状态在服务端 `selectedFields` 回显中本就无对应键（回显的是 section keys 而非六字段），需保证 UI 开关状态与回显一致，避免「开关开但内容无变化」的认知偏差（当前默认行为已偏安全——备注默认关）。

### 9. 可撤销分享（7 天 TTL）

**现状**：`ShareService.createShare` 持久化授权记录（userId、tokenHash、scope 严格 XOR：eventId 或日期范围、selectedFields、expiresAt 7 天），明文 token 只返回一次、永不落库；公开读取门 `getSharedSummary` 先查缓存再查持久化记录，revokedAt/expiresAt 双重校验 + 原子 `updateMany`（WHERE 复查关闭读→写竞态），撤销/过期返回 404。分享创建/撤销/打开各发一条服务端权威 product event（确定性 clientEventId 幂等）。

**实际作用**：分享是持久化可撤销授权，不是一次性 URL。

**真伪判定**：真实现。抽样验证：`share.service.ts` 全文核对——token 哈希 sha256、`validateSelectedFields` 白名单、`validateScope` 严格互斥、`toReadModel` 永不暴露 tokenHash/userId。

**结论**：保留。

**改造方案**：无。

### 10. 分享管理列表

**现状**：`GET /reports/clinic-summary/shares` + `DELETE /reports/clinic-summary/shares/:shareId`；`ShareManagementSheet` 展示创建时间/到期/访问次数/最近访问（或「暂无访问」）/已撤销态，撤销后仍列出并显示撤销时间；keepAlive 缓存，创建分享成功即失效缓存。不展示任何访问者身份。

**实际作用**：用户对自己分享出去的链接有完整控制视图。

**真伪判定**：真实现。抽样验证：`share_management.dart` 的 `_revoke` 走真实 DELETE + `invalidateSelf`；`_ShareRow` 字段全部来自服务端列表 DTO，无本地推断。

**结论**：保留。

**改造方案**：无。

### 11. 公开分享页 + 公开 PDF

**现状**：`/report/clinic-summary/:token` 免认证读分享（raw Dio 解信封，`skipAuthorization: true`，2026-08-14 修复生成客户端信封缺陷）；底部 [下载 PDF] 走 `shared/:token/pdf`；错误区分网络错误与链接失效。公开 PDF 用同一过滤视图生成。

**实际作用**：医生/他人打开链接即可查看脱敏摘要或下载 PDF，无需登录。

**真伪判定**：真实现。抽样验证：`clinic_summary_shared.dart` 错误分支区分 `AppErrorKind.network` 与其他；后端 `exportSharedPdf` 复用 `getSharedSummary` 门（撤销/过期即 null → 404）。

**结论**：保留。

**改造方案**：无。

### 12. 就诊摘要占位数据问题（_fillMissingSections）——已修复

**现状（历史）**：Task 8 期间服务端按 `selectedFields` 省略未选 section，但生成客户端 `ClinicSummaryDto` 四 section 键标记必填，客户端曾用 `_fillMissingSections` 补入 `profile:{nickname:'',sexAtBirth:''}`、`allergies:[]`、`conditions:[]`、`currentMedicines:[]`，把「未返回/未选择」伪装成「空数据」，且预览弹窗渲染时以服务端回显 selectedFields 为准，导致「开关选了但显示为空」与「未选字段显示空列表」双重的语义混乱。

**现状（2026-08-14 合同债收口）**：Lucent 将四键改为可选并重新导出 openapi（`clinic_summary_dto.dart` 四字段 `required: false`、类型可空）；客户端删除 `_fillMissingSections` 及其两处调用（preview 与公开分享 raw-Dio 路径），解信封后直接反序列化，未选 section 为 null；`ClinicSummaryContent` 改为「字段选中 && 数据非空」双门控，null section 渲染为空、不崩溃。

**代码验证**：全库 grep `_fillMissingSections` 零命中（lib/ 与 test/ 均无）；生成 DTO 四键 `required: false`；content widget 对 `profile == null` 等空值直接跳过渲染。迁移日志 2026-08-14 两条目（合同债同步 + 移除占位反序列化）与 Active_UI_Report.md 第 70/82 行一致。

**真伪判定**：该假实现**历史上真实存在，当前代码中已确认不存在**。

**结论**：已修复。保留修复后的诚实语义。

**改造方案**：无（维持现状；后续若重开字段选择，必须以「未选 = 字段不存在」为契约，禁止任何默认值补齐）。

### 13. 就诊摘要测量

**现状**：preview 在服务端响应边界上报 `visit_summary_previewed`（每次对话框呈现一条，riverpod 自动重试不重复计数，失败计 failure 不计 previewed）；PDF 下载按 `PdfDownloadResult` 上报 `visit_summary_exported`（empty/failed → failure）；分享由服务端 share_created/opened/revoked 记录，客户端不上报（分享打开按每次成功公开读取计数）。More sheet 的 PDF/打印导出在 `handleReportExportAction` 按请求真实状态收敛（HTTP 成功但 idle/failed/unavailable 记 failure，requested/processing/completed 才记 success）。

**真伪判定**：真实现。抽样验证：`clinic_summary_preview_dialog.dart` 的 `_previewMeasured` 标志 + `ref.listen` 边界；`export_actions.dart` 的 `dataExportUiStatusForRequest` 收敛分支；服务端 `getSharedSummary` 每次成功读发一条 `visit_summary_share_opened`。

**结论**：保留。

**改造方案**：无。

### 14. AI 周报/月报生成（SSE 流）

**现状**：`POST /reports/summary/generate/stream`（SSE：summary 增量事件 + result/done/error）由 `BaseLlmSummaryService` 编排：user setting 开关（关闭 → 403）→ dashboard facts + computation → context → LLM 结构化生成（JSON schema `reportSummarySchema`）→ safety policy 校验 → 持久化到历史摘要；无分析模型/策略拒绝/生成失败时走本地化模板 fallback（`copy.service.ts`），不返回空。客户端 `LucentSseClient` 消费流（`reconnect` 自动重连、`receiveTimeout: zero`）。

**实际作用**：手动触发的周/月 AI 总结，仅存在于 legacy 兼容页（More → 历史报告）。

**真伪判定**：真实现（链路真实）。但注意其消费面：主路径 `/report` 已完全移除 AI 摘要，`summary/generate`（非流式）、`summary/generate/async` + `status` 三个端点客户端零消费（仅 `generateStream` 被 legacy 页使用）；`ai_summary_remote.dart` 的非流式 `generate()` 方法是客户端死代码。

**结论**：改造——保留 SSE + BullMQ + LLM 基础设施，换新 prompt 与输入口径，改造为「周/月纵向洞察生成器」：只输出有来源和覆盖率的模式与低风险动作，证据不足弃权，不生成泛化长文（泛化输出形态与数据语义不可信，不代表周/月纵向理解退出产品）。

**改造方案**：
- P1：`summary/generate/stream` 链路保留，换新 prompt 与输入口径：输出固定为时间范围、覆盖率、有来源的已观察模式（最多一个）与低风险行动（最多一个），允许用户反馈；无足够数据时直接弃权，不生成泛化长文。
- P1：客户端删除 `ai_summary_remote.dart` 非流式 `generate()`（死代码，调用方为零）。
- P1：纵向洞察生成器装配到 Review 的日/周/月视图（与 #19 legacy dashboard 改造联动）；事件回顾作为专题嵌入，不再统领全部周/月内容。
- P2：legacy 页上的旧 AI 摘要装配随 #19 改造一并处理（`summary/generate`、`summary/generate/async` + `status` 等零消费端点下线或降级为不暴露）。

### 15. AI 周报无事件/数据不足防护——已消除

**现状**：两个层面均已堵住：
- 主路径：Review 页**没有任何** AI 周报入口与生成逻辑，无事件状态只有「开始观察」入口 + 轻量解释（`review_view.dart` 注释与代码均确认「不生成周报」）。
- legacy 页：`_readinessStatus()` 仅当指标非空、score 非 insufficient、无 insufficient 指标时才为 ready；`_PrimaryAction` 在 insufficient 状态显示「继续记录」而非「生成总结」，ready 才显示生成按钮。后端 prompt 显式约束「Use only the supplied JSON facts / Do not invent missing data / If data is missing, say that the summary is limited by missing records」。

**实际作用**：杜绝「数据不足仍产出泛化周报」这一假实现路径。

**真伪判定**：已消除。抽样验证：`readiness.dart` 三态主按钮映射（signedOut→登录 / insufficient→继续记录 / ready→生成总结）；`dashboard_view.dart` `canShowFullReport = readiness == ready`；主路径 Review 四段内容全部来自事件事实，无 LLM 参与。

**注意**：后端 `summary/generate*` 端点本身没有服务端「数据不足拒绝」守卫（客户端 gate 是唯一防线），直接调 API 仍可对空数据生成（prompt 要求自述数据有限）。属低风险残留，随 legacy 页改造为纵向洞察生成器后自然消失。

**结论**：已修复。

**改造方案**：P2（随 legacy 改造为纵向洞察生成器时一并处理）；建议服务端对全 insufficient 请求返回 409/空结果以双保险。

### 16. AI 摘要用户开关

**现状**：`aiSummariesEnabled` user setting：客户端 controller `build()`/`generate()` 双重检查（disabled 状态卡片）；后端 `assertAiSummariesEnabled` 读 `userSetting`，false → 403。

**真伪判定**：真实现（前后端双保险，非客户端自欺）。

**结论**：保留。

### 17. 月度 / 打印 PDF 导出

**现状**：More → PDF（月度）/ 打印下载：登录门槛 → security elevation（PIN 验证，`@UseGuards(SecurityElevationGuard)` 服务端强制）→ `POST /data-export-requests`（createRequest 落库 → BullMQ 队列或 inline fallback → `DataExportProcessorService` 取 dashboard 真实聚合 → `ReportExportPdfService` 按 kind 构建医院/月度/打印 PDF → COS 上传 → 状态 completed + 通知）→ 客户端按状态 toast（requested/processing/completed/failed/unavailable 五态）。未配置存储时落 `unavailable` 状态并给出明确错误信息。

**实际作用**：真实生成 PDF 文件（异步、可轮询、失败可查），非「点击即成功」的假导出。

**真伪判定**：真实现。抽样验证：`processor.service.ts` 完整状态机（requested → processing → completed/failed + errorMessage）；`export.service.ts` 队列不可用走 inline 处理兜底，杜绝丢任务；`export_actions.dart` 对 idle/failed/unavailable 显示失败 toast 而不是假装成功。

**结论**：保留。

**改造方案**：
- P2：导出生命周期刻意轻量（无页内历史列表、无重试队列）与产品定位一致（次级出口），保留现状即可；`Mock_Or_Deferred.md` 中「clinic share link 无应用内链接管理，只能重新生成」已过时（分享管理已上线），建议文档更新（P2 文档维护）。

### 18. 导出成功 ≠ 医生查看/获益——已消除

**现状**：三处口径均已收敛：
- 分享按钮文案「分享摘要 / Share summary」（原「分享给医生」），入口文案「就诊时按需使用 / Use as needed during your visit」，创建确认步骤明示「链接持有者可查看」与 7 天有效期，不暗示医生已收到。
- 分享访问数由服务端 share_opened 事件如实记录，客户端不臆测「医生看过」。
- 导出测量按请求真实状态收敛（见 #13），HTTP 成功但请求实际失败时计 failure。

**真伪判定**：已消除。抽样验证：`_ShareConfirmPanel` 文案 + `reportShareConfirmExpiryHint(7)` / `reportShareConfirmNotice`；`clinic_summary_preview_dialog.dart` 分享创建成功只给链接复制/撤销，无「已通知医生」类反馈。

**结论**：已修复。

**改造方案**：无。

### 19. Legacy dashboard 兼容页（/report/legacy）

**现状**：More → 历史报告进入 `LegacyDashboardCompatPage`（readiness 首卡 + 趋势/发现/建议历史 + AI 总结/规律 + 四张导出卡 + 7/30 切换 + 下拉刷新 + 未登录 preview），共享 `handleReportExportAction`。`dashboard_view.dart`、sections、`top_bar.dart` 等带 LEGACY 标注保留未删，仅经兼容页可达。

**实际作用**：为仍依赖旧周报视图的用户提供过渡入口。

**真伪判定**：真实现（计划内保留，`Active_UI_Report.md` Task 10 明确「删除评估留待兼容期结束」）。

**结论**：改造——聚合计算逻辑保留（真实数据），重新装配为 Review 日/周/月纵向洞察视图：事实 / 覆盖率 / 一个模式 / 一个动作；「综合评分」输出去掉，代之以单维趋势 + 覆盖率展示。

**改造方案**：
- P2：`legacy_dashboard_compat.dart`、`dashboard_view.dart` 与 legacy sections 不删除，重新装配为 Review 的日/周/月纵向洞察视图（聚合计算逻辑保留，`top_bar.dart` 范围切换改造为日/周/月切换）；「综合评分」输出移除，代之以单维趋势 + 覆盖率展示。
- P2：路由 `/report/legacy` 与 domain 侧 `dashboard.dart` 实体/mapper 视装配进度迁移（注意 #17 的 PDF 生成仍依赖 dashboard 聚合数据，迁移前需确认 data-export 的 PDF 数据源替代方案）。
- P2：客户端 domain 层保留 `ReportDashboard` 与否取决于 data-export 是否迁移到 event-review 口径；若 PDF 未来改为事件口径，dashboard 整套可连同后端一并下线。

### 20. 综合健康评分

**现状**：主路径已移除（`ReportScoreHero` 不再装配，测试断言无 `report-score-hero`）；但后端 `ReportsPresenterService.buildScore` 仍在计算（good=35 / stable=25 / needs_attention=15 / insufficient_data=18 硬编码权重，注意 `insufficient_data` 得分高于 `needs_attention` 这一明显怪异），legacy 页 readiness 描述区仍展示 `scoreSummary` 一句话。

**实际作用**：仅 legacy 页可见的一句话评分结论。

**真伪判定**：真实现但属「跨维度综合评分替代事实」模式的残留——产品愿景明确「综合健康评分退出产品方向」（`Product_Vision.md`：评分不透明、0 分 preview 无信息价值），主路径已遵守，legacy 未清。

**结论**：改造为「洞察对象」而非分数——覆盖率 + 单维趋势方向 + 值得关注的模式，不合成总分；单维趋势在手机端看，未来在桌面/Web 大屏做更清晰比较。新实现必须使用 `observedMetric` 或等价覆盖率模型，unknown 日不绘点也不补 0。

**改造方案**：P2 移除后端 `buildScore` 及 dashboard DTO 的 score 字段的总分输出，代之以「洞察对象」（覆盖率 + 单维趋势方向 + 值得关注的模式，不合成总分）；改造前确认 data-export PDF 无 score 依赖（医院 PDF 是否含评分需核对 `report-pdf/pdf.service.ts`，若含则 PDF 也随之改版）。

### 21. 健康趋势/统计图表（legacy）

**现状**：legacy 页 fl_chart 单指标折线（用药/饮水/睡眠 tab 切换）+ 指标卡 sparkline。数据为真实聚合（`ReportsContextService` 按天聚合 dose logs / daily records），但**兼容 scalar 序列存在 unknown→0 映射**：`context.service.ts` 的 `medicationSeries` / `waterSeries` 对 `value == null` 的 unknown 天填 0（文档称「兼容序列保留 sufficient observed 值、排除 unknown/partial」，实际代码对 unknown 天仍投影 0——两条目口径不完全一致）；客户端 legacy mapper `_mapDirection` 未知→flat（伪装「持平」）、`_mapDataKind` 未知→general。主路径 Review 不受影响（趋势仅存在于 legacy）。

**实际作用**：legacy 周报视图的图表，unknown 天在图上表现为 0 值点。

**真伪判定**：部分实现——数据真实，但 unknown→0 的投影使图表可能误导（缺失日显示为 0 而非空），属「unknown 映射 0/持平」模式在 legacy 路径的残留（客户端 `dashboard.dart` 注释已声明「legacy scalar 主字段保留至 observed metric 迁移」）。

**结论**：改造——采用 observedMetric 口径：unknown 天不绘点、只绘已记录数据，补覆盖率标注。

**改造方案**：P2 将 legacy 图表改按 `observedMetric`（客户端 domain 已保留字段）口径输出：unknown 天不绘点、只绘已记录数据，并在图表旁直接显示“有记录 N 天 / 范围 M 天”覆盖率标注；废除 unknown→0 投影（服务端兼容序列）与 unknown→flat/general（客户端 mapper）两处口径。

### 22. 建议历史回顾（legacy）

**现状**：legacy 页 `suggestionHistoryProvider`（`/today/suggestions/history`）+ 客户端按 title|reason|type 去重取最高生命周期状态 + 点击弹详情面板（类型图标/生命周期 Badge/规则 meta/置信度/反馈）。

**真伪判定**：真实现（数据源为真实历史 API）。仅 legacy 页消费，随 legacy 改造一并移入 Review。

**结论**：改造——改造为 Review「建议历史」详情视图（建议生命周期状态已真实存在）。

**改造方案**：P2 将建议历史从 legacy 页移入 Review，作为「建议历史」详情视图：数据源为真实历史 API（`/today/suggestions/history`），保留按 title|reason|type 去重取最高生命周期状态与详情面板（类型图标/生命周期 Badge/规则 meta/置信度/反馈）。

---

## 假实现模式核查结论（任务指定五项）

| 模式 | 核查结果 |
|------|---------|
| 就诊摘要占位数据（_fillMissingSections 伪装缺失字段） | **历史存在，当前已修复**。2026-08-14 合同债收口：服务端四键改可选 + 客户端删 `_fillMissingSections`（全库零命中）、双门控渲染、测试断言「缺 section → null 不抛」。当前代码为诚实实现 |
| 无事件强行生成泛化 AI 周报 | **主路径已确认不存在**（Review 无周报生成逻辑，无事件只给入口）；legacy 页 AI 摘要被 readiness==ready 门控 + prompt 约束不虚构。后端端点缺服务端守卫为低风险残留 |
| 导出请求成功等同医生查看/用户获益 | **已消除**：文案「分享摘要/按需使用」不暗示已收到；测量按请求真实状态收敛；分享访问由服务端计数 |
| 跨维度综合评分替代事实 | **主路径已移除**（评分 hero 不装配、测试锁定）；仅 legacy 页与后端残留（含 insufficient 得 18 分高于 needs_attention 15 分的权重缺陷） |
| unknown 映射 0/空列表/「需关注」 | **Review 主路径已彻底修复**（显式 unknown 成员 + reasonCode + 「方向未知」文案）；legacy dashboard scalar 路径仍存在 unknown→0（服务端兼容序列）与 unknown→flat/general（客户端 mapper），随 legacy 改造为 observedMetric 口径（#21）一并修正 |

## 其他核查

- **死代码**：`ai_summary_remote.dart` 非流式 `generate()`（零调用）；后端 `summary/generate`、`summary/generate/async`、`status`、`clinic-summary/export/async`、`status` 端点客户端零消费（仅 stream 与 preview/pdf 被用）；`summary.service.ts` 的旧 Redis `createShareLink` 保留为 legacy 缓存桥（控制器不再调用，注释声明待 Task 10 清理——实际未清理，属计划内遗留）。
- **静态数据冒充动态**：未发现。`ReportDashboard.signedOut()` 与 `dashboard_preview.dart` 的 mock 趋势仅用于未登录 preview 且文件头明确标注「preview only」，属设计语义。
- **点击代替真实保存**：未发现。分享创建/撤销、check-in、结束、导出、字段切换重拉 preview 全部走真实 API 且带失败反馈。
- **文档漂移**：`Mock_Or_Deferred.md`「clinic share link 无应用内链接管理，只能重新生成」已过时（Task 8 分享管理已上线，含撤销）；`Active_UI_Report.md` 顶部对 legacy scalar 的描述与 `context.service.ts` 实际 unknown→0 投影口径不完全一致。
- **红色风险提示（red flags）**：文档化限制——red flag 为用户级静态检查结果、不与事件药物对齐；next-step 渲染为结构化 warning 色调展示，无泛化建议文案，可接受。

## 后端投入错配判断

Lucent reports 模块存在明显超过 C 端消费面的投入：

1. **Dashboard 全套**（`dashboard/context.service.ts` + `computation.service.ts` + `presenter.service.ts` + `ai-summary/` 全套 + `prompts/` + `schemas/` + SSE 端点 + BullMQ 队列）——约 2000+ 行核心逻辑 + 大量 spec，**当前仅被 `/report/legacy` 兼容页消费**，而该页正按纵向洞察方向改造（见 #19）。data-export 的 PDF 生成依赖 dashboard 聚合，是 dashboard 存续的唯一真实理由。
2. **未消费端点**：`summary/generate`（非流式）、`summary/generate/async` + `status`、`clinic-summary/export/async` + `status`（队列 + 轮询全链路，移动端全部未用——客户端 PDF 走 `preview/pdf` POST 直下，导出走 `/data-export-requests`）。异步队列基础设施（`summary-queue.service.ts` / `pdf-queue.service.ts`）对当前唯一客户端是冗余投入。
3. **建议**：将 legacy dashboard 聚合逻辑保留并重新装配为纵向洞察视图（#19），删除泛化 AI-summary 消费面与未消费端点；先把 data-export 所需事实聚合迁移到 event-review/observed metric，再裁剪后端。新的纵向洞察服务应消费统一覆盖率与时间范围事实，不继承 legacy 的综合评分、unknown→0 或泛化长文生成。**先做客户端死代码清理与数据契约拆分，再评估后端裁剪，避免先砍后端影响导出。**

## 模块级结论（价值判断与整体改造建议）

**价值判断**：当前事件 Review + 就诊摘要 + 分享管理 + 导出是**本仓库质量最高、假实现最少的模块之一**，应作为健康事件专题保留。但把全部报告能力收缩成事件回顾，同样不符合长期健康伙伴定位：用户还需要在非生病期间看懂一周和一个月的睡眠、饮水、餐食、心情与建议变化。旧 dashboard 的综合评分、unknown→0 和泛化 AI 周报按新产品方向改造为纵向洞察口径（覆盖率 + 单维趋势 + 模式 + 一个动作）；纵向洞察要基于真实覆盖率重装配，而不是恢复旧页面。

**遗留问题**（按优先级）：
- P1：回顾历史无翻页 UI（超过 20 条事件不可达）；
- P1：就诊摘要六字段选择中饮水/睡眠/备注三开关无实际内容门控，界面承诺与真实行为不一致（推荐裁剪为三有效开关或如实注明）；
- P1：定义日/周/月纵向洞察的事实契约与覆盖率展示，不复用 legacy 泛化 AI 报告；
- P2：legacy 兼容页改造为纵向洞察（#19-#22：dashboard 视图重装配 + 评分改洞察对象 + scalar 改 observedMetric + AI 周报改洞察生成器），清理客户端死代码（非流式 generate）与后端未消费端点；
- P2：文档漂移更新（Mock_Or_Deferred 分享管理条目、legacy scalar 口径）。

**整体建议**：保留事件专题主路径；优先修隐私门控与历史可达性，同时建立纵向洞察的新契约；将 legacy 改造为纵向洞察排入 0.1.0 发布后的首个版本窗口，并以此为契机完成后端 reports 模块的消费面对齐。
