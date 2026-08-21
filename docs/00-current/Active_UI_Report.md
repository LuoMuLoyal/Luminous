---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-21
---

# Active UI — Report

Last updated: 2026-08-21（增量审查修复：review_history _pendingCursor 重置 + build 副作用移至 lifecycle + review_detail l10n null guard + lucent_ai_summary 未知枚举映射日志 + clinic_summary _sectionSelected 一致性）

Lucent Report dashboard 的服务端水量源已统一为整数 ml 的 observed metric，并继续提供由该 metric 派生的旧升数序列；该兼容序列保留 sufficient observed 值（包括 0 ml），排除 unknown/partial。Lucent 合同与 generated client 已提供 `ReportMetricDto.observedMetric`，Luminous Report domain 保留该字段；但当前 mapper 仍以 legacy `dto.value` / `dto.unit` / `dto.status` 填充主字段，仅附加映射 `observedMetric`，Flutter UI 也仍以 legacy scalar 为主要展示路径。

## Review 领域层（已实现）

- 新增 `EventReview` 领域实体与 `ReviewRepository` 接口（current / history / detail），实现为 `LucentReviewRepository`，映射 Lucent event review read model：`GET /api/v1/user/reports/reviews/current`（无事件返回空信封 null，不是 404）、`GET .../reviews`（status/cursor/limit 分页）、`GET .../reviews/{eventId}`（foreign 404）。
- 实体保留契约语义：四个 section 各自 available/unknown；unknown 段的 reasonCode 已知码按原文保留，未知码在生成 DTO 反序列化层被折叠为 `unknown_default_open_api` 占位符；coverage 的 state/coverage/sources 未知值映射为显式 `unknown` 成员而非空列表或 0；available actions 保留客户端可渲染项。
- 展示层 provider：`reviewCurrentProvider`（keepAlive，优先 active 事件）、`reviewHistoryProvider`（缓存第一页，watch `reviewHistoryStatusProvider` 按 status 过滤重建重取）、`reviewDetailProvider`（autoDispose family，按事件 ID 隔离）与 `reviewLastCurrentProvider`（通过 `ref.listen` 只采纳被接受的 AsyncData，失败时保留最后一次成功数据，登出/会话失效的 null 数据会清空缓存；`ref.invalidate` 即重试）。
- 自动刷新覆盖：`reviewCurrentProvider` watch `dailyRecords` / `doseLogs` / `healthEvents` 三个 `DataChangeTopic`；`reviewHistoryProvider` watch `healthEvents`。health_event 的 create / end（含 outcome 确认）/ checkIn 在服务端确认成功后发射 `healthEvents`。
- Task 6 起 `/report` 主内容切换为事件优先的 `ReviewView`（见下节）；Task 7 起旧 dashboard 主路径引用移除并收尾：`dashboard_view.dart`、sections、`top_bar.dart`（7/30 天范围切换）等 legacy 文件保留代码但不再从 `page.dart` 装配，文件头已加 LEGACY 标注；Task 8 已把导出/就诊摘要迁入 More（见「Review More 入口」节），旧 dashboard 仅经 `/report/legacy` 兼容页可达，删除评估留待兼容期结束（`skeleton_view.dart` 仍被 ReviewView 的骨架屏复用，非 legacy）。

## Review 事件优先视图（Task 6，主内容已切换）

- `/report` 页面装配 `ReviewView`（`presentation/widgets/views/review_view.dart`）：事件头部 + 四段（发生了什么 / 有什么变化 / 完成了什么 / 接下来怎么办）+ 事件历史，移动端约束布局，不新增桌面专属 breakpoint 或 sidebar 对等实现（桌面与移动端同一布局）。
- 事件头部：active 事件显示「进行中」与今日 check-in（`coverage.checkIns.todayCheckIn` 为空且 `availableActions` 含 check-in 时），同时保留「结束观察」入口；ended 事件显示用户确认的 outcome，无 check-in。check-in / 结束 / 开始观察均复用 health_event 的 bottom sheet 与 `ActiveHealthEvent` notifier。
- 四段按 fixed 顺序渲染；每段独立 available/unknown：unknown 段显示 reasonCode 本地化的简短缺失原因（`no_observations` / `insufficient_coverage` / `no_completed_actions`，未知码折叠为通用文案），不显示 0 分或红色「需关注」状态。fact code：`health_event` / `observed_changes` / `completed_actions` / `active_check_in` / `event_ended`；数值趋势 direction 缺失/未知时如实显示「方向未知」而不伪装「持平」；用药安全提醒（`redFlags`）以 warning 色调结构化展示，无泛化建议文案。
- 历史：`reviewHistoryProvider` 第一页按事件逐条列出（最近在前），不按月份分组；提供 status 轻量筛选（全部 / 进行中 / 已结束，`reviewHistoryStatusProvider` 驱动重新拉取），**时间范围不是 review list 合同的一部分**（合同只有 status/cursor/limit，旧 dashboard 的 7/30 天切换保留在 legacy 文件、不进主路径）。加载失败只在卡片内显示一行提示 + 轻量 inline 重试（invalidate history provider），不阻塞首屏；筛选切换重取时沿用旧数据不闪骨架（`skipLoadingOnRefresh`）。完成动作段落内的 check-in 日期与 header/history 一致经 `reviewShortDateLabel` 本地化。当首页 `nextCursor` 非空时，卡片底部渲染「加载更多」按钮；点击后通过 `onLoadMore` 回调调用 `reviewRepositoryProvider.fetchHistory(status, cursor)` 请求下一页，追加渲染并防重入；筛选切换或 DataChangeBus 刷新重取首页时自动重置累积列表。
- 无事件：显示「开始健康观察」入口 + 最近事件历史；完全没有事件时给轻量解释，不自动生成周报。未登录 preview 显示 `SignInHintBanner`，隐藏开始入口。
- 「开始观察」已与 today 对齐：预读 health context snapshot 的当前用药选项与按用户时区当天解析的症状记录选项，随创建请求转发 `reasonRecordId` / `currentMedicineIds`；选项加载失败静默降级为空列表，不阻塞开始观察。创建成功后由 DataChangeBus 自动刷新 review。
- 状态处理：首载 loading 显示骨架屏；刷新失败但 `reviewLastCurrentProvider` 有数据时继续渲染旧数据 + 轻量 stale 提示条；无缓存的错误显示 `StateErrorView` + 重试。
- 主路径回归约束（测试锁定）：不构建 `ReportExportSection` / `ReportReadinessSection`（`canShowFullReport` 整页锁所在）；顶栏无 7/30 天范围切换（`ReportTopBar` / `ReportRangeMenu` 仅 legacy 文件）；旧 `reportDashboardProvider` 失败不阻塞 review 渲染。
- 文案全部走 `report*` l10n 分片（zh/en 齐全），旧 `reportExport*`、诊所摘要等文案保持 Report 口径（Task 8 已将入口移入 More，见「Review More 入口」节）。

## Review More 入口（Task 8，导出与就诊摘要已迁入）

- `/report` 顶栏右上角新增「更多」按钮（`_ReviewTopBar` 的 `review-more-action`，tooltip 更多），打开 `showReportMoreActionsSheet`（`presentation/widgets/sheets/more_actions.dart`）：四项入口——就诊摘要（走 `handleReportExportAction` 的 clinicShare 分支打开诊所摘要预览弹窗）、PDF（月度 PDF 导出）、打印/下载（打印 PDF 导出）、历史报告（push `/report/legacy` legacy 兼容页）；移动端 bottom sheet、桌面端 dialog，入口点击先关 sheet 再触发流程。
- 导出/分享行为与旧 dashboard 装配一致（共享 `presentation/utils/export_actions.dart` 的 `handleReportExportAction`）：登录门槛 → clinicShare 预览 → security elevation（PIN 验证）→ dataExport POST → 下载链接/状态 toast；不改变任何后端 API 调用与数据流。
- Task 8（Visit Summary and Product Measurement）起 More 为五入口：就诊摘要 / 分享管理 / PDF 报告 / 打印下载 / 历史报告。分享管理（`showShareManagementSheet`）列出当前用户的分享记录（创建时间/到期时间/访问次数/最近访问/已撤销态）并提供撤销，不展示任何访问者身份信息。
- 就诊摘要预览弹窗（Task 8 字段级隐私）：六项字段选择（事件概况/症状变化/用药槽位/饮水/睡眠/备注），默认不选自由文本备注；六个开关全部真实生效（R-2）——`event_overview` 门控 profile + findings；`symptom_changes` 门控 conditions；`medication_slots` 门控 currentMedicines；`water` 门控 coverage.water + 逐日饮水事实；`sleep` 门控 coverage.sleep + 逐日睡眠事实；`notes` 门控自由文本备注记录（默认关闭）。未选字段不出现在 preview 请求、PDF 与分享中（服务端 `applySelectedFields` 单一过滤出口，preview/PDF/share 三路径共用）。选择 notes 时分享确认步骤额外显示「持有链接者可查看备注原文」隐私警告。分享创建前显示 7 天有效期与「链接持有者可查看」，创建后可复制链接或撤销，不暗示医生已收到。preview 与 share-create 已随信封契约修复（2026-08-15）改用生成客户端（`reportsControllerPreviewClinicSummaryV1` / `reportsControllerShareClinicSummaryV1`），见「2026-08-15 — Clinic Summary 分享/预览走生成客户端」节。
- 过敏记录不是六个可选字段之一，按元数据处理：服务端 `resolveSectionKeys` 恒包含 `allergies`，内容组件对过敏段「非空即渲染」（不受字段选择门控）；`coverage.checkIns` 和 `coverage.dose` 同样始终包含（非可选）。
- 分享管理列表为 keepAlive 缓存：预览弹窗内创建分享成功会失效该缓存，打开面板即见新分享；字段选择在分享已创建/已撤销步骤锁定（确认步骤仍可切换，影响正在创建的分享）。
- 文案口径：就诊摘要入口「就诊时按需使用 / Use as needed during your visit」，不暗示医生一定查看；分享按钮文案由「分享给医生/Share with doctor」改为「分享摘要/Share summary」（分享仍是用户显式动作，API 行为不变）。
- 主路径回归（测试锁定）：首屏不渲染四张导出卡与 `ReportExportSection`，顶栏无 7/30 切换（`test/report/widgets/more_actions_test.dart` 10 个用例 + `test/report/page_test.dart` 既有断言）。
- Legacy 兼容页 `LegacyDashboardCompatPage`（`presentation/pages/legacy_dashboard_compat.dart`，路由 `/report/legacy`，slide 进入、含返回按钮）：按 d8c9c5f5e 旧装配重建移动端 dashboard（readiness 首卡 + 趋势/发现/建议历史 + AI 总结/规律 + 四张导出卡 + 7/30 天切换 + 下拉刷新），沿用 `/report` 的公开预览语义（未登录显示 preview + 登录引导）；取舍：不复刻旧桌面端双栏外壳，桌面宽度渲染同一移动端布局。旧 dashboard 文件保留原样未删除。

## Review 视觉/无障碍/状态验证（Task 9）

- a11y 语义顺序（TalkBack/VoiceOver）锁定为：事件标题 → 状态/结果 → 四段 → 历史 → More。
  - 事件头部卡片顺序调整：事件标题在最前，状态/结果 chip 行在其下（此前 chip 在标题上方，屏幕阅读器会先读状态再读标题）；状态 chip 参与 flex 收缩并单行省略。
  - 顶栏与内容区加 `Semantics(container: true, sortKey: OrdinalSortKey(1/0))`：只调整语义遍历顺序（正文先读、顶栏后读），不影响视觉布局、焦点顺序与点击命中；「更多」按钮加 `semanticsLabel`（此前是空 label 的图标按钮）。
  - 全宽动作按钮（check-in / 开始观察）与用药安全提醒标题行修复 en 长文案横向溢出（Forui 按钮内容 Row 对非 flex 子项给无界宽度，label 由 `widgets/shared/constrained_action_button.dart` 限宽换行/省略）。
  - 语义顺序由 `test/report/widgets/review_semantics_test.dart`（5 用例）按语义树遍历顺序断言；页面级断言用「遍历顺序拼接的文本流」做子串位置检查——ListView 会把整段正文文本合并进一个语义节点（label 换行拼接），该合并是滚动视图既有语义行为。
- golden 视觉基线：`test/report/goldens/review_{active|ended|partial|no_event}_zh_light.png` 四张（视口 390 宽、内容高度随状态裁剪：active/ended/partial 为 390x844、no_event 为 390x517；zh + light + 常规字体），由 `test/report/review_golden_test.dart` 生成并锁定；应用未打包自定义字体，golden 使用 Flutter 测试默认字体，中文以占位方块呈现，布局结构完全确定。每张 golden 与全部矩阵用例断言无综合分数（`report-score-hero`）、无整页 readiness 锁（`report-readiness-card`）、无默认导出矩阵（`report-export-section`）。
- 矩阵 widget 测试（不生成 golden）：zh/en、dark、大字体（2x textScaler）各跑一遍四状态 + 大字体超长标题组合，断言 `takeException() == null`（溢出即失败）。
- 集成流程（离线/mock，Windows 桌面设备实跑 11 用例全绿）：`integration_test/report/report_e2e_test.dart` 重写为 ReviewView 断言（六状态核心路径 + More 四入口 sheet + Tab 往返保状态）；`shell_navigation_e2e_test.dart` 报告 Tab 断言改为 `review-no-event-card`；新增 `review_closed_loop_e2e_test.dart`——共享内存事实源（`E2eHealthEventLoopStore`）打通 HealthEventRepository 与 ReviewRepository，闭环：开始事件 → Record 写症状 → Medicine 确认槽位（`medicine-plan-dose-action-*`，桌面同样渲染剂量确认卡片）→ Review 看到更新（DataChangeBus 自动刷新）→ 结束并确认结果（Review 自动刷新为无事件 + 历史出现「好转」）。
  - Record 时间线 badge 桌面溢出修复（6.4px，阻断桌面 e2e）：badge 外层 `Flexible` + 内层文案 `Flexible` + 省略号，随本任务提交。
  - 环境限制：桌面窗口下 Today 健康事件卡片为移动布局专属（桌面未做功能对等），「开始事件」走 Review 无事件卡同一入口（同 StartEventSheet + ActiveHealthEvent notifier + DataChangeBus 链路）；`tester.view.physicalSize` 缩到手机宽度触发 riverpod 3.3.1 的 `UncontrolledProviderScope` setState-during-build 竞态（TickerMode 重建期间 subscription resume → 同步 invalidate），本环境无法以移动视口运行 e2e（见迁移日志，未伪造运行结果）。
  - 质量审查修复（2026-08-13）：e2e 剂量 fake 补 `fetchForDate` override（mark 后 `_refreshCache` 不再走真实 HTTP，消除幻影 pending-sync 与失败 toast 噪声）；`constrained_action_button.dart` 横向 padding 用命名常量 `_kContentPadding = 24`（Forui md/sm contentPadding 12+12，原用 Spacing.level6=28 多扣 4px）并注明无界宽度回退分支前置条件；语义测试 chip 断言加强为首个「进行中」节点必须非按钮。

## Review 收口（Task 10，全量验证与状态定稿）

- 第五 Tab 用户任务为 **Review（回顾）**：底部导航/侧栏标签与页内文案均为「回顾/Review」；`/report` 路由路径、`features/report` 目录、`ShellTab.report` 枚举与 telemetry key 保留不动，**`/report` 是兼容路由**（深链与既有行为不变），代码层重命名留待兼容期结束后评估。
- **桌面/Web 未做功能对等**：ReviewView 与 legacy 兼容页均为移动端约束布局，桌面窗口渲染同一布局，不新增桌面专属 breakpoint/sidebar；完整认证 Web 与桌面端保持冻结，不继续功能对等、发行或产品化。
- **旧 dashboard 代码尚未删除**：`dashboard_view.dart` 及 sections、`top_bar.dart` 等 legacy 文件保留原样（文件头带 LEGACY 标注），仅经「更多 → 历史报告」（`/report/legacy` 兼容页）可达；`skeleton_view.dart` 仍被 ReviewView 骨架屏复用，非 legacy。删除评估留待兼容期结束。
- 全量验证（Task 10，2026-08-13）：`dart run scripts/bootstrap_generated_sources.dart`（无生成物漂移）、`flutter analyze`（无问题）、`flutter test` 全量 **3067 passed / 1 skipped**（跳过为既有）、`dart run scripts/run_daily_checks.dart`、`dart run scripts/check_doc_coverage.dart --warning-only`、`dart run scripts/check_doc_links.dart` 全部通过；桌面 e2e（`report_e2e` 6 + `shell_navigation` 4 + `review_closed_loop` 1 = **11 用例**）此前已 `-d windows` 实跑全绿，Task 10 未重复执行（环境为 Windows 桌面，移动视口限制见迁移日志，未伪造运行结果）；`git diff --check` 无空白错误。
- 保留的文档化限制：red flag 为用户级静态检查结果、不与事件药物对齐；`doseLogSources` capped 判定；changes 趋势为首末比较简化口径；`buildCurrent` 双重读取为低优先级遗留项；旧 dashboard 删除评估留待兼容期结束。

## 历史事件详情页（改造项 2，H-6 + H-9，2026-08-18）

- **历史行可点开完整回顾**：`_HistoryEventRow` 包 `FTappable`（`onTap` 为空时保持纯只读行，不包 FTappable，避免禁用态语义合并破坏既有遍历顺序）；`ReviewHistorySection` 新增 `onEventTap` 参数，`ReviewView` 透传，`ReportPage` 装配 `context.push(Routes.reviewDetail.replaceAll(':eventId', event.id))`。
- **新顶层路由 `/report/review/:eventId`**（GoRouter 顶层、slide 过渡、需登录）：`ReportReviewDetailPage`（`presentation/pages/review_detail.dart`）用 `PageScaffold` 外壳 + 复用 `EventHeaderSection`（只读：`showCheckInAction` / `showEndAction` 均为 false，`onCheckIn`/`onEndEvent` 空函数）+ 四段渲染 widgets，接 `reviewDetailProvider(eventId)`（autoDispose family）。loading 复用 `ReportSkeletonView`（放在可滚动容器内，与 Review 首屏骨架一致）；error 用 `StateErrorView` + `ref.invalidate(reviewDetailProvider(eventId))` 重试。
- **触发记录展示（H-9）**：「发生了什么」段在窗口行之后、症状计数之前新增「由记录触发：{title}」行：后端 facts.arguments 恒带 `reasonRecordTitle`（从事件 `reasonRecordId` 经 daily-records reader 解析记录标题，缺失/读取失败为 null、不阻塞回顾），前端 `reviewArgString` 非空才渲染；新 l10n 键 `reportReviewWhatHappenedReasonRecord`。
- **埋点**：详情数据成功呈现后（data 分支首次 build 的 post-frame 回调 + mounted 守卫）调用 `ProductEventService.trackReviewOpened()`；session 去重内置，重建/重试不会重复上报。loading/error 不上报。

## Visit Summary and Product Measurement 收口（Workstream 2 Task 10）

- **公开分享页信封兼容修复**：`clinicSummarySharedProvider` 改走生成客户端 `reportsControllerGetSharedClinicSummaryV1`（保留 `skipAuthorization: true`，与公开 PDF 一致）并校验信封，与 preview provider 同一模式；四个 section 键已随响应合同改可选（2026-08-14 合同债收口），未选 section 反序列化为 null，`_fillMissingSections` 占位补齐已删除；provider 测试改写为同一 scripted-adapter harness（信封解包、缺 section 容忍、per-token 缓存、错误传播 4 条）。
- **漏斗合同模型同步**：bootstrap 脚本 `_productEventsModels` 补全 5 个 Funnel schema（`FunnelDailyCountsDto`/`FunnelOptionalCountsDto`/`FunnelTotalsDto`/`FunnelWindowDto`/`FunnelResponseDto`），重新生成后生成包 build_runner 编译通过、两次 bootstrap 无漂移；admin funnel 端点客户端不消费，生成面仅作合同完整性。
- 全量验证（2026-08-14）：`dart run scripts/bootstrap_generated_sources.dart`（两次运行无漂移）、`flutter analyze`（零问题）、`flutter test` 全量 **3119 passed / 1 skipped**（跳过为既有）、`dart run scripts/run_daily_checks.dart`（analyze/format/test/openapi-sync 全过）、`dart run scripts/check_doc_coverage.dart --warning-only`、`dart run scripts/check_doc_links.dart`（137 文件无坏链）全部通过；桌面闭环 e2e（`integration_test/report/review_closed_loop_e2e_test.dart`）`-d windows` 实跑 1 test 通过（移动端实机仍受 Windows 桌面宿主环境限制，未伪造运行结果）；`git diff --check` 无空白错误。
- 产品闭环程序（Workstream 1 + 2）实施完毕，`Luminous/plans/2026-08-07-product-loop-program.md` 与 `2026-08-07-visit-summary-and-product-measurement.md` 已删除（实施完毕文件已删）。

## Sparse Record Semantics 合同

- Lucent 合同边界：`ReportMetricDto.observedMetric` 统一承载 `value`、`state`、`coverage`、`sources`、`observedCount`、`expectedCount`、`windowStart` 和 `windowEnd`；`unknown` 不投影为 `0`。服药 observed metric 以 reminder slot 为计划单位，来源枚举保留 `manual`、`health_platform`、`reminder_plan`、`derived`。
- Luminous Report 消费边界：domain 保留 `observedMetric`，但 mapper 仍以 legacy `dto.value` / `dto.unit` / `dto.status` 为主，仅附加 observed metric；当前趋势和指标卡也仍主要展示 legacy scalar。这个字段保留不代表 Report 已消费完整的 medication contract。
- 睡眠 episode 是 Lucent 后端和 Today collector 的语义；当前 Report 仍消费 legacy sleep scalar，尚未消费完整 sleep episode contract，也不提供 episode 级别的同日记录保留或“不按日期合并”保证。
- 本次客户端合同同步没有改变 Report 页面可见结构、评分/导出/AI 摘要的既有行为；这些仍按本文件顶部的迁移说明和 TODO 管理。

> 本文件继续记录当前已经实现的 `Report` 运行时事实。第五 Tab 用户任务已改为“回顾”，以健康事件为主单位，移除综合健康评分并把导出/医生分享移入“更多”；事件优先 Review 视图已在 Task 6 上线（见上节），导出/医生分享移入 More 与旧 dashboard 兼容页已在 Task 8 上线（见「Review More 入口」节），字段级隐私、可撤销分享与闭环测量在 Workstream 2 收口（见「Visit Summary and Product Measurement 收口」节）；旧 dashboard 代码的删除评估待兼容期结束；clinic summary 四 section 键合同债已解除（响应合同改可选、客户端占位反序列化已移除，见迁移日志同日条目）。

## 页面结构（旧 dashboard，代码保留但已不装配）

> Task 6 起 `/report` 主内容已切换为 ReviewView（见「Review 事件优先视图」节）。Task 7 已收尾主路径：以下 dashboard 页面结构描述的是仍保留在仓库中的 legacy 视图代码（`dashboard_view.dart` 及其 sections、`top_bar.dart` 未删除，文件头带 LEGACY 标注；`skeleton_view.dart` 除外——它仍被 ReviewView 骨架屏复用）。Task 8 起该视图仅经 More → 历史报告（`/report/legacy` 兼容页）可达，删除评估留待兼容期结束。

- Lucent-backed report dashboard，真实 medication / water / sleep 聚合。
- 用户可选范围：`last_7_days` / `last_30_days` / `custom`（Forui `FCalendar.grid` 日期范围选择器）。
- 时间范围选择器使用 Forui `FPopoverMenu`（`ReportRangeMenu`），从右上角 pill 按钮下方弹出，替代旧版底部弹出 bottom sheet。
- 移动端报告页为 readiness-first 状态页：
  - 顶部只保留标题 + 时间范围。
  - 首屏单一 `readiness` 主卡合并登录门槛、数据不足、生成总结、同步、数据更新时间。
  - `generatedAt` 从 Lucent report dashboard DTO 映射到前端 domain，显示"当前显示的数据更新于 …"。
  - 生成总结与同步操作仅在 readiness 主卡内提供，不再在内容区重复 `ReportActionBar`。
  - 时间范围由 Header `ReportRangeMenu` 表达，内容区不再重复日期范围文本。
- 桌面端与移动端对齐到同一现有 Report 布局：顶部移除旧 snapshot 状态块，主内容首块为 `readiness` 主卡。
- 未登录 preview 态：顶部显示与其他 tab 一致的轻量 `SignInHintBanner`；下方用显式空态卡片展示 Report 页职责范围（健康趋势、重点发现、历史建议回顾、导出预览），不再显示巨大的 readiness 锁定卡或灰色空白占位块。
- `历史建议回顾` 数据源从通知接口切换到 `GET /today/suggestions/history` API，展示建议生命周期状态（进行中/已过期/已忽略）和按类型映射的图标。
- 移动端完整层仅在 `已登录 + 数据足够` 时显示：AI 总结、健康模式分析、导出摘要、医疗免责声明。
  - section 顺序：readiness → metrics → trend → findings → suggestionHistory → aiSummary → patterns → export → reference。
  - 导出区移至页面末尾（规律分析之后），引导用户先阅读分析再导出。
  - 各 section 间距统一 `Spacing.level5`。

- 移动端下拉刷新 + readiness 主卡内显式同步操作。

## 评分与指标

- `ReportScoreHero` 已移除（R-4 #20）：健康评分计算不透明，0 分 preview 无信息价值，且产品文档未将评分列为 Report 页核心组件。后端 `buildScore` 及 `ReportDashboardScoreDto` 已同步删除，PDF 评分卡已移除。
- `ReportMetricsGrid` 在移动端和桌面端均渲染，桌面端位于右栏。
- 指标卡 2 列网格，含 sparkline 趋势条、状态徽章、方向箭头。

## 趋势与发现

- 趋势区使用 `fl_chart` 单线折线图 + Forui `FTabs` 指标切换。每个 tab 对应一个指标（用药/饮水/睡眠），选中 tab 时只渲染该指标的单条折线，Y 轴显示真实值（不再归一化），图表上方显示当前值摘要。日期标签从 `dashboard.startDate` 动态生成。
- 桌面端趋势区位于左栏（`showRangePill: false`，范围 pill 由外壳 suffixes 提供），移动端位于指标卡下方。
- findings 卡片为信息展示型（非导航型），已移除装饰性 chevron，桌面端使用 `Wrap` 自动换行排列。
- patterns 卡片同样为信息展示型，已移除装饰性 chevron。

## AI 摘要

- 手动 AI 摘要生成，真实增量流 `/api/v1/user/reports/summary/generate/stream`（通过 `LucentSseClient`）。
- AI 摘要文本使用 `MarkdownBody` 渲染，样式走 `MarkdownStyle.ai(context, paragraphWeight: FontWeight.w700)`（见 [[Design_System#Markdown 渲染]]，2026-08-03 起统一）。
- 本地 signed-out / disabled / loading / success / error AI 摘要状态。
- 卡片内 `近 7 天 / 近 30 天` AI 摘要切换，带按范围缓存状态。
- AI 占位文案使用 l10n 兜底，无硬编码中文。

## 导出动作

四个导出动作已接入：

- `给校医院` — hospital PDF
- `月度报告` — monthly PDF
- `打印预览` — print PDF
- `分享给医生` — clinic share link（Redis 24h TTL + 原生 OS 分享面板）
- 导出卡片显示进行中的进度与有界状态文案；inFlight 时卡片灰化。
- 移动端在未登录或数据不足时不渲染导出卡，只显示轻量锁定说明。
- Mine/Settings 使用同一真实数据导出请求流；隐私设置由 Mine/Settings 持有。

## Clinic Summary（后端隐私保护医疗摘要）

> Task 8（Workstream 2）起：预览弹窗支持六项字段级隐私选择（默认不含自由文本备注），
> 未选字段在 preview/PDF/share 中均不存在；分享改为持久化可撤销记录（7 天有效），
> 创建前显示有效期与「链接持有者可查看」，创建后可复制链接或撤销；More sheet 新增
> 「分享管理」面板（创建/到期/访问次数/最近访问/已撤销态）。以下段落描述的是旧
> Redis 24h TTL 分享链路，保留作历史说明。

用于医生分享的后端侧脱敏摘要：

- `POST /reports/clinic-summary/preview` — 脱敏摘要（姓名 mask 张**、年龄非 birthDate、仅诊断年份）
- `POST /reports/clinic-summary/share` — Redis 分享链接，24h TTL
- `GET /reports/clinic-summary/shared/:token` — 公开访问（无需认证），过期返回 410
- `GET /reports/clinic-summary/preview/pdf` — PDF 下载（需认证），A4 格式，含 profile/allergies/conditions/medicines/disclaimer，CJK 字体渲染
- `GET /reports/clinic-summary/shared/:token/pdf` — 公开 PDF 下载
- `@Public()` 装饰器 + `JwtAuthGuard`（支持 `Reflector` 的混合认证/公开路由）
- 前端 Report 导出区分享按钮点击后先弹出预览弹窗（`ClinicSummaryPreviewDialog`），弹窗内展示脱敏摘要内容 + [下载 PDF] + [分享给医生] 两个操作按钮。
- 预览弹窗桌面端使用 `showFDialog` + `AppDialogShell`，移动端使用 `showModalBottomSheet`。
- PDF 下载通过 Raw Dio（`ResponseType.bytes`）调用 `GET /reports/clinic-summary/preview/pdf`，保存为临时文件后通过 `share_plus` 分享。
- 分享按钮调用 `reportsControllerShareClinicSummaryV1()` 生成 Redis 分享链接，通过 `SharePlus.instance.share` 分享 URL。
- 公开分享页 `/report/clinic-summary/:token` 调用 `GET /reports/clinic-summary/shared/:token` 展示脱敏摘要，底部含 [下载 PDF] 按钮（调用 `shared/:token/pdf`，`skipAuthorization: true`）。
- `ClinicSummaryContent` 共享组件复用于预览弹窗和公开分享页，展示生成时间、数据范围、脱敏个人信息、过敏记录、疾病记录、当前用药、关键发现、免责声明。

## 骨架屏

- 桌面端双栏布局对齐真实页面：左7 `Trend+Findings`，右5 `MetricsGrid+AiSummary+Patterns+ReferenceNotice`；导出区移至双栏之后全宽展示。
- 移动端按真实 section 顺序排列（导出在末尾）。

## 数据层

- 报告相关远程数据源（`ReportRemoteDataSource`、`AiSummaryRemoteDataSource`）通过 `generated/lucent_api` 的 Retrofit 客户端访问 Lucent API。
- DTO 直接返回扁平 DTO（`response.data`），Enum 序列化使用 `.json` 属性。
- AI 摘要增量流通过 `LucentSseClient` + Dio 直接消费 SSE。
- `userMessageFromError` 统一错误文案映射，不暴露内部异常文本。

## 2026-07-19 补充

- 趋势图 Y 轴恢复 `showTitles: true`，显示格式化数值。
- 序列配色区分：sleep 从 info 改为 warning（琥珀），general 从 primary 改为 success（绿），四个 kind 互异。
- `lineTouchData` 开启 touch tooltip，显示触点实际值+单位+日期（`DateFormat.MMMEd(locale)` 格式化）。
- 图表外包 `Semantics` label 包含标题 + 各指标当前值摘要。
- `_LegendDot` 新增 `currentValue` 和 `unit` 参数，图例项带当前值+单位。
- X 轴标签改用 `DateFormat.Md(locale)` 格式化。
- readiness 三态徽章按 status 映射：insufficient 用 `warning`，ready 用 `success`。
- ready 标题按范围参数化（`reportReadinessReadyTitleRange`，`{range}报告已就绪`）。

## 2026-07-19 P2 低级一致性打磨

- `score_hero.dart` 已随 R-4 #20 移除，不再有评分卡相关的 tooltip 或字号 token。
- `trend.dart` 图例色点从 8px 增大为 `Spacing.level3`（10px），提升可识别性。X 轴日期已走 `DateFormat.Md(locale)`，无需改动。
- `suggestion_history.dart` 手写 `DecoratedBox` 徽章改为 `FBadge.raw` + `.delta()` + `shapeDelta` 模式，与项目其他徽章实现一致。
- `report/page.dart` 移除 `isInsufficient: (_) => false` 恒 false 死代码。
- `report/page.dart` 加载副标题从 `placeholderNoData` 改为 `placeholderLoading`（"加载中…"）。

## 2026-07-19 剩余中级项

- 趋势图改为按序列独立归一化到 [0, 1]（Y 轴 [-0.1, 1.1]，去掉数值标签，tooltip 保留原始值+单位），解决不同量纲共用 Y 轴压成平线问题。
- 桌面 loading 外壳移除 `scrollable: false`（使用默认 `true`），矮窗不再溢出。
- 移动端错误态去掉 `AppBackButton`（tab 根页面不应有返回键），改为 `DecoratedBox` + `SafeArea` + `AppStateErrorView`。
- 同步按钮 `isSyncing` 接入 `dashboardAsync.isLoading`（`isRefreshing`），同步进行中显示进度态。
- 桌面 findings 从横向滚动 `Row` 改为 `Wrap` 自动换行。
- `range_picker_dialog` 日历弹窗新增"取消"按钮（ghost 样式 + `Navigator.pop(null)`）。
- 桌面端趋势区传 `showRangePill: false`，避免与 `DesktopTabShell` suffixes pill 重复。

## 2026-07-20 P1 修复

- **切时间范围保留旧值**：新增 `reportLastDashboardProvider` 缓存最近一次成功加载的 dashboard。切换时间范围时，新查询加载期间展示旧数据而非整页骨架，`isRefreshing` 指示器仍正常显示。
- **AI 总结"自定义"范围日期兜底**：`generate()` 在 `range == custom` 但 dashboard 非 custom 时，从缓存的 dashboard 取 `startDate`/`endDate`，不再传 null 日期。
- **桌面 loading 假按钮禁用**：`_buildLoadingShell` 中 `ReportActionBar` 传 `isGenerating: true, isSyncing: true`，加载态按钮不可点击。
- **图表 tooltip 触点值+日期**：tooltip 从恒显示 `currentValue` 改为根据 `spot.spotIndex` 取实际触点值，并新增日期行。
- **图表 Semantics 数值摘要**：`Semantics.label` 从仅标题扩展为包含各指标当前值摘要。

## 2026-07-20 P2 报告模块打磨

- **装饰图标 ExcludeSemantics**：`readiness.dart` 的状态头像图标和时钟图标包裹 `ExcludeSemantics`，避免屏幕阅读器重复朗读相邻文字。
- **就绪卡"生成总结"loading**：`readiness.dart` 的 `_PrimaryAction` ready 状态新增 `isGenerating` 参数，生成中禁用按钮 + 显示 `FCircularProgress`。`dashboard_view.dart` 传入 `isGenerating: aiSummaryState.status == ReportAiSummaryCardStatus.loading`。
- **emptyInsufficientBuilder 死代码删除**：`page.dart` 移除不可达的 `emptyInsufficientBuilder` 分支。
- **R-4 #20 移除综合评分**：`score_hero.dart` 整文件删除，`ReportHealthScore` 实体删除，`ReportReadinessSection.scoreSummary` 参数删除，`_ScoreHeroPlaceholder` 重命名为 `_ReadinessPlaceholder`。
- **导出卡禁用态 chevron 修复**：`export.dart` 的 `_ExportCard` trailing 图标在 `requestInFlight.inFlight` 时显示 `lock` 而非 `chevronRight`，正确表达“其他导出进行中”的禁用语义。

## 2026-07-20 联调修正

- **建议历史详情面板**：新增 `suggestion_history_detail_sheet.dart`，点击历史建议列表项弹出详情（桌面端 `showFDialog` + `AppDialogShell`，移动端 `showModalBottomSheet`）。展示类型图标+标题、生命周期 Badge、原因正文、规则 ID/版本/触发方式/置信度/生成时间 meta 字段、用户反馈（如有）、过期时间（如有）。`page.dart` 的 `onSuggestionTap` 从 `null` 改为调用 `showSuggestionHistoryDetailSheet`。
- **诊所摘要预览弹窗**：新增 `clinic_summary_preview_dialog.dart`，点击"分享给医生"导出按钮时先弹出预览弹窗，展示 `POST /reports/clinic-summary/preview` 返回的 `ClinicSummaryDto` 脱敏内容。弹窗内含 [下载 PDF] 和 [分享给医生] 两个操作按钮。
- **诊所摘要 PDF 下载**：`LucentApiPaths` 新增 `clinicSummaryPreviewPdf` 和 `clinicSummarySharedPdf(token)` 路径常量。通过 Raw Dio 以 `ResponseType.bytes` 下载 PDF 二进制，保存到临时目录后通过 `share_plus` 分享。
- **诊所摘要分享链路改造**：`page.dart` 的 `clinicShare` 导出入口从直接调用 `_handleClinicShare` 改为先弹出 `showClinicSummaryPreviewDialog`，用户在预览弹窗内点击 [分享给医生] 按钮触发分享。移除了 `page.dart` 中的 `_handleClinicShare` 方法（逻辑已迁移到弹窗内）。
- **诊所摘要公开分享页**：新增 `clinic_summary_shared.dart` 页面和 `/report/clinic-summary/:token` 路由（公开路由，无需认证）。页面调用 `GET /reports/clinic-summary/shared/:token` 展示分享的摘要内容，底部含 [下载 PDF] 按钮（调用 `shared/:token/pdf`，`extra: {skipAuthorization: true}`）。
- **诊所摘要 Provider**：新增 `clinic_summary.dart` provider 文件，包含 `clinicSummaryPreviewProvider`（autoDispose FutureProvider）和 `clinicSummarySharedProvider`（autoDispose family FutureProvider）。
- **诊所摘要共享内容组件**：新增 `clinic_summary_content.dart`，`ClinicSummaryContent` widget 复用于预览弹窗和公开分享页，展示生成时间、数据范围、脱敏个人信息、过敏/疾病/用药列表、关键发现、免责声明，底部可选 [下载 PDF] / [分享] 按钮。

## 2026-07-21 审查修复

- **公开分享页错误区分**：`clinic_summary_shared.dart` 的错误回调从统一显示"链接已过期"改为通过 `LucentErrorMapper.toAppError` 区分网络错误（`AppErrorKind.network`）和链接失效。网络错误显示"网络连接失败"+ `wifiOff` 图标 + 重试按钮；其他错误仍显示"链接已过期" + `triangleAlert` 图标。
- **PDF 下载逻辑提取**：新增 `pdf_download.dart` 工具文件，`downloadAndSharePdf()` 函数封装 Dio 二进制下载 → 写临时文件 → SharePlus 分享的完整流程。预览弹窗和公开分享页均改为调用此函数，消除重复代码。
- **MetaRow / formatDateTimeFull 提取**：`_MetaRow` widget 提取为 `components.dart` 中的公共 `MetaRow`；`_formatDateTime` 方法提取为 `date_format_utils.dart` 中的 `formatDateTimeFull()`。`clinic_summary_content.dart` 和 `suggestion_history_detail_sheet.dart` 均改用公共组件。
- **分享失败错误消息格式**：硬拼接 `'${l10n.reportExportFailedToast}: ${error.message}'` 改为 l10n 参数化字符串 `reportExportFailedWithReason(reason)`，中英文冒号格式由 ARB 模板控制。

## 2026-07-26 Report UX 瘦身

- **移除 `ReportActionBar`**：内容区不再重复生成总结/同步按钮，操作统一由 readiness 主卡提供，消除重复 CTA。
- **移除日期范围文本标签**：时间范围已由 Header `ReportRangeMenu` 表达，内容区不再重复展示。
- **section 重排**：导出区从 AI 总结后移至页面末尾（规律分析之后），引导先阅读再导出。桌面端导出从双栏上方移至双栏之后全宽展示。
- **间距统一**：移动端各 section 间距从 `Spacing.level4` 统一为 `Spacing.level5`，视觉节奏一致。
- **Findings 分隔线移除**：`findings.dart` 去掉标题与内容间的 `AppDivider`，与其他 section 头部风格统一。

## 2026-08-14 回顾与就诊摘要成功边界测量

- Review 页在回顾数据实际呈现（AsyncData 过渡、登录态）时上报 `review_opened`（surface=review），session 去重。
- 就诊摘要预览弹窗：preview 在服务端响应边界上报 `visit_summary_previewed`（surface=more），每次呈现一条；PDF 下载按结果上报 `visit_summary_exported`，失败计 failure 不计 exported。分享由服务端 share_created/opened/revoked 记录，客户端不上报。
- More sheet 的 PDF/打印导出在 `handleReportExportAction` 上报 `visit_summary_exported`（surface=more）：HTTP 成功但请求状态为 idle/failed/unavailable 时记 failure，requested/processing/completed 才记 success。

### 2026-08-15 — Clinic Summary 分享/预览走生成客户端

响应契约信封化修复后,preview/share/shared 三处 raw Dio 手动解包 workaround 移除,
统一走生成客户端(`reportsControllerPreviewClinicSummaryV1` 等);`api_paths.dart` 删除
对应的信封解包常量与注释。行为不变(仍校验信封 code),错误路径由 DioException 驱动。

### 2026-08-18 — R-3 周月纵向洞察生成器替换泛化总结口径

- AI 总结卡片内容结构由泛化 bullets + actionLabel + confidenceNote 替换为 **覆盖率 + 已观察模式 + 低风险行动 + 免责声明** 四段。
- `ReportAiSummary` entity 字段变更：删除 `bullets`/`actionLabel`/`action`/`confidenceNote`，新增 `coverage`（medication/water/sleep 各 trackedDays+totalDays）、`observedPattern`（nullable）、`lowRiskAction`（nullable）、`disclaimer`。
- `ReportAiSummaryContent` 不再有 `bullets: List<ReportAiSummaryItem>`，改为 `observedPattern`/`lowRiskAction`/`disclaimer`/`coverage`。
- 删除非流式 `generate()` 方法（domain interface / remote datasource / repository 三层），仅保留 `generateStream()`。
- section 渲染由 bullets 列表 + action 按钮改为 observedPattern / lowRiskAction / disclaimer 三段文本。
- 生成客户端重新生成，新增 `ReportCoverageDto`/`ReportObservedPatternDto`/`ReportLowRiskActionDto` 等模型。
