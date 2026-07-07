# Luminous Current State

Last updated: 2026-07-07

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理
- [[00-current/Repository_Split]] — 仓库划分
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Work_Phase_Guide]] — 阶段总纲
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 已完成基线

- 历史 completed baselines 与 audit remediation 已归档：[[04-archive/current-state-archive]]
- 文档治理现在带有 warning-only 的路径映射检查：`docs/doc-map.yaml` + `tool/check_doc_coverage.dart`
  会在 `pre-commit` 与 `tool/run_daily_checks.dart` 中提醒本次代码改动需要复核哪些文档。
- AI 开发工作流增强已接入仓库级入口：
  - 编辑器助手入口：`.github/copilot-instructions.md`
  - agent 入口：`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`
  - MCP 入口：`.cursor/mcp.json`
  - VS Code 项目设置已启用 `dart.mcpServer`
  - app-side AI 试验 seam 建立在 `lib/core/ai/`，默认关闭，不替代 Lucent-backed
    assistant/report 生产链路
  - 编译期环境变量统一通过 `lib/core/config/env_keys.dart` + `env_reader.dart`
    读取，Web/JS 构建不再依赖动态 `String.fromEnvironment(key)`；`.env.example`
    现在同时承载 app 运行时与 full-stack E2E 所需键。
- Forui-first 编码统一性优化完成：
  - 页面骨架统一：`PageScaffold`（26 子页）+ `AppTopBar`（5 Tab 根页）+ `AuthShell`（5 Auth 页）。
  - Material 组件全面迁移：按钮、进度、InkWell、图标、对话框、输入、选择、列表、卡片、Chip、导航、Tab、Drawer 等。
  - 颜色系统：所有 `Color(0xFF...)` 和 `Theme.of(context).colorScheme.*` 已替换为
    `context.theme.colors.*` / `AppColors` 语义 token。
  - 排版系统：所有 `textTheme.*` 已替换为 `AppTypographyToken`。
  - `Theme.of(context).brightness` 已替换为 `MediaQuery.platformBrightnessOf(context)`。
  - 合理遗留：`RefreshIndicator`（Forui 未提供等效组件）。
  - 已迁移的剩余 Material 组件：
    - `Tooltip` → `FTooltip`（12 处）
    - `SegmentedButton` → `FSelectGroup`/`FSelectGroupItemMixin.radio`
    - `FloatingActionButton.extended` → `FButton`（Record NLP FAB）
    - `showDatePicker`/`showDateRangePicker` → `FDateField.calendar`/`FCalendar.grid`
    - `showTimePicker` → `FTimeField.picker`/`FTimePicker`
  - 已替换的手写组件：
    - Record 时间轴 → `timeline_tile`（桌面 `RecordTimelinePanel` + 移动 `RecordMobileTimeline`）
    - 通知列表滑动删除 → `flutter_slidable`（替代 `Dismissible`）
- 基础组件优化完成：
  - `AppDivider` 支持 `width` 参数，清理冗余默认色调用。
  - `AppStateViews` 拆分为 `app_state_message.dart` + `app_skeleton.dart`，修复 tone 语义，
    `AppInlineSkeletonCircle` 自动 shimmer。
  - `AssistantStateCard` 删除，合并到 `AppStateMessageView(maxWidth: 560)`。
  - `ResponsiveContentFrame` 支持 `padding` 覆盖。
  - `PageScaffold` 支持 `titleWidget` 与 `headerStyle`。
- Phase 1 可见问题修复进行中：
  - Today 页视觉层级重构完成：
    - 根主题现改为直接使用 Forui 内置主题族：`theme.family` 持久化当前选择，`LuminousApp` 与测试主题统一从 `lib/theme/theme.dart` 的主题族目录映射到 stock `FThemes.*`；默认族为 `blue`，不再保留手写 sky-blue 定制色值。
    - 移动端 Today 信息顺序调整为 `summary → priorities → AI summary → recommendations → todos`，优先事项不再被 AI 卡片压在首屏下方。
    - Today 概览 / 优先事项 / AI summary / recommendation / todos 现在使用分层卡片语气（emphasis / soft / neutral），recommendation 的 loading 改为行骨架屏，失败态改为紧凑 inline retry。
    - 根据视觉反馈，Today 条目卡片底色已统一收回纯白，只保留当前主题色边框和语义按钮，不再使用淡色填充。
    - 顶部 `AI chat` 入口和通知按钮统一收敛到 Forui 语义按钮变体；优先事项详情移回主内容列，右侧仅保留行动按钮，降低拥挤感。
  - Report 页指标卡移动端 `BOTTOM OVERFLOWED BY 2.0 PIXELS` 已修复。
  - Today 页优先事项卡片右侧 action pill 文字颜色已修复，不再与背景融为一体；宽度改为 `IntrinsicWidth` 自然撑开，避免 “去服用” / “去喝水” 截断。
  - Today 页 AI 日总结 signed-out / disabled 空态 footer 已移除，只保留单条 bullet 提示，避免重复文案。
  - 登录提示弹窗（尚未登录 / 是否去登录）的取消/去登录按钮已改为横向布局，去登录位于右侧。
  - 通知页返回后若接口返回 401，`LucentDioClient` 现在会清理本地 session 并通过回调同步到 `authSessionProvider`，避免 UI 卡在“已登录但请求持续失败”的状态。
  - Today 页顶部标题从 36px 降到 30px，与其他 Tab 根页统一。
  - 胶囊按钮统一收敛到 Forui 按钮语义与圆角体系，不再依赖单独的 `button_styles.dart` 主题定制文件。
    - 删除 `AppPillButton` 中间层；Today/Record/Medicine/Report 顶部与操作行中的胶囊按钮
      全部改用标准 `FButton`，依靠主题默认获得一致的 pill 外观，仅在需要处保留内边距/最小宽度覆盖。
    - Today 页“AI 对话”、优先事项“去服用/去喝水”、Report 周期选择 pill、Record 日期选择 pill、
      Record 顶部 action chips、Medicine workspace header action chip 已统一。
  - Mine / Settings 主题设置现为双层偏好：
    - 显示模式仍保留 `system / light / dark`
    - 新增 `theme.family`，可在 `blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc` 间切换
    - 设置主页摘要显示为 `模式 · 主题族`，高级设置恢复默认值时会同时重置两项
    - 根据移动端截图反馈，将 touch 模式下 `md`/`sm`/`lg` 按钮的 `minHeight` 与垂直内边距各下调 4px，
      使胶囊按钮看起来更紧凑。
    - 扫描并继续统一了剩余自定义圆角的胶囊操作按钮：Medicine workspace quick actions、Search 源切换、
      Record OCR 选项卡、Record 新建记录 chip。当前仅保留搜索条 `lg`、圆形图标按钮、卡片/静态 badge、
      以及 filter chips 的原有圆角。
    - Record 页“快速记录”网格已重构为 2×3 布局，底部新增占满宽度的“备注”按钮；格子改用 `FTappable` +
      `FAvatar` + `AppDivider`，去掉重复 outline 边框与手写分隔线；未启用项显示锁图标并降低透明度。
    - 修复 Record 快速记录“用药”点击断言失败：`_handleQuickAction` 现在对无法映射到 `DailyRecordKind` 的类型
      （如 medication）统一打开通用创建页，并将登录检查前置，使七个快速记录项的登录提示行为一致。
    - Record 页日期选择器重构：移除顶部左右步进按钮，改为内联 `FLineCalendar` 横向滑动选日期；
      右侧保留日历按钮，点击弹出 `FCalendar.splitGrid` 月/年网格选择器。为彻底压缩高度并避免
      `FLineCalendar` 默认 `ItemContent` 在不同屏幕下 overflow，使用自定义 `builder` 绘制紧凑日期项：
      字号调整为 weekday 11 / date 14，垂直间距 4 / 2，保留 today 指示点与选中/禁用装饰；
      自定义项用 `SizedBox.expand` 占满 `FLineCalendar` 的 item 宽度，使选中态背景接近正方形。
      `RecordDateBar` 高度改为固定 48px，避免 MediaQuery 在键盘/旋转时引发重建。
    - Record 页 UI 紧凑化与顶部按钮对齐：
      - `AppTopBar` 的 trailing 操作区改为与标题垂直居中对齐，解决右上角加号按钮偏高问题。
      - 移动端 Record 加号按钮（iconOnly + emphasized）圆角从 pill 改为 10px 圆角矩形，视觉更克制。
      - `RecordPage` body 顶部内边距改为按屏幕高度连续计算（`height * 0.012`，clamp 10~16），
        减小标题与日期条之间的空白。
      - `RecordQuickEntryPanel` 尺寸改为按屏幕短边连续计算（`(shortEdge - 600) / 280`，clamp 0~1），
        标题与卡片间距、格子垂直内边距、头像尺寸、备注按钮内边距和分隔线高度均随屏幕尺寸平滑缩放，
        避免在小屏设备上快速记录区占用过多空间。
- 裸 catch 修复完成（全项目，约 75 处）：所有 `catch (_)` 改为 `catch (e)` 并添加 `debugPrint` 日志；`flutter analyze` 通过。
  重复组件名提取已于三审修复中完成（7 类 24 处 → 共享文件），动画时长统一已于一审修复中完成。
- 清除 `unnecessary_import` 警告（40 个文件）：删除 `app_design.dart` 已 re-export 的冗余 `app_breakpoints.dart` import 行；`flutter analyze` 通过。
- 应用图标规范化：图标源文件从 `assets/icons/Luminous-icon.png` 迁移到 `assets/icon/app_icon.png`，通过 `flutter_launcher_icons` 生成全平台图标；`pubspec.yaml` 和 `auth_branding.dart` 路径已同步更新。
- 启动屏统一（flutter_native_splash）：通过 `flutter_native_splash` 自动生成全平台启动屏素材（Android/iOS/Web），亮色背景 `#FFFFFF` + 暗色背景 `#171717`，图标使用 `assets/icon/app_icon.png`。修复了暗色模式白屏问题（`values-night/colors.xml` 全部改为 `#171717`），统一了 `styles.xml` 引用，删除了旧的手写矢量 XML（`splash_wordmark_icon.xml`、`launch_screen.xml`）和 Web 端旧 HTML splash。
- 一审修复完成（2026-07-06）：
  - **AppRoutes 全覆盖**：`AppRoutes` 从 5 个常量扩展到全部路由路径（Shell tabs / Auth / Account / Settings / Record / Medicine / Mine / Notifications / Assistant / Scan），所有路由定义与导航调用中的硬编码字符串替换为常量引用；`AppBackButton` 默认 fallback 从不存在的 `/today` 修正为 `AppRoutes.home`。
  - **动画时长统一**：`router_helpers.dart` 中的 4 个路由过渡时长常量移入 `AppAnimationDurations`（`authPageTransitionIn/Out`、`crudPageTransitionIn/Out`），`authFadeIn` 重命名为 `authContentFadeIn` 以区分路由过渡与内容入场动画；所有时长集中管理。
  - **Formz 用法统一**：移除 `validators.dart` 中 5 个 `FormzInput` 子类继承和返回空格的实例 `validator`，改为 `abstract final class` + 纯静态方法；移除 `formz` 包依赖。
  - **AppBreakpoints.assistantContent**：确认在 3 个文件中使用中，无需移除。
  - **18 个 pre-existing 测试失败修复**：修复全部 18 个测试失败，包括路由常量迁移导致的不匹配（`app_back_button_test`）、provider 测试缺少 override（`today_dashboard_provider_test`、`auth_session_gate_test`）、shimmer 动画导致 `pumpAndSettle` 超时（`shell_page_test`、`today_ai_card_test`、`mine_page_test`、`medicine_page_test`）、真实 Dio 调用导致 pending timer（`today_ai_card_test`、`shell_page_test`、`medicine_page_test`、edit page tests）、signed-out 测试缺少 `mineRepositoryProvider` override（`mine_page_test`）、报告日期硬编码（`report_page_test`）。`flutter test` 896 passed, 0 failed。
  - **OpenAPI 客户端重新生成 + 调用方适配**：根据 Lucent 07-01 ~ 07-06 期间的 API 变更（Security PIN 替代 2FA、Daily Records 分页参数类型从 `String` 改为 `num?`/`DailyRecordKind?`、`UserSettingsDataDto` 新增必填 `securityPin` 字段），重新生成 `packages/lucent_openapi` 客户端并适配所有调用方。修复 `daily_record_remote_data_source.dart` 的参数类型映射，6 处测试文件补充 `securityPin` 必填参数。`flutter analyze` + `flutter test` 896 passed, 0 failed。
  - **Record 过滤器改用标准 FButton**：`_FilterChip` 从 `FButton.raw` + 自定义 `.delta(decoration: ...)` 改为标准 `FButton` + `variant: FButtonVariant.outline` + `selected: selected`，完全依赖 Forui 内置变体系统处理选中/未选中视觉差异；移除自定义 `AppColors` 参数，locked 标签改用 `suffix` 参数传入。
  - **Forui 主题定制文件已移除**：当前不再保留 `button_styles.dart` 或手写 colors/theme overrides，直接使用 Forui 内置主题族与标准按钮语义。
  - **Record 过滤器横向布局修复**：`FButton` 默认 `mainAxisSize: MainAxisSize.max` 导致在 `Wrap` 中撑满宽度，添加 `mainAxisSize: MainAxisSize.min` 恢复横向排列。
  - **primary FButton 黑底黑字修复**：Forui `FTypography` 的 `TextStyle` 携带 `color: colors.foreground`（近黑），当 `Text` 使用 `AppTypographyToken` style 时会覆盖 `FButton` 的 `DefaultTextStyle` 设置的 `colors.primaryForeground`（白）。修复 `RecordHeaderActionChip`、`MedicineHeaderActionChip` 中 `Text` 的 style，移除 `AppTypographyToken` 引用改为 `TextStyle(fontWeight: FontWeight.w700)`，让 `FButton` 的前景色正确传递。FAB 添加 `mainAxisSize: MainAxisSize.min`。
  - **通知增强**：
    - 免打扰时段：`NotificationSettingsState` 新增 `dndEnabled` / `dndStartTime` / `dndEndTime`，DND 子页面使用 `FTimeField.picker` 选择时段；`MedicineReminderNotificationPlanner` 在 `plan()` 中过滤落在 DND 窗口内的通知（支持跨午夜）。
    - 通知声音/振动：`NotificationSettingsState` 新增 `notificationSoundEnabled` / `notificationVibrationEnabled`，在 planner 中与 `MedicineReminderSoundPreference` 取 AND；`LocalNotificationGateway` 的 `enableVibration` 参数独立控制振动。
    - 用药提醒提前量：`NotificationSettingsState` 新增 `reminderAdvanceMinutes`（0/5/10/15/30），planner 在 `scheduledAt` 上做 `subtract`；通知设置页通过 `showFSheet` 底部弹窗选择。
  - **无障碍设置**：
    - `AccessibilitySettingsController`（纯前端 SharedPreferences）：`FontSizePreference`（small/standard/large/extraLarge）、`reduceAnimations`、`highContrast`。
    - `app.dart` 的 `builder` 注入 `MediaQuery.copyWith(textScaler, accessibleNavigation)`，高对比度通过 `FColors.copyWith` 重建 `FThemeData`。
    - 无障碍设置页面：字体大小用 `FTileGroup` + `SettingsSelectionIcon` 选择，减少动画和高对比度用 `FSwitch` tile。
    - 设置页 General section 新增无障碍入口，高级设置"恢复默认"同时重置无障碍偏好。
- 桌面侧边栏重构完成：
  - 移除自定义折叠/展开机制（`ShellSidebarProvider` + `SharedPreferences` 持久化 + `AnimatedContainer`），改为纯 Forui `FSidebar` 原生实现。
  - 去边框化：侧边栏样式从自定义 `FSidebarStyle`（含 `Border.all` + `borderRadius.xl`）改为 `BoxDecoration(color: background)`，继承 Forui 极简主义美学。
  - 侧边栏新增 `FSidebarItem.children` 展开子项：记录、用药、我的、设置四个顶层项可展开显示子导航（共 15 个子项），Forui 原生箭头展开/收起。
  - 内容区新增 Forui `FBreadcrumb`：两级面包屑（App 名称 → 当前 Tab），替换原 `FCard.raw` 包裹。
- 数据与存储设置：
  - 新增 `DataStorageSettingsController`（纯前端 SharedPreferences）：`DataRetentionPeriod`（30 天 / 90 天 / 永久）、`ImageQualityPreference`（标准 / 省流）、`SyncPreference`（仅 Wi-Fi / Wi-Fi 与移动网络）。
  - 新增 `DataStorageSettingsPage`：三段式选择列表（离线保留 → 图片质量 → 同步设置），复用 `SettingsSelectionIcon` + `settingsSubpageTileGroupStyle`。
  - 设置主页新增「数据与存储」分组（通用与通知之间），摘要显示当前保留期；高级设置「恢复默认」同步重置数据存储偏好。
  - 桌面侧边栏设置子项新增「数据与存储」入口。
- 健康档案快捷入口：
  - 设置页通用分组新增「健康档案」入口（`heartPulse` 图标），直达 mine 功能区的健康档案编辑页。
- 二审修复完成（2026-07-07）：
  - **超长 build 方法重构**：`_DrugBoxSection.build()` 拆分为 `_DrugBoxHeader`、`_DrugBoxSubtitle`、`_DrugBoxContent` 三个独立 Widget，消除 566 行超长方法。
  - **重复 badge 代码消除**：新增共享 `TintedStatusBadge` 组件，替换 `medicine_mobile_drugbox_section.dart`、`reminder_log_panels.dart` 中 3 处几乎相同的内联 `FBadge.raw` 代码（每处约 30 行），同时消除 `0.12 > 0.5` 死代码条件。
  - **ref.read() 误用修复**：`record_nlp_dialog.dart` 中 `ref.read(provider).draft` 改为使用已 watch 的 `state.draft`。
  - **硬编码睡眠时长配置化**：提取 `_sleepDurationOptions` 命名常量，switch 分支改为 for 循环，TODO 注释更新为正式文档注释。
- 三审修复完成（2026-07-07）：
  - **重复私有组件提取**：新建 `app_shared_widgets.dart` 共享文件，提取 6 个跨文件重复的私有组件（`VerificationCodeField` 4 文件、`MineEditFormLoading` 4 文件、`SettingsSectionLabel` 6 文件、`SheetDragHandle` 2 文件、`SoftIcon` 2 文件、`IconActionButton` 1 文件），共 27 处引用替换为共享组件。
  - **Mock 死代码清理**：删除从未引用的 `MockMedicineSearchRepository`，测试 mock 移入测试文件私有类。
  - **强制解引用清理**：清理 18+ 处最危险的 `!` 强制解引用，包括 `response.data!`（无 null check）、`data.nutritionEstimate!`（6 处重复）、`content.summary!/footer!`、`resource.actionUrl!`、`result.errorMessage!`、`sleepDeepMinutes.value!` 等，改用 Dart 3 `case final x?` 模式匹配或局部变量。
  - **日历高度跳动修复**：`RecordDateBar` 高度从 `MediaQuery.sizeOf(context).height * 0.055` 改为固定常量 48.0，消除键盘弹出/旋转时的不必要重建。
  - **硬编码日期范围文档化**：`_minDate`/`_maxDate` 添加文档注释。
  - **测试全量修复**：修复 5 个测试失败（898 passed, 0 failed），包括测试主题引用错误（`FThemes.neutral` → 实际 app 主题）、设置页主题摘要显示"模式 · 主题族"组合标签、退出登录按钮缺少 test key。
  - **审查文档清理**：删除三份已完成的审查报告，暂缓项写入 `TODO.md`。
- 开发者选项扩展完成（2026-07-07）：
  - **API 端点切换**：`DeveloperSettingsController` + `ApiEndpoint` 枚举（local / staging / production / custom），`lucentBaseUrlProvider` 改为响应运行时端点选择，切换后自动 logout。仅 debug 可见，release 强制 production。
  - **日志级别**：引入 `talker_flutter` 替代原始 `AppLogger`，`talkerProvider` 提供全局 Talker 实例，Release 静默，Debug 按级别过滤。`applyLogLevelToTalker()` 运行时切换 TalkerLogger 过滤级别。
  - **功能开关**：`FeatureFlagsController` + `FeatureFlagsSettingsPage`（6 个 flag：端侧 AI Runtime / AI Runtime 提供方 / GenUI 渲染 / 流式输出 / 条码扫描 / PDF 导出），从编译期 env 种子初始化，运行时可覆盖。路由 `/settings/more/feature-flags`。
  - **高级设置页面**：追加「开发者选项」分组（`kDebugMode` 条件渲染），「恢复默认设置」同时重置 developer settings + feature flags。
- 文件命名与结构大重构完成（2026-07-07）：
  - **AGENTS.md 新增 File Naming Rules**：禁止文件名重复所在目录/feature 名称，散文件归子目录，Repository 实现统一命名，测试文件镜像源文件名。
  - **全项目去前缀**：~370 个文件重命名，去除目录名/feature 名前缀（`lib/core/network/lucent_*` → `lucent_` 去除，`lib/core/design/app_*` → `app_` 去除，`lib/core/widgets/common/app_*` → `app_` 去除，`lib/app/router/router_*` → `router_` 去除，全部 14 个 feature 的 `{feature}_*` → 前缀去除）。
  - **Repository 命名统一**：`lucent_{feature}_repository.dart` → `lucent_repository.dart`，`mock_{feature}_repository.dart` → `mock_repository.dart`，多后端 feature 保留子域名（`lucent_ai_repository.dart`、`lucent_ai_summary_repository.dart` 等）。
  - **散文件归目录**：14 个直接放在 `presentation/widgets/` 或 `presentation/` 根目录的文件归入 `shared/`、`dialogs/`、`utils/` 子目录。
  - **测试文件同步重命名**：85 个测试文件跟随源文件重命名。
  - `flutter analyze` — No issues found! `flutter test` — 898 passed, 0 failed。
- Medicine 安全检查三层展示 + Report 门控透明度完成（2026-07-07）：
  - **Medicine 三层展示**：风险检查页从二态（有/无风险）重构为三层视觉语义：Tier 1 已确认风险（红色 `destructive`）、Tier 2 已确认安全（绿色 `primary`，附"不等于绝对安全"免责声明）、Tier 3 未覆盖/不确定（黄色 `secondary`）。严重度颜色从全部 `primary` 改为按 high/medium/info 分级。添加前风险检查弹窗新增检查范围区块（过敏交叉 / 相互作用 / 禁忌）。
  - **Report 门控透明度**：数据不足时不再只显示 "--" 占位。新增 `_DataInsufficientBanner` 横幅（当评分或全部指标为 `insufficientData` 时显示），重点发现空态增加引导文案，导出区在数据不足时显示原因提示。
  - `flutter analyze` — No issues found! `flutter test` — 898 passed, 0 failed。`dart run tool/run_daily_checks.dart` — exit code 0。
- 测试依赖引入完成（2026-07-07）：
  - **mocktail** ^1.0.5 — 零代码生成 mock 库，新增 `test/helpers/mocks.dart` 提供 8 个常用接口的 mocktail 实现
  - **network_image_mock** ^2.1.1 — `test/helpers/test_helpers.dart` 新增 `mockNetworkImages()` 包装函数
  - **alchemist** ^0.14.0 — Golden 测试框架（替代 discontinued 的 `golden_toolkit`），新建 `test/golden/` 目录，3 个 golden 测试 + 6 个基线图
  - **patrol** ^4.6.1 — 原生系统交互 E2E 框架，`patrol_cli` v4.4.0 全局安装，新建 `integration_test/patrol/` 目录 + `patrol.yaml` 配置
  - `flutter analyze` — No issues found! `flutter test` — 904 passed, 0 failed。
- Mine 档案完整度提示完成（Brainstorm E 项）：
  - 新增 `MineCompletenessNotice` 组件，从 `MineProfileSnapshot` 现有字段派生缺失项（基础信息 / 过敏史 / 当前用药），每项展示安全影响说明 + "去完善"操作按钮
  - 档案完整时自动隐藏；未登录时不渲染
  - 修复 Archive Section 状态 badge 颜色： "待补充" 从 `primary` 改为 `destructive`，"已完善" 从 `primary` 改为 `mutedForeground`
  - 新增 10 个 ARB key（zh + en），3 个新测试
  - `flutter analyze` — No issues found! `flutter test test/mine/page_test.dart` — 14 passed, 0 failed

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
