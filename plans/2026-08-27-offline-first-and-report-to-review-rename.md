# 离线优先策略 + report→review 全量改名计划

Created: 2026-08-27

## 一、问题现状

### 1.1 骨架屏长时间不消失

离线状态下打开应用，每个 tab 都长时间显示骨架屏，过了很长时间才显示错误页。

**根因链路**：

```
Tab Page → resolvePageViewState()
  → data.isLoading && !data.hasValue → PageViewStateLoading (骨架屏)
  → data.error → PageViewStateFatalError (错误页)
```

- `authGuarded`：session restoring 时返回永不完成的 `Completer<T>().future`（`pendingAuthSessionResolution`），provider 永远停在 `loading`。
- `AuthSessionNotifier.restore()`：调 `fetchAccount().run()`，网络请求受 Dio 超时（connect/receive 各 10s）限制。网络不通时最长等待 ~20s（fetchAccount + refreshSession 串行），期间 `isLoading: true` → `isRestoring: true` → 所有 tab 骨架屏。
- `healthContextSnapshotProvider`：有 5s `.timeout()`，缓存为空时 5s 后报错。
- `reportPage`：`reviewCurrentProvider` 有 10s `_reviewTimeout`，缓存为空时 10s 后报错。
- 其他 provider（mine、medicine workspace）：**无客户端 timeout**，靠 Dio 10s 超时兜底，但 Dio 的 `connectionTimeout` 是连接建立超时，DNS 解析或 TCP 握手卡住时可能更长。
- **`resolvePageViewState` 第 105 行**：`data.isLoading && data.hasValue` 时保留旧数据——但首次加载（缓存空）时 `hasValue = false`，只能走 `loading` 分支。

### 1.2 无缓存的 repository

| Tab | Repository | 缓存层 | 无网络行为 |
|-----|-----------|--------|-----------|
| Today | `LucentTodayRepository` | 依赖 health-context（缓存✅）+ daily-record（缓存✅）+ dose-log（缓存✅） | ✅ 缓存非空时 degraded dashboard |
| Record | `LucentDailyRecordRepository` | ✅ cache-first | ✅ 缓存非空正常 |
| Medicine | `LucentMedicineWorkspaceRepository` | ❌ 无独立缓存层，依赖 health-context 缓存 + 纯远程 dose-log/reminder（失败降级为空） | ⚠️ health-context 缓存空时报错 |
| Review | `LucentReviewRepository` + `LucentReportRepository` | ❌ 均无缓存层，纯远程 | ❌ 直接报错 |
| Mine | `LucentMineRepository` | 间接依赖 health-context 缓存 | ⚠️ health-context 缓存空时报错 |

### 1.3 report→review 命名遗留

第五 tab 产品概念已从 "Report" 改为 "Review"，但代码中大量旧名遗留：

- 文件夹：`lib/features/report/`（应改为 `lib/features/review/`）
- l10n 分片：`report_zh.arb` / `report_en.arb`（应改为 `review_zh.arb` / `review_en.arb`）
- ARB key：~283 个 `report*` 前缀 key
- 类名：`ReportPage`、`ReportRepository`、`ReportRemoteDataSource`、`ReportDashboard`、`LucentReportRepository` 等
- 路由：`Routes.report`、`/report` 路径、`ShellTab.report`
- 变量/方法名：`reportDashboardProvider`、`reportAiSummaryControllerProvider` 等
- 测试目录：`test/report/`、`integration_test/report/`
- 文档：大量 `docs/` 下文件引用 `report`

## 二、方案

### Phase 1: 底线超时 + 离线兜底（P0，阻塞所有后续工作）

#### 1.1 `authGuarded` 底线超时

**文件**：`lib/core/providers/auth_guarded.dart`

当前 `pendingAuthSessionResolution<T>()` 返回永不完成的 Future。改为带超时回退：

```dart
Future<T> pendingAuthSessionResolution<T>({
  Duration timeout = const Duration(seconds: 8),
  required Ref ref,
}) {
  return ref.watch(authSessionProvider.notifier).restoreFuture().timeout(
    timeout,
    onTimeout: () => throw TimeoutException('Session restore timed out'),
  );
}
```

或者更简单的方案：在 `AuthSessionNotifier.build()` 中启动 `restore()` 并设置一个内部超时，超时后 `state = AuthSessionState(isLoading: false, isAuthenticated: false, errorMessage: '网络超时，请检查网络后重试')`。

这样 `isRestoring` 变为 `false`，`isConfirmedSignedOut` 变为 `true`，各 tab provider 走 `signedOutFallback` 或 `AuthRequiredException`，不再卡在骨架屏。

**选择方案 B**（在 Notifier 层加超时），因为：
- 不需要改 `authGuarded` 签名
- 超时后可以显示"网络超时"提示而非直接登出
- 各 tab 可以根据 `session.isConfirmedSignedOut` 走 preview 或错误态

#### 1.2 `resolvePageViewState` loading 超时

**文件**：`lib/core/widgets/common/page_state.dart`

在 `PageViewStateLoading` 中增加一个底线超时机制。当 loading 持续超过阈值（如 6s），自动降级为"网络缓慢"提示而非无限骨架屏。

方案：在 `PageStateSwitch` 的 loading 分支中包一个 `FutureBuilder` + `Timer`，超时后显示"加载缓慢"提示 + 重试按钮。

或更简单：在各 tab page 的 `loadingBuilder` 中自行处理，不改公共组件。

**选择方案**：在公共组件 `_DefaultLoadingView` 中增加底线超时——6s 后骨架屏上方出现"加载缓慢，点击重试"提示条。各 tab 自定义的 `loadingBuilder` 也需要同步处理。

#### 1.3 无缓存 repository 增加 cache-first

需要新增缓存层的 repository：

1. **`LucentReviewRepository`**（`lib/features/review/data/repositories/lucent_review.dart`）
   - 新增 `ReviewDao` + `reviews` Drift table
   - `fetchCurrent()` / `fetchHistory()` 改为 cache-first

2. **`LucentReportRepository`**（`lib/features/review/data/repositories/lucent.dart`）
   - 新增 `ReportDashboardDao` + `report_dashboards` Drift table（或复用 health-context snapshot 中已有的聚合数据）
   - `fetchDashboard()` 改为 cache-first

3. **`LucentMedicineWorkspaceRepository`**（`lib/features/medicine/data/repositories/lucent_workspace.dart`）
   - 已依赖 health-context 缓存；但 `doseLogDs` 和 `reminderDs` 使用的是纯远程 `DoseLogRemoteDataSource` 和 `MedicineReminderRemoteDataSource`
   - 改为注入 `DoseLogRepository`（即 `CachedDoseLogDataSource`）而非 `DoseLogRemoteDataSource`
   - `reminderDs` 增加 `ReminderDao` + `reminders` Drift table（已有 `current_medicines` 表但无 reminders 表）

4. **`LucentMineRepository`**（`lib/features/mine/data/repositories/lucent.dart`）
   - 已依赖 `healthContextSnapshotProvider`（有缓存），无需额外缓存层
   - 但 `healthContextSnapshotProvider` 缓存为空时的超时需要缩短

5. **`LucentUserSettingsRepository`** / **`LucentNotificationPreferencesRepository`** / **`LucentNotificationRepository`**
   - 增加 SharedPreferences / Drift 轻量缓存（已有部分 SharedPreferences 缓存）

#### 1.4 网络超时常量统一

**文件**：`lib/core/database/cache_constants.dart`

当前 `networkTimeoutShort = 5s`，Dio `connectTimeout = receiveTimeout = 10s`。

新增：
```dart
/// 底线超时：首次加载（缓存为空）时，超过此时间显示"加载缓慢"提示
const Duration loadingFloorTimeout = Duration(seconds: 6);

/// Session restore 超时：超过此时间放弃等待，降级为未登录态
const Duration sessionRestoreTimeout = Duration(seconds: 8);
```

### Phase 2: report→review 全量改名（P1）

#### 2.1 原则

- 文件夹 `lib/features/report/` → `lib/features/review/`
- 文件名中的 `report` → `review`（仅 report→review 语义的文件，不含 `reminder_delivery_reporter` 等无关文件）
- 类名 `Report*` → `Review*`（如 `ReportPage` → `ReviewPage`、`ReportDashboard` → `ReviewDashboard`）
- 变量名 `report*` → `review*`（如 `reportDashboardProvider` → `reviewDashboardProvider`）
- ARB key `report*` → `review*`（如 `reportRangePickerTitle` → `reviewRangePickerTitle`）
- l10n 分片文件 `report_zh.arb` / `report_en.arb` → `review_zh.arb` / `review_en.arb`
- 路由 `Routes.report` → `Routes.review`，路径值 `/report` → `/review`，枚举 `ShellTab.report` → `ShellTab.review`
- 子路由同步改：`/report/clinic-summary/:token` → `/review/clinic-summary/:token`，`/report/legacy` → `/review/legacy`，`/report/review/:eventId` → `/review/detail/:eventId`
- 测试目录 `test/report/` → `test/review/`，`integration_test/report/` → `integration_test/review/`
- 文档中 `report` → `review`（仅指第五 tab 的，archive 历史文档不动）

#### 2.2 不改名的例外

以下保留 `report` 名称，因为它们不是第五 tab 的产品概念：
- `reminder_delivery_reporter.dart` / `medicineReminderDeliveryReporterProvider`（提醒送达报告）
- `ReminderDeliveryReporter` 类
- `ReportAiSummaryRepository` → `ReviewAiSummaryRepository`（改，因为是第五 tab 的 AI 摘要）
- `analytics/product_event_service.dart` 中的 `trackReviewOpened` 等已用 review 命名的（不动）
- `docs/04-archive/` 下的历史迁移日志（不动）

#### 2.3 执行顺序

1. **l10n 分片重命名**：`report_zh.arb` / `report_en.arb` → `review_zh.arb` / `review_en.arb`，key 前缀 `report` → `review`
2. **dart run scripts/arb_tools.dart merge** + **flutter gen-l10n**
3. **lib/features/report/ → lib/features/review/**：移动文件夹
4. **文件名重命名**：`report.dart` → `review_legacy.dart`（或合并到已有 review 文件），`lucent.dart` → `lucent_review_legacy.dart` 等
5. **类名/变量名批量替换**：使用全局 sed/grep 替换
6. **路由更新**：`Routes.report` → `Routes.review`，路径值 `/report` → `/review`，`ShellTab.report` → `ShellTab.review`；同步更新所有子路由路径和 `loginRouteForCurrentLocation` 等引用
7. **测试目录移动**：`test/report/` → `test/review/`，`integration_test/report/` → `integration_test/review/`
8. **文档更新**：`docs/02-reference/`、`docs/00-current/` 中 report → review（仅第五 tab 语义）
9. **check_doc_coverage.dart** 更新规则映射（如有）
10. **flutter analyze** + **flutter test** 全量验证

#### 2.4 ARB key 改名范围

`report_zh.arb` / `report_en.arb` 中 ~283 处 `report*` key。需要：

1. 文件名改为 `review_zh.arb` / `review_en.arb`
2. key 前缀 `report` → `review`（如 `reportRangePickerTitle` → `reviewRangePickerTitle`）
3. 代码中 `l10n.reportRangePickerTitle` → `l10n.reviewRangePickerTitle` 全量替换
4. 其他分片中引用的 `report*` key（`today_en.arb`、`settings_en.arb`、`mine_en.arb`、`common_en.arb`、`assistant_en.arb`、`notification_en.arb`）同步改名

### Phase 3: 文档与验证（P2）

1. 更新 `docs/00-current/Active_UI_*.md` 中 report → review
2. 更新 `docs/02-reference/routing.md`、`architecture.md` 等
3. 更新 `docs/02-reference/Localization.md`
4. 更新 `Luminous/AGENTS.md` 和 `CLAUDE.md` 中 report → review
5. `flutter analyze` + `flutter test` + `dart run scripts/check_doc_coverage.dart --warning-only`

## 三、依赖关系

- Phase 1.1（authGuarded 超时）和 Phase 1.2（loading 超时）互相独立，可并行
- Phase 1.3（cache-first repository）依赖 Phase 1.1（否则缓存空时仍卡在骨架屏）
- Phase 2（改名）独立于 Phase 1，可并行
- Phase 3 依赖 Phase 1 和 Phase 2 完成

## 四、执行顺序

1. **Phase 1.1**：`AuthSessionNotifier` 增加底线超时
2. **Phase 1.2**：`PageStateSwitch` loading 增加底线超时提示
3. **Phase 1.3**：逐个 repository 增加 cache-first（review → medicine workspace → settings/notification）
4. **Phase 1.4**：统一超时常量
5. **Phase 2**：report→review 全量改名（按 2.3 执行顺序）
6. **Phase 3**：文档更新与全量验证

## 五、风险与缓解

- **Phase 1.1 风险**：超时后用户可能看到"未登录"态而非"网络超时"提示。缓解：在 `AuthSessionState` 中区分 `isTimeout` 标记，UI 层显示"网络超时"而非登录引导。
- **Phase 1.3 风险**：新增 Drift 表需要 migration。缓解：Drift schema version +1，`@DriftDatabase` 增加 migration step。
- **Phase 2 风险**：大规模改名可能遗漏。缓解：改名后 `flutter analyze` 会捕获所有缺失引用；`grep -r report` 确认无残留。
- **Phase 2 路由变更**：`/report` → `/review` 全量替换，已有的深链接（分享链接等）如需向后兼容可在路由层增加 `/report` → `/review` 的 redirect 规则。
