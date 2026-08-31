# lib/features/today — 今日看板

## Summary

today 是五 tab shell 的**第一个 tab**（路由 `Routes.home`，即 `/`，也是 `initialLocation`），
职责是"今日行动面板"：聚合问候、主/次建议卡、AI 摘要、健康观察、快捷入口，是跨 feature
数据的**展示聚合层**。它本身不持有领域数据，而是编排其他 feature 的 domain/repository 与
共享 provider 拼出 `TodayDashboard` 和建议流。

UI 行为细节以代码与 `flutter test` 为准；本 README 只讲结构与聚合模式。

## 目录结构

- `application/usecases/` — `quick_entry_water.dart`（一键饮水：复用 record 的
  `WaterQuickEntryFlow` / `QuickEntryUndoService`，保留撤销语义）、`skip_dose.dart`
  （`SkipDoseUseCase`：调 medicine 的 `DoseLogRepository.mark(skipped)` 并发
  `DataChangeTopic.doseLogs`）。
- `data/datasources/` — `suggestion_remote.dart`（`TodaySuggestionRemoteDataSource`：
  建议 bundle / 反馈 / AI 解释 / 历史）、`ai_remote.dart`（`TodayAiRemoteDataSource`：
  今日 AI 分析读/刷新/SSE 生成流）。
- `data/providers/` — `today_suggestion.dart`（`todayRepositoryProvider` 装配聚合仓库）、
  `suggestion.dart`（dataSource / repository / `suggestionHistoryProvider`，被 review 消费）。
- `data/repositories/` — `lucent.dart`（`LucentTodayRepository`：聚合构建 `TodayDashboard`）、
  `lucent_ai.dart`（`LucentTodayAiRepository` + AI 相关 provider）。
- `data/utils/` — `suggestion_json_codec.dart`（建议 bundle 的本地缓存序列化）。
- `domain/entities/` — `dashboard.dart`（`TodayDashboard` + 全部子模型与枚举）、
  `suggestion.dart`（`TodaySuggestionBundle` / 卡片 / 证据 / 反馈 / 历史）、
  `ai_analysis.dart`（`TodayAiAnalysis` + 物化状态 + 卡片状态机）。
- `domain/repositories/` — `dashboard.dart`（`TodayRepository`）、`suggestion.dart`
  （`SuggestionRepository`）、`ai.dart`（`TodayAiRepository`）。
- `presentation/pages/` — `page.dart`（`TodayPage`：状态分流 + 桌面/移动壳选择 + 下拉刷新）。
- `presentation/providers/` — `dashboard.dart`（`todayDashboardProvider`）、
  `suggestion.dart`（`todaySuggestionProvider` AsyncNotifier + `suggestionExplanationProvider`）、
  `ai_analysis.dart`（`todayAiAnalysisControllerProvider`）。
- `presentation/widgets/` — `views/`（`dashboard_view.dart`、`skeleton_view.dart`）、
  `sections/`（suggestion / suggestion_primary_card / suggestion_interactive /
  suggestion_state_views / summary / observation / quick_actions）、`shared/`
  （section / top_bar / card_style / components / view_models / suggestion_icon_mapping）。

## Dashboard 聚合模式

**数据来源**：`DataChangeBus`（跨 feature 变更广播）+ 各 feature 的 repository/provider。
三个数据 provider 各自独立、互不阻塞：

- `todayDashboardProvider`（keepAlive）— `ref.watch(dataChangeVersionProvider(...))` 监听
  6 个 topic（dailyRecords / currentMedicines / doseLogs / medicineReminders / userSettings /
  healthEvents），任一变更自动重建；`authGuarded`，未登录返回 `TodayDashboard.signedOut()`。
- `todaySuggestionProvider`（AsyncNotifier）— cache-first + 后台刷新 + 300ms debounce
  监听 `dataChangeBusProvider`；dismiss 本地排除、feedback 提交后静默重拉；
  pending/stale/failed 时 `_preservePreviousContent` 保留旧卡。
- `todayAiAnalysisControllerProvider` — 物化读模型（empty/pending/ready/stale/failed），
  `403 → disabled`，尊重 `userSettingsControllerProvider.aiSummariesEnabled` 开关。

**聚合仓库** `LucentTodayRepository._buildDashboard()`：health_context 快照 → 当前用药
列表 → daily record 摘要（water 汇总 / vital 读数 / sleep / mood）→ dose logs（已完成
药品集合）→ reminders（今日排程分母 `_todayScheduledMedicineIds`、下一提醒）→ settings
（水目标）→ notification（未读）。**已知上游失败按 section 降级**为
`TodayObservedMetricState.degraded`（degraded 态），不整页报错。

**视图聚合** `dashboard_view.dart`：`TodayDashboardView` 按 `Breakpoints.desktop` 分流
mobile 单列 / desktop 双栏（左 7: Primary+Summary，右 5: Secondary+Observation）；
section 顺序 = 问候语 → PrimarySuggestion → SecondarySuggestions → Summary →
HealthEvent → Observation → QuickActions；`SkeletonScope` 包裹加载态，
`TodaySkeletonView` 按真实 section 顺序镜像骨架屏。

## 跨 feature 依赖（出边）

- **health_context** — `snapshot.dart` entity + `healthContextSnapshotProvider`
  （聚合构建用药概览；health event 的当前用药选项）。
- **medicine** — `dose_log.dart` / `reminder.dart` entity + 各自 repository
  （`doseLogRepositoryProvider` / `reminderRepositoryProvider`）。
- **record** — `record.dart` entity + `dailyRecordRepositoryProvider` /
  `dailyRecordListForDateProvider`（摘要数据、health event 原因记录选项）；
  quick entry 复用 record 的 use case。
- **health_event** — `activeHealthEventProvider` + start/check-in/end 三个 sheet
  （今日页内的活动事件区块）。
- **settings** — `userSettingsRepositoryProvider`（水目标）+ `userSettingsControllerProvider`
  （AI 摘要开关）。
- **notification** — `notificationRepositoryProvider`（未读徽标）。
- **shell** — `DesktopTabShell` / `ShellDeferredContent`（桌面壳；today 自带
  `TodayTopBar`，`showHeader: false` 避免双标题）。

**入边依赖**：review（`suggestionHistoryProvider` + suggestion entity）、
`core/push/message_handler.dart`（推送路由到 `/` 并触发 AI 摘要刷新）、
`lib/app/router.dart`（tab 路由）。今日页内的健康事件区块是今日页**唯一**直接操作
其他 feature 状态的区域，事件创建/结束/check-in 后由 `DataChangeTopic.healthEvents`
驱动两个数据 provider 自动刷新。

## 与 shell 五 tab 的关系

- 五 tab：today / record / medicine / review（旧名 report，tab key 保留
  `shell-tab-report` 兼容）/ mine，位于 `StatefulShellRoute.indexedStack`。
- today 是第 0 个 branch、`initialLocation`；未登录可预览（`isPreview` 模式显示
  `SignInHintBanner`，`todayDashboardProvider` 返回 signed-out 占位数据）。
- 桌面端今日页不再使用 shell 头部（`DesktopTabShell(showHeader: false)`），由
  `TodayTopBar` 自带标题 + 助手/通知入口。
