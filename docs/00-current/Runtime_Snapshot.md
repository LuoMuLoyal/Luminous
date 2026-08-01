# Luminous Runtime Snapshot

Last updated: 2026-07-30 (OCR engine init fix and ABI pre-check)

## 技术栈

- Flutter + Riverpod（`@riverpod` 注解 + 手写 `NotifierProvider`/`AsyncNotifierProvider` 混合）+ GoRouter（`go_router_builder` 类型安全路由）。
- 编译期环境变量入口：`lib/core/config/env_keys.dart` + `env_reader.dart`，通过 `--dart-define-from-file=.env` 注入。新增 `SUPPORT_EMAIL` 环境变量用于帮助页面的反馈邮箱入口。
- 本地持久化：Drift（WAL 模式 + 外键约束），6 张表 + 6 个 DAO + `SyncWorker`（指数退避重放）。
- 日志：`talker_flutter`（全量替换 `debugPrint`），release 保留内存历史 + Sentry 转发。
- 错误上报：`sentry_flutter ^9.0.0`，`SentryTalkerObserver` 桥接 Talker 事件 → Sentry，`SENTRY_DSN` 空时跳过 init。
- AI 开发增强：`.github/copilot-instructions.md`、`.cursor/mcp.json`、`dart.mcpServer`、`lib/core/ai/` 实验 seam。

## 主题与设计系统

- `LuminousApp` 使用 Forui 引导的根主题，`MaterialApp.router` 从 Forui 派生 light/dark `ThemeData`。
- Forui 0.24.0 移除了除 `neutral` 外的所有预定义颜色方案（原 `FThemes.blue/green/orange/red/rose/slate/violet/yellow/zinc`）。`lib/core/theme/theme.dart` 通过 `_familyColorOverride()` 函数在 `FTheme.neutral` 基础上覆盖 `primary` / `primaryForeground` 来模拟原有主题族的颜色变体，保持 App 的主题族选择能力不变。
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
- `DesktopTabShell` 统一桌面端外壳（FHeader.nested + maxWidth 约束 + muted 背景 + 可选 RefreshIndicator）。
- 5 个 Tab 页面全部迁移到 `DesktopTabShell`，顶栏统一使用 `FHeader.nested` 替代自定义 `AppTopBar`。
- 桌面端侧边栏始终展开（图标 + 文字），不可折叠。
- 侧边栏 header 显示用户头像+昵称（已登录）或 app Logo（未登录）；footer 包含通知入口（带红点）、主题快切（system/light/dark 三态循环）、设置、帮助。
- 桌面端窗口通过 `window_manager` 设置最小尺寸 480×720 + 窗口标题 + 隐藏原生标题栏（`TitleBarStyle.hidden`）（Web/移动端为 no-op）。自定义标题栏集成在侧边栏头部：`DragToMoveArea` 支持拖拽移动窗口，Windows/Linux 渲染自定义最小化/最大化/关闭按钮（hover 态反馈），macOS 系统红绿灯按钮自动叠加。
- 对话框宽度自适应屏宽：`LayoutScaleResolver.dialogMaxWidthFor()` 桌面 560 / 平板 480 / 移动 360；`wideDialogMaxWidthFor()` 桌面 640 / 平板 520 / 移动 420。
- 全局键盘快捷键通过 `AppShortcuts`（StatelessWidget）注入到 `FToaster` 内层，组合 Flutter 原生 `Shortcuts` + `Actions`。快捷键：Ctrl/Cmd+K（命令面板）、+N（新建记录）、+,（设置）、+Shift+A（助手）、+1-5（切换 Tab）。
- 命令面板（Ctrl+K）提供模糊搜索 + Tab 导航 + 常用操作。
- 桌面端 Hover 态：`DesktopHoverCard` 通过 `MouseRegion` 追踪 hover，悬浮时背景/边框变为 primary 色调；移动端 pass-through。
- 右键上下文菜单使用 Forui `FContextMenu.tiles`，桌面端右键触发，移动端长按触发。时间线卡片已接入。
- 桌面端拖拽支持：Record 时间线卡片包裹 `Draggable<TimelineDragData>`（仅 `recordId != null` 且桌面端），可拖拽到日历日期单元格（`DragTarget`）改变记录日期。拖拽时源卡片半透明，目标日期高亮反馈，成功后 `DataChangeTopic.dailyRecords` 触发看板刷新。移动端不启用拖拽。
- 桌面端 CRUD 路由侧面板化：Record create/detail/edit 和 Medicine reminder new/detail/edit 路由在桌面端使用 `sidePanelPage`（右侧滑入面板，maxWidth 560，半透明遮罩，`barrierDismissible`），移动端降级为 `slidePage`（全屏）。
- 断点体系：`compact=360` / `mobile=600` / `tablet=960` / `smallDesktop=1080` / `desktop=1200` / `wide=1400` / `ultrawide=1920`。`LayoutScale` 在 1200–1400 和 ≥1400 使用不同 `maxContentWidth`（1400 vs 1600）。`gridCrossAxisCount` 在 ≥1920 使用 6 列。
- Medicine 页桌面布局：≥1400 三列（药盒 | 记录+安全 | 操作），1200–1400 双列（药盒+记录 | 安全+操作）。
- Report 页桌面布局：顶部全宽（就绪+指标+导出）+ 下方双列（趋势+发现+历史 | AI摘要+模式+免责）。
- Mine 页桌面布局：6:4 双列（同步+账号+归档+通知 | AI隐私+安全）。
- Settings 页桌面布局：≥1200 双列（账号+安全+通用 | 快速记录+隐私+关于+退出），移动端单列。

## 网络层

- 拦截器链：`AuthInterceptor`（token 注入 + 401 刷新）→ `RetryInterceptor`（5xx/超时重试）→ `ErrorInterceptor`（DioException → LucentApiException 映射）。
- `LucentDioClient` 仅负责 Dio 实例配置 + interceptor 注册。
- `lucentClientProvider`（keepAlive）是全部 feature 的统一 API 访问入口。
- Base URL 解析：debug 模式下 `DeveloperSettingsController.resolvedBaseUrl` 对 `ApiEndpoint.local` 做平台适配——Android 模拟器使用 `10.0.2.2`（因为 `127.0.0.1` 指向模拟器自身），其他平台使用 `127.0.0.1`。`LucentBaseUrl.value` 的 debug 回退同理。Release 模式强制使用 `.env` 注入的 `LUCENT_BASE_URL`。
- `LucentSseClient` 支持 `reconnect` 自动重连；SSE 请求单独覆盖 `receiveTimeout: Duration.zero`（不限超时），避免 AI 生成慢时主 Dio 的 10s `receiveTimeout` 导致流提前中断。
- `LucentApiPaths` 常量注册表集中管理所有 API 路径字符串。
- `LucentErrorMapper.toAppError()` 将任意异常转换为 `AppError`（5 分类：network/auth/server/business/unknown）。网络层 fallback 消息为英文（locale-neutral），业务错误消息由服务端按 locale 返回。
- Android debug 构建通过 `debug/AndroidManifest.xml` 的 `android:usesCleartextTraffic="true"` 允许明文 HTTP 流量；release 构建不受影响（使用 HTTPS）。

## 错误处理

- `lib/core/errors/`：`AppError` + `Result<T>`（sealed class）+ `runGuarded<T>()`（泛化错误处理 helper）。
- `userMessageFromError()` 安全提取用户友好消息，避免内部异常文本暴露。
- `core/network/envelope.dart`：`throwIfFailed()`/`unwrapOrThrow()`/`ensureEnvelopeSuccess()` 统一业务错误 helper。

## 状态管理

- `@riverpod` 注解函数用于 repository DI + 简单数据读取。
- 手写 `NotifierProvider`/`AsyncNotifierProvider` 用于表单、分页、复杂交互状态（因 riverpod_generator 命名不匹配项目约定）。
- `authGuarded` helper 封装 auth session 检查模式。
- `DataChangeBus`（keepAlive Notifier）解耦跨 feature invalidation——`DataChangeTopic` 定义 5 个领域事件，消费方 watch `dataChangeVersionProvider(topic)`。
- `PrefKeys`（`core/config/pref_keys.dart`）集中管理 SharedPreferences key。Record quick-entry
  偏好包括动态排序、自定义顺序、收起状态、频率计数、饮水默认量、饮水角标模式和睡眠进行中标记。
- Record quick-entry panel 从 `RecordDashboardView` 接收当天 `RecordDaySummary` 与 `RecordTimelineEntry`
  列表，用于本地渲染饮水角标（累计量/次数/隐藏）和睡眠进行中角标；该显示层不新增后端状态字段。

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
- `Routes` 常量集中管理所有路由路径字符串，已移除死路由 `medicineReminders`（无对应页面）。
- Record quick-entry settings 新增 `/record/quick-entry-settings` 和
  `/record/quick-entry-settings/reorder`，属于 shell 外的 Record typed routes，桌面端使用
  `sidePanelPage`。

## 国际化

- ARB 文件按功能模块拆分为 `lib/l10n/src/{fragment}_{locale}.arb`（11 个 fragment × 2 locale = 22 文件）。
- `scripts/arb_tools.dart` merge 命令在 `flutter gen-l10n` 前合并为 `app_{zh,en}.arb`（gitignored）。
- 用户可见文本全部通过 ARB + `AppLocalizations`，无硬编码字符串。
- 2026-07-28：Record 页面移除语音（`speech_to_text`）和 OCR 功能，删除 `voice_entry_dialog.dart` / `ocr_entry_dialog.dart` / `voice_recording.dart` / `speech_locale_resolver.dart` 及关联测试。`pubspec.yaml` 移除 `speech_to_text` 依赖，SDK 列表同步更新。
- 2026-07-29：Medicine 拍照识别 OCR 引擎从 `google_mlkit_text_recognition` 替换为 `paddle_ocr_native`（PP-OCRv6 / ONNX Runtime）。`pubspec.yaml` 依赖替换；Android 移除 ML Kit 四语言模型、限制 `arm64-v8a` ABI；iOS 最低版本从 13.0 升至 16.0、启用 static framework linkage；移除 `RECORD_AUDIO` / `NSMicrophoneUsageDescription` 残留权限。候选提取算法从纯文本正则匹配重写为空间布局评分（面积 + 位置 + 置信度）。
- 2026-07-30：OCR 引擎初始化失败后状态恢复 + ABI 入口预检。`PaddleOcrEngine` 提取 `ensureInitialized()` 公共方法，init 失败时重置 `_initialized = false` 并 rethrow，允许下次调用重试（原 bug：失败后引擎卡在不一致状态，当前生命周期内 OCR 永久不可用）。`box_scan.dart` 在用户选择 OCR 后、打开相机前调用 `ensureInitialized()` 预检，失败时显示 `_showOcrUnavailableDialog` 并提供切换到 AI 识别的入口。批准号正则 `\w{7,9}` 收紧为 `[A-Za-z0-9]{7,9}`（排除下划线）。新增 l10n 键 `scanOcrUnavailableTitle` / `scanOcrUnavailableMessage` / `scanOcrUnavailableUseAi`。
- 2026-07-28：Record 移动端 header 右上角 `+` 按钮替换为 sparkles 图标 NLP 入口（`SemanticIcons.aiEntry` + `recordNlpHeaderAction` l10n 键），删除原 `RecordAiInputBar` 顶部输入条。NLP 入口直接从 header 调用 `_openNlpDialog`，不再经 `RecordDashboardView` 回调传递。
- 2026-07-28：About 页面新增版本检查功能 l10n 键（`settingsAboutCheckUpdate`、`settingsAboutCheckUpdateChecking`、`settingsAboutCheckUpdateUpToDate`、`settingsAboutCheckUpdateAvailable`、`settingsAboutCheckUpdateFailed`），位于 `settings_*` 分片。帮助页面新增 FAQ 区块和反馈区块 l10n 键（`settingsHelpFaqSectionTitle`、`settingsHelpFaqLoadError`、`settingsHelpFeedbackSectionTitle`、`settingsHelpFeedbackSubject`、`settingsHelpFeedbackUnavailable`、`settingsHelpFeedbackOpenFailed`），删除 Mine 分片中未使用的 `mineHelpFaqTitle` / `mineHelpFaqSubtitle`。
- 2026-07-28：Record quick-entry settings 新增 `recordQuickSettings*` 和
  `recordQuickHelpTooltip` 键，Settings 根页新增 `settingsQuickEntrySubtitle` 次入口文案。
- 2026-08-01：Record quick-entry 图标与长按文案更新。`recordQuickSettingsCustomIconTitle` /
  `recordQuickSettingsCustomIconHint` 从"长按修改图标"改为点击更换；新增 `recordQuickIconChangeAction`、
  `recordQuickIconResetAction`、`recordQuickIconFieldLabel`、`recordQuickHelpLongPressRule` 键，
  供快速记录设置页、创建/编辑表单图标字段与长按类型设置弹窗使用。
- 2026-07-28：Record quick-entry daily flows 新增即时保存/撤销反馈键
  `recordQuickSavedToast`、`recordQuickUndoAction`、`recordQuickUndoFailedToast`，以及症状多选
  `recordFastEntryMultiSelectAction`、`recordFastEntryPartialFailedToast`。这些键位于
  `record_*` 分片，仍通过 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` 生成。
- 2026-07-28：Record quick medication 新增 `recordQuickMedication*` 键，用于 0 药引导、用药选择、
  已记录提示、加载失败和部分失败反馈。运行时通过 `healthContextSnapshotProvider`、
  `medicineReminderListProvider` 和 `CachedDoseLogDataSource` 组合当前药箱、提醒和 dose logs。
- 2026-07-28：Record quick sleep 新增 `recordQuickSleep*` 键，用于开始睡眠 toast、加载失败、
  多 start 选择、合并确认和保持分离/合并操作。运行时通过 `dailyRecordRepositoryProvider`
  拉取前一天与当天的 sleep records，识别 `payload.sleepEvent=start/wake` 临时事实，并在确认合并后写入标准
  `durationMinutes/startAt/endAt` sleep payload。
- 2026-07-28：Record quick meal 新增 `recordQuickMealConfirmTitle`。运行时通过
  `mealQuickImagePickerProvider` 封装 `ImagePicker` + `ImageCompressor`，单击餐食先调用相机，拍照后在
  Record 页确认对话框中补充标题/描述/备注，确认后复用 `dailyRecordRepository.uploadImage` 和
  `DailyRecordCreateInput.attachments` 创建 meal daily record。
- 2026-07-28：Record quick-entry sorting/help/badges 新增 `recordQuickSleepInProgressBadge`，用于快速记录
  睡眠入口角标；排序和显示偏好继续由 `QuickEntryPreferences` + SharedPreferences 管理。
- 2026-07-24：全量翻译质量优化，修复 28 处翻译问题（见 `docs/03-logs/migration-log/2026-07-24.md`），包括语义错误（`轻动作`→`快捷操作`）、copy-paste 错误（`medicineStatusNeedsCheckin` 中英文均与 `medicineStatusStable` 相同）、非标准英语（`Needs lift`→`Needs improvement`）、口语化表达、缺少因果连词等。
- Medicine 主页新增空态文案键：`medicineTodayPlanEmpty`、`medicineSafetyPanelEmptyTitle`、`medicineSafetyPanelEmptyBody`（位于 `medicine_*` 分片）。
- Mine 健康档案分组新增空态文案键：`mineArchiveEmptyTitle`、`mineArchiveEmptyDescription`（位于 `mine_*` 分片）。
- Report 预览空态新增文案键：`reportPreviewBannerMessage`、`reportTrendPreviewTitle/Body`、`reportFindingsPreviewTitle/Body`、`reportSuggestionHistoryPreviewTitle/Body`、`reportExportPreviewTitle/Body`（位于 `report_*` 分片）。
- 日期格式化通过 `lib/core/utils/date_format_utils.dart`（locale 感知 `intl.DateFormat` 封装）。

## 测试与验证

- 集成测试统一使用 Patrol（`patrolTest`）。
- `integration_test/` 分为离线/mock 流程与 Android 模拟器全栈 lane。
- 全栈移动 E2E 当前为本地/手动，不属于 GitHub Actions 流水线。
- 本地验证入口：`scripts/check_doc_coverage.dart`、`scripts/run_daily_checks.dart`、`scripts/run_fullstack_checks.dart`、`scripts/verify_lucent_openapi_sync.dart`。
- GitHub Actions 在构建 APK 前检查生成客户端漂移。
- `luminous-cd.yml` 在 Flutter Web 构建前校验 `LUCENT_BASE_URL` 和 `SENTRY_DSN` secrets 存在性，防止空字符串注入 `--dart-define`。
- Mock repositories 仅存在于 `test/helpers/mocks/`，生产代码使用 repository `signedOut()` 工厂返回静态预览数据。

## 页面脚手架

- 子页直接组合 `FScaffold` + `FHeader` + `ResponsiveContentFrame`。
- 骨架屏通过 `SkeletonScope`/`SkeletonSlot`/`SkeletonText` 细粒度行内骨架，不造假数据。
- 页面级错误使用 `StateErrorView`，加载态使用 shimmer 骨架屏。
- `StateMessageView` 的 `description` 参数为可选（`String?`），仅需标题+图标的场景不再需要传入重复文案。
- 轻量反馈使用 `Toast`（`lib/core/feedback/toast.dart`），不用页面级 `SnackBar`。
- `showAppDialog` 支持 `barrierDismissible` 参数（默认 `true`），需要不可点击遮罩关闭的对话框（如扫码处理遮罩）统一通过 `showAppDialog(barrierDismissible: false)` 调用，不再直接使用底层 `showFDialog`。
- Today 未登录态使用预览 dashboard，不显示“今天还没有记录”引导；摘要指标和快捷入口由前端 view model 基于 dashboard 数据组装。

## ARB 编辑流程（2026-07-20 更新）

- **绝对不要直接编辑 `app_zh.arb` / `app_en.arb`**：这两个文件是由 `lib/l10n/src/` 下分片合并生成的产物。直接编辑的改动会在下次 merge 时丢失。
- 正确流程：编辑 `lib/l10n/src/` 下分片 → `dart scripts/arb_tools.dart merge` → `flutter gen-l10n`。
- `lib/l10n/AGENTS.md` 是 l10n 目录的专用规则文件，详细记录了分片映射表和新模块添加流程。
- 全部 9 个设置子页统一使用 `settingsPageVerticalPadding(context)` 共享函数，不再各自内联响应式三元表达式。

## 2026-07-26 更新

### 网络层 / OpenAPI 客户端

- 官方生成器从 `openapi_retrofit_generator` 切换为 `@openapitools/openapi-generator-cli` 7.22.0 `dart-dio` + `json_serializable` + `copy_with_extension`。
- 生成命令：`openapi-generator-cli generate -i ../Lucent/docs/openapi.json -g dart-dio -o generated/lucent_api -c config.json`（配置含 `enumUnknownDefaultCase=true`）。
- 药品详情 `drugInteractions` 合同改为 `List<DrugbankDrugInteractionDto>`；`CreateDataExportRequestDto` 枚举字段移除 `default`。
- 生成后需运行 `dart run scripts/bootstrap_generated_sources.dart` 生成 `.g.dart` 和 root 代码。

### 国际化

- 新增 `medicineRiskCheckCoverageSummaryManual` / `medicineRiskCheckCoverageSummaryUnavailable`（`medicine_*` 分片），风险检查 coverage 摘要不再硬编码中文。

## 2026-07-28 更新

### 帮助页面自包含化

- 帮助页面不再依赖后端 `support-resources` API，FAQ 内容由本地 Markdown 文件提供（`assets/faq/faq_{zh,en}.md`），按 `## ` 标题切分为多个可折叠 Q&A 项。
- 反馈入口改为前端直接通过 `mailto:` 唤起邮件客户端，邮箱地址通过 `SUPPORT_EMAIL` 环境变量注入。
- 新增 `SUPPORT_EMAIL` 到 `EnvKey` 枚举和 `EnvReader`。
- 帮助页 `_FeedbackSection` 优先读后端 `appInfoProvider` 的 `supportEmail`，回退到编译期 `SUPPORT_EMAIL` 环境变量。

### About 页面版本检查

- About 页新增“检查更新” tile，点击后从 `GET /api/v1/public/app-info` 获取 `latestVersion` 和 `downloadUrl`，与本地 `package_info_plus` 版本通过 `compareSemver()` 比较。
- 状态机：`idle → checking → upToDate / updateAvailable / checkFailed`。发现新版本时自动打开 `downloadUrl`。
- 后端 `AppInfoDataDto` 新增 `latestVersion` 和 `downloadUrl` 字段，通过 `LATEST_VERSION` 和 `DOWNLOAD_URL` 环境变量配置。
- `kFallbackSupportUrl` 从 `https://luminous.app/support` 修正为 `https://github.com/LuoMuLoyal/Luminous`。

## 2026-07-27 更新

### 用药风险检查迁移到后端 API

- 客户端风险检查逻辑全部删除（`risk_checker.dart` 等 6 个文件），改为消费后端 API `GET/POST /api/v1/medicines/risk-check`。
- 生成客户端新增 7 个 risk check DTO 文件，`MedicinesApi` 新增 `medicinesControllerGetRiskCheckV1` / `medicinesControllerRunRiskCheckV1` 方法。
- `MedicineRiskCheckResult` 实体增加 `overallRiskLevel` / `overallRiskScore` / `redFlags` / `overallRecommendation` 字段；新增 `MedicineRiskCheckRecord` / `MedicineRiskCheckRecords` 包装实体。
- 用药安全卡片（`mobile_safety.dart`）重写：消除 FCard 嵌套，改为单一 `FTappable` → `DecoratedBox`；新增最后检查时间显示和 stale 状态指示。
- OpenAPI 导出更新为 104 paths / 224 schemas。
