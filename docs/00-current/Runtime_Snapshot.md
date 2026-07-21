# Luminous Runtime Snapshot

Last updated: 2026-07-21 (Today compact summary)

## 技术栈

- Flutter + Riverpod（`@riverpod` 注解 + 手写 `NotifierProvider`/`AsyncNotifierProvider` 混合）+ GoRouter（`go_router_builder` 类型安全路由）。
- 编译期环境变量入口：`lib/core/config/env_keys.dart` + `env_reader.dart`，通过 `--dart-define-from-file=.env` 注入。
- 本地持久化：Drift（WAL 模式 + 外键约束），6 张表 + 6 个 DAO + `SyncWorker`（指数退避重放）。
- 日志：`talker_flutter`（全量替换 `debugPrint`），release 保留内存历史 + Sentry 转发。
- 错误上报：`sentry_flutter ^9.0.0`，`SentryTalkerObserver` 桥接 Talker 事件 → Sentry，`SENTRY_DSN` 空时跳过 init。
- AI 开发增强：`.github/copilot-instructions.md`、`.cursor/mcp.json`、`dart.mcpServer`、`lib/core/ai/` 实验 seam。

## 主题与设计系统

- `LuminousApp` 使用 Forui 引导的根主题，`MaterialApp.router` 从 Forui 派生 light/dark `ThemeData`。
- 语义颜色枚举 `SemanticColor`（6 个语义色）× `SemanticColorPalette`（5 个预计算 tone：solid/foreground/muted/subtle/border）。
- `SemanticColors` 通过 `FColors.extensions` 注入 Forui 主题，暗色模式 alpha 自动补偿。
- 高对比度模式使用 `HighContrastColors` 常量类（`lib/core/design/high_contrast.dart`）。

## Token 系统

所有 token 位于 `lib/core/design/`，通过 barrel `design.dart` 统一导出。`App*` 前缀已全部移除。

- `Spacing` — `level1..level12`（4/6/10/14/20/28/36/44/56/72/96/128）。
- `RadiusTokens` — `level0..level9` + `levelFull`。
- `TypographyToken` — `level1..level10`。
- `DurationTokens` — 路由过渡 + widget 动画时长。
- `Breakpoints` — `mobile`(600) / `tablet`(960) / `desktop`(1200)。
- `ResponsiveSizing` — 卡宽 / sidebar 宽 / grid 列数 / 可缩放尺寸 helper。
- `LayoutScale` + `LayoutScaleResolver` — 响应式布局刻度 + 对话框固定宽度。

## 响应式布局

- `ResponsiveContentFrame` 从 `tablet`(960px) 起应用 `maxContentWidth` 约束（平板 1040px / 桌面 1400px），移动端不限宽。
- `DesktopTabShell` 统一桌面端外壳（AppTopBar + maxWidth 约束 + muted 背景 + 可选 RefreshIndicator）。
- 5 个 Tab 页面全部迁移到 `DesktopTabShell`。

## 网络层

- 拦截器链：`AuthInterceptor`（token 注入 + 401 刷新）→ `RetryInterceptor`（5xx/超时重试）→ `ErrorInterceptor`（DioException → LucentApiException 映射）。
- `LucentDioClient` 仅负责 Dio 实例配置 + interceptor 注册。
- `lucentClientProvider`（keepAlive）是全部 feature 的统一 API 访问入口。
- `LucentSseClient` 支持 `reconnect` 自动重连；SSE 请求单独覆盖 `receiveTimeout: Duration.zero`（不限超时），避免 AI 生成慢时主 Dio 的 10s `receiveTimeout` 导致流提前中断。
- `LucentApiPaths` 常量注册表集中管理所有 API 路径字符串。
- `LucentErrorMapper.toAppError()` 将任意异常转换为 `AppError`（5 分类：network/auth/server/business/unknown）。网络层 fallback 消息为英文（locale-neutral），业务错误消息由服务端按 locale 返回。

## 错误处理

- `lib/core/errors/`：`AppError` + `Result<T>`（sealed class）+ `runGuarded<T>()`（泛化错误处理 helper）。
- `userMessageFromError()` 安全提取用户友好消息，避免内部异常文本暴露。
- `core/network/envelope.dart`：`throwIfFailed()`/`unwrapOrThrow()`/`ensureEnvelopeSuccess()` 统一业务错误 helper。

## 状态管理

- `@riverpod` 注解函数用于 repository DI + 简单数据读取。
- 手写 `NotifierProvider`/`AsyncNotifierProvider` 用于表单、分页、复杂交互状态（因 riverpod_generator 命名不匹配项目约定）。
- `authGuarded` helper 封装 auth session 检查模式。
- `DataChangeBus`（keepAlive Notifier）解耦跨 feature invalidation——`DataChangeTopic` 定义 5 个领域事件，消费方 watch `dataChangeVersionProvider(topic)`。
- `PrefKeys`（`core/config/pref_keys.dart`）集中管理 35 个 SharedPreferences key。

## 本地持久化

- Drift 6 张表：daily_records / medicine_dose_logs / current_medicines / health_context / today_suggestions / pending_sync_queue。
- cache-first 模式：读（缓存 + 后台刷新节流 30-60s）→ 写（乐观本地副本 → 远程确认/失败入队 pending sync）。
- `SyncWorker`：connectivity_plus 监听 + 指数退避重放 + maxRetry 上限 + handler 注册机制。
- `cacheCleanupProvider`：应用启动时按 `DataRetentionPeriod` 清理过期缓存。
- `MineSyncFailedBanner`：Mine 页面顶部展示同步失败警告。
- `cache_constants.dart`：统一所有时间常量（节流/超时/重试/退避）。

## 认证与会话

- 认证/会话状态：恢复中 / 确认已登出 / 已登录。
- `AuthRepository` 接口（22 个方法）+ `LucentAuthRepository` 实现。
- `OAuthLoginController` 统管 WeChat/QQ/Apple 三方登录。
- GoRouter 全局 `redirect` 守卫：未认证用户可以访问主 tab 预览页（`/`、`/record`、`/medicine`、`/report`、`/mine`）以及 `/settings`、`/assistant`、`/legal`、`/report/clinic-summary`；其他受保护路由才重定向到 `/login`。已认证用户访问 `/login`、`/register`、`/forgot-password` 时会被送回首页。
- 受保护 provider 在认证恢复或确认登出时不调用 Lucent。
- 受保护入口点击在当前页弹出登录提示（`AuthRequiredDialogGate` 带 returnTo）。

## 类型安全路由

- `go_router_builder ^4.3.0`，8 个 feature 各自 `presentation/routes.dart` 使用 `@TypedGoRoute` 注解（共 42 条路由）。
- `router.dart` 通过 `...feature_routes.$appRoutes` spread 聚合。
- 5 个 shell tab 路由保持手写（`StatefulShellRoute.indexedStack`）。
- `AppRoutes` 常量集中管理所有路由路径字符串，已移除死路由 `medicineReminders`（无对应页面）。

## 国际化

- ARB 文件按功能模块拆分为 `lib/l10n/src/{fragment}_{locale}.arb`（10 个 fragment × 2 locale = 20 文件）。
- `scripts/arb_tools.dart` merge 命令在 `flutter gen-l10n` 前合并为 `app_{zh,en}.arb`（gitignored）。
- 用户可见文本全部通过 ARB + `AppLocalizations`，无硬编码字符串。
- Medicine 主页新增空态文案键：`medicineTodayPlanEmpty`、`medicineSafetyPanelEmptyTitle`、`medicineSafetyPanelEmptyBody`（位于 `medicine_*` 分片）。
- Mine 健康档案分组新增空态文案键：`mineArchiveEmptyTitle`、`mineArchiveEmptyDescription`（位于 `mine_*` 分片）。
- Report 预览空态新增文案键：`reportPreviewBannerMessage`、`reportTrendPreviewTitle/Body`、`reportFindingsPreviewTitle/Body`、`reportSuggestionHistoryPreviewTitle/Body`、`reportExportPreviewTitle/Body`（位于 `report_*` 分片）。
- 日期格式化通过 `lib/core/utils/date_format_utils.dart`（locale 感知 `intl.DateFormat` 封装）。

## 测试与验证

- 集成测试统一使用 Patrol（`patrolTest`）。
- `integration_test/` 分为离线/mock 流程与 Android 模拟器全栈 lane。
- 全栈移动 E2E 当前为本地/手动，不属于 GitHub Actions 流水线。
- 本地验证入口：`tool/check_doc_coverage.dart`、`tool/run_daily_checks.dart`、`tool/run_fullstack_checks.dart`、`tool/verify_lucent_openapi_sync.dart`。
- GitHub Actions 在构建 APK 前检查生成客户端漂移。
- Mock repositories 仅存在于 `test/helpers/mocks/`，生产代码使用 repository `signedOut()` 工厂返回静态预览数据。

## 页面脚手架

- 子页直接组合 `FScaffold` + `FHeader` + `ResponsiveContentFrame`。
- 骨架屏通过 `AppSkeletonScope`/`AppSkeletonSlot`/`AppSkeletonText` 细粒度行内骨架，不造假数据。
- 页面级错误使用 `AppStateErrorView`，加载态使用 shimmer 骨架屏。
- `AppStateMessageView` 的 `description` 参数为可选（`String?`），仅需标题+图标的场景不再需要传入重复文案。
- 轻量反馈使用 `AppToast`（`lib/core/feedback/app_toast.dart`），不用页面级 `SnackBar`。
- Today 未登录态使用预览 dashboard，不显示“今天还没有记录”引导；摘要指标和快捷入口由前端 view model 基于 dashboard 数据组装。

## ARB 编辑流程（2026-07-20 更新）

- **绝对不要直接编辑 `app_zh.arb` / `app_en.arb`**：这两个文件是由 `lib/l10n/src/` 下分片合并生成的产物。直接编辑的改动会在下次 merge 时丢失。
- 正确流程：编辑 `lib/l10n/src/` 下分片 → `dart scripts/arb_tools.dart merge` → `flutter gen-l10n`。
- `lib/l10n/AGENTS.md` 是 l10n 目录的专用规则文件，详细记录了分片映射表和新模块添加流程。
- 全部 9 个设置子页统一使用 `settingsPageVerticalPadding(context)` 共享函数，不再各自内联响应式三元表达式。
