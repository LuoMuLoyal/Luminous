---
status: active
owner: frontend
updated: 2026-08-31
---

# Design System

本文档是设计系统总览：根主题、Token、组件基线与通用组件约定。历史迁移记录见 [Design_System_Migration](../archive/2026-08-31-doc-governance/Design_System_Migration.md)（已归档）。

## 根主题

- 根主题为 Forui-led，当前通过 `lib/core/theme/family.dart` 暴露主题族目录。
- Forui 0.24.0 移除了除 `neutral` 外的所有预定义颜色方案。`LuminousApp` 现通过 `_familyColorOverride()` 函数在 `FTheme.neutral` 基础上覆盖 `primary` / `primaryForeground` 来模拟原有 `blue / green / orange / red / rose / slate / violet / yellow / zinc` 主题族的 light/dark 颜色变体，再派生 app 的 `ThemeData`。
- 在 app 根注入 `FTheme`，替代 earlier green-skewed auth look。
- **Scaffold 背景色策略（2026-08-27）**：scaffold 背景从纯白（`colors.background` = `#FFFFFF`）改为淡灰（`colors.secondary` = `#F5F5F5`），卡片背景保持纯白（`colors.card`）。通过灰底 vs 白卡的色差实现层次分离，不再依赖边框。`FCard` 默认样式和 `todayCardStyle` 的 neutral/soft/emphasis tone 已去掉边框（`BorderSide.none`）；urgent/warning tone 保留语义色边框（警示而非分隔）。移动端所有 tab 页面的背景色由顶层 `ShellPage` 的 `FScaffold` 统一提供，不再在各页面手动 `DecoratedBox(color: colors.background)`。桌面端 `DesktopTabShell` 内容区背景同样从 `scaffoldStyle.backgroundColor` 取值。桌面端 sidebar 保留纯白背景（`colors.background`），与灰色内容区形成对比。

## Shell 与页面 chrome

- `ShellPage` 直接使用 Forui shell 原语：
  - `FScaffold` 作为页面框架
  - `FBottomNavigationBar` 作为移动端 tab bar
  - `FSidebar` 作为桌面端 rail
  - 保留现有 tab/routing 状态模型
- shell 的 tab 图标、桌面设置/帮助动作、折叠开关、sidebar brand mark 均使用 Forui 自带的 Lucide 图标，替代 Material 图标。
- 共享子页 chrome 也使用 Forui 原语：
  - 子页直接组合 `FScaffold` / `FHeader`
  - `AppBackButton` 使用 Forui 图标按钮
  - 共享状态/对话框壳使用 `FCard` / `FButton` / `FDialog`
- **窗口标题栏自定义**：`window_manager` 设置 `TitleBarStyle.hidden` 隐藏原生标题栏；`DesktopWindowChrome`（`lib/core/widgets/common/control/desktop_window_chrome.dart`）在应用顶部渲染 32px 全宽拖拽区 + 窗口控制按钮（Windows/Linux），位于 `bootstrap.dart` 的 app builder 中以 `Column` 布局包裹整个应用；侧边栏 header 保留 `DragToMoveArea` 作为额外拖拽区；macOS 系统红绿灯按钮自动叠加，sidebar header 左侧加 70px padding 避免重叠。
- **桌面端 CRUD 路由侧面板化**：Record create/detail/edit 和 Medicine reminder new/detail/edit 路由在桌面端使用 `sidePanelPage`（右侧滑入面板，maxWidth 560，半透明遮罩，`barrierDismissible`），移动端降级为 `slidePage`（全屏）。
- **桌面端拖拽支持**：Record 时间线卡片包裹 `Draggable<TimelineDragData>`（仅 `recordId != null` 且桌面端），可拖拽到日历日期单元格（`DragTarget`）改变记录日期；源卡片半透明，目标日期高亮，成功后 `DataChangeTopic.dailyRecords` 触发看板刷新。移动端不启用拖拽。
- **桌面端右键上下文菜单**：Record 时间线卡片、Medicine 用药记录项、Mine 归档项均接入 `FContextMenu.tiles`（桌面端右键触发，移动端长按触发），提供"查看详情"/"编辑"等操作。
- **桌面端 Hover 态**：`DesktopHoverCard` 通过 `MouseRegion` + `AnimatedContainer` 追踪 hover，悬浮时背景/边框变为 primary 色调；移动端 pass-through。
- **桌面端 Settings 主-从布局**：≥1200 使用 `_SettingsMasterDetail`（左导航 260px 高亮当前分组 + 右内容滚动），移动端保持单列长滚动。
- **断点体系**：`compact=360` / `mobile=600` / `tablet=960` / `smallDesktop=1080` / `desktop=1200` / `wide=1400` / `ultrawide=1920`。`LayoutScale` 在 1200–1400 和 ≥1400 使用不同 `maxContentWidth`。`gridCrossAxisCount` 在 ≥1920 使用 6 列。

## Token 清理

- `AppColorTokens` 与 `AppTypographyTokens` 已删除。
- `AppShadowTokens` 也已删除且未替换：
  - 其 level1/level2 值先内联，后从 `app_toast.dart`、`app_state_views.dart`、`today_components.dart` 完全移除，
     以匹配更平的 Forui-first 视觉方向。
  - 后重新引入为 `ElevationTokens`（`lib/core/design/tokens/elevation.dart`），提供 `raised` / `glow` / `shadowColor` 三个方法，暗色模式 alpha 自动补偿。
- 所有 `App*` 前缀已移除（2026-07-09）：
  - `AppSpacingTokens` → `Spacing`
  - `AppRadiusTokens` → `RadiusTokens`（避免与 Flutter `Radius` 冲突；`RadiusTokens` 已于 2026-08-30 退役，圆角统一走 `context.theme.style.borderRadius.*`）
  - `AppTypographyToken` → `TypographyToken`（`TypographyToken` 已于 2026-08-30 退役，字体统一走 `context.theme.typography.body/display.*`）
  - `AppAnimationDurations` → `DurationTokens`（`abstract final class`，避免与 Flutter `Durations` 冲突；现位于 `motion.dart`）
  - `AppBreakpoints` → `Breakpoints`
  - `AppResponsiveSizing` → `ResponsiveSizing`
  - `AppLayoutScale` → `LayoutScale`（值对象）+ `AppLayoutTokens` → `LayoutScaleResolver`（静态工具）
- `lib/core/design/color/semantic_color.dart` 中 `SemanticColor` enum：
  - 6 个语义色：`primary`、`success`、`warning`、`info`、`destructive`、`neutral`
  - 每个 `SemanticColor` 解析为 `SemanticColorPalette`（10 个预计算 tone：`solid`/`foreground`/`muted`/`subtle`/`border`/`shimmerBase`/`disabled`/`borderStrong`/`fill`/`fillStrong`）
  - `SemanticColors` 通过 `FColors.extensions` 注入，暗色模式 alpha 自动补偿
  - 数据/领域层使用 `SemanticColor`；widget 通过 `palette(context)` 或 `solid/muted/subtle/border/shimmerBase/disabled/borderStrong/fill/fillStrong(context)` 解析

## 命名

- 所有 token 类名无 `App` 前缀，通过 barrel `design.dart` 统一导出。
- `Spacing` / `IconSizeTokens`（2026-08-30 起）以语义别名（`xs`/`sm`/`md`/`lg`/`xl`/`xl2`...）为主命名，`level*` 保留为向后兼容别名；`DurationTokens` / `Breakpoints` / `ResponsiveSizing` 仍暴露 `level*` 主命名。
- 字体（2026-08-30 起）：`TypographyToken` 已退役，统一使用 Forui `context.theme.typography.body/display.*`（`FTypeface` scale：`xs3`/`xs2`/`xs`/`sm`/`md`/`lg`/`xl`/`xl2`/`xl3`/`xl4`，touch 主题下对应 10/12/14/16/18/20/22/30/36/48px）。
- 圆角（2026-08-30 起）：`RadiusTokens` 已退役，统一使用 Forui `context.theme.style.borderRadius.*`（`FBorderRadius` scale：`xs2`/`xs`/`sm`/`md`/`lg`/`xl`/`xl2`/`xl3`/`pill`）。需要裸 `double` 时用 `.xxx.topLeft.x`，需要 `Radius` 时用 `.xxx.topLeft`。
- `DurationTokens` 和 `MotionTokens` 为 `abstract final class`（非 `class + const _()`），位于 `motion.dart`。
- `MotionTokens` 提供 4 个 curve token：`entrance`（easeOutCubic）、`exit`（easeInCubic）、`standard`（easeInOut）、`snappy`（easeOut）。
- `IconSizeTokens`（`icon_size.dart`）提供 8 级 icon size（`xs`~`xl4`，`level1`~`level8` 为等价别名；全量值见生成的 [token 清单](generated/design-tokens.md)）。原 level5=32 已拆分为 xl=28（suggestion card）和 xl2=32（avatar/hero）。
- `LucideIconBridge`（`lucide_icon_bridge.dart`，generated）提供 name→IconData 正查 (`resolve`) 和 IconData→name 反查 (`nameOf`)。反查使用预计算 `_reverseMap`（O(1)），而非每次 keystroke O(N) 扫描。
- `ElevationTokens`（`elevation.dart`）提供 `raised(FColors)` / `glow(Color)` / `shadowColor(FColors)` 方法。
- `GradientTokens`（`gradient.dart`）提供 `semanticFill(SemanticColorPalette)` / `tintFade(Color, Color)` 两个命名渐变模式；禁止内联 `LinearGradient`，必须走 token。
- 旧的 `xxs/xs/...` 与 `xs/sm/...` 别名曾在所有调用点迁移后被移除；2026-08-30 起 `Spacing` / `IconSizeTokens` 重新引入语义名（`xs`/`sm`/`md`/`lg`/`xl`/`xl2`...）作为主命名，`level*` 保留为向后兼容别名。

## 主题偏好

- 旧主题调色板变体（`classic / bluePink / yellowGreen`）与 `theme.palette` 偏好已从活跃 UI/state 中移除。
- 当前主题偏好仅为模式（`theme.mode`）。

## 颜色

- **取色分层职责（2026-08-30 起）**：`background`/`card`/`foreground` 三个基础面色是 Forui 主题系统的"画布层"色，走 `context.theme.colors.*` / `SurfaceTokens.*` 按需取用是合理分层（`SemanticColor` 无对应 tone，不强行映射）；语义色（`mutedForeground`/`primary`/`destructive`/`primaryForeground`/`border`）统一走 `SemanticColor.*`（如 `SemanticColor.neutral.solid(context)`、`SemanticColor.primary.solid/foreground(context)`、`SemanticColor.destructive.solid(context)`、`SemanticColor.neutral.border(context)`）。两者职责不同，不是"双轨制"而是"分层职责"。
- **主题取法约定（2026-08-30 起）**：同一方法内对同一来源（`context.theme.style.borderRadius` / `context.theme.typography` / `context.theme.colors`）取用 ≥2 次时，在方法顶部提取一次局部变量（`final borderRadius = context.theme.style.borderRadius`、`final typography = context.theme.typography`、`final colors = context.theme.colors`）再使用，避免重复解引用；单次使用保持内联。
  - `SemanticColor.*.tone(context)`（如 `SemanticColor.neutral.solid(context)`）保持每次调用直接传 `context` 的规范形态，不做变量化。
  - 自带 `context` 参数的内嵌闭包（如 `FBadge.raw(builder: (context, style) {...})`）内照常直接 `context.theme.*`，不引用外层方法提取的变量，避免取值来源漂移。
- `RecordTypeColors`（`lib/features/record/domain/entities/record_type_colors.dart`）已删除。
- 每种记录类型的颜色对现在表示为 `SemanticColor` token，在 widget build 时解析。

## 间距与布局

- 间距使用 `Spacing` token（语义别名 `xs`~`xl8` 为主命名，`level1`~`level12` 为等价别名；全量值见生成的 [token 清单](generated/design-tokens.md)）。
- 硬编码像素值正被项目范围地替换为 token 引用，即使这些 token 值本身在向 Forui 靠拢。
- 断点引用 `Breakpoints` 常量；不出现硬编码 `600`。
- 响应式尺寸 helper 位于 `lib/core/design/layout/responsive_sizing.dart`，用于卡宽、sidebar 宽、grid 高、可缩放 hero/chart
   尺寸。
- 对话框宽度 token 位于 `lib/core/design/layout/layout_scale.dart`：`LayoutScaleResolver.dialogMaxWidth` (360)、
  `wideDialogMaxWidth` (420)、`dialogStandardMaxWidth` (440)。快速记录选择/确认类弹窗统一使用
  `dialogStandardMaxWidth`，避免 `maxWidth: 440` 硬编码分散在多处。

## 组件基线

- status pill：填充 alpha `0.12`，圆角 `context.theme.style.borderRadius.sm`。
- panel 圆角：`context.theme.style.borderRadius.lg`。
- section header 字重：`w600`（设置页分组标题统一用 `SettingsSectionLabel`，见"反馈与通用组件"）。
- icon badge：`IconSizeTokens.xl3`（48px）；text action 图标：`IconSizeTokens.sm`（16px）。

## 路由过渡

- auth 页面：`CustomTransitionPage` + `FadeTransition`（400ms in / 280ms out）。
- drill-down 子页：`SlideTransition` + `FadeTransition`（220ms in / 150ms out）。

## 交互

- Today 与 Mine 页面支持下拉刷新：`RefreshIndicator` + `AlwaysScrollableScrollPhysics`。
- `ShellPage` 使用 lazy tab loading（按当前 index 渲染页面，替代 `IndexedStack`）；仅当前 tab 的 provider 在启动时触发，Riverpod 缓存使切回瞬间完成。

## 图表

- 记录趋势图表使用 `fl_chart`（`LineChart` / `BarChart`），不手写 `CustomPainter` 图表。

## 对话框

- 共享对话框 helper：`showAppDialog` / `DialogShell`（`lib/core/widgets/common/dialog/dialog_shell.dart`），在 `showFDialog` + `FDialog` 之上统一 `maxWidth`/`maxHeight`、共享 padding、滚动行为与键盘 inset。
- `showAppDialog` 支持 `barrierDismissible` 参数（默认 `true`）；需要不可点击遮罩关闭的场景（如扫码处理遮罩）传 `false`。
- `RecordNlpDialog` 与 `MedicineAddPrecheckDialog` 已使用该 helper；新对话框优先走 `showAppDialog`，不裸调 `showFDialog`。

## 反馈与通用组件

- `Toast` 从 Forui theme 值解析颜色与图标处理，不依赖旧兼容主题层。
- `StateMessageView`（`lib/core/widgets/common/feedback/state_message.dart`）的 `description` 参数为可选——仅需标题+图标的空态/错误态（如帮助页）不传重复描述文案。
- `StateErrorView`（同文件）通过 `LayoutBuilder` 检测父级是否有界高度：无界时 fallback 到 `SizedBox(height: 320)`，使 `SingleChildScrollView` 在 `SliverList` 或无 `Scaffold` 的测试环境中不会因 `Viewport` 获得无界高度而崩溃。
- `_LoadingTimeoutWrapper`（`lib/core/widgets/common/feedback/page_state.dart`）同样以 `LayoutBuilder` 检测：有界高度时用 `Expanded` 填充，无界高度时用 `mainAxisSize: MainAxisSize.min` 不强制 `Expanded`，避免子 widget 的 `Expanded` 在无界 `Column` 中触发 `RenderFlex` 异常。
- `IconActionButton`（`lib/core/widgets/common/control/icon_action_button.dart`）是全 App 唯一的顶栏图标按钮实现，`showBadge` 在右上角叠加红点（未读消息提醒等）；各模块顶栏统一引用 core 版本。
- `showForuiDatePicker`（`lib/core/widgets/common/control/date_picker.dart`）是全 App 共享的日历日期选择器，基于 `showFDialog + FCalendar.grid` 封装，统一记录/提醒/健康表单等所有日期选择入口。
- 设置页统一引用 `settingsPageVerticalPadding(BuildContext)`（响应式垂直 padding）与 `SettingsSectionLabel`（分组标题：`typography.body.xs` + `w600` + `SemanticColor.neutral.solid(context)` + `Spacing.level2` 水平 padding），不再各自手写响应式三元表达式或分组标题实现。

## Auth 与表单

- auth 页面（login/register/forgot-password/change-email/account-settings）直接组合 `FButton` / `FTabs` / `FToast` / `FDialog`；`auth_shell.dart` 仅保留为薄 page-shell/card 布局 helper。
- 主表单页模式：`Form` + `GlobalKey<FormState>` + `FTextFormField.email/password` + `AutovalidateMode.onUserInteraction`。
- 表单验证经 `AuthValidationMixin` 与 `CooldownTimerMixin` 共享（`lib/features/auth/presentation/providers/shared/auth_form_mixin.dart`），`RegisterFormNotifier` / `PasswordResetNotifier` / `LoginFormNotifier` 均使用；email 校验委托 `email_validator` package，auth provider 内不保留手写 email regex。
- register form 带真实 Forui `FCheckbox` terms/privacy consent gate，用户接受前禁用账户创建。
- account settings 页面按 `FTabs` 分为 overview/profile/email/identity 与 password/delete-account 两个 pane，各 pane 渲染在单个外层 `FCard` 内。

## 输入控件

- 输入类控件统一 Forui：`FTextField` / `FTextFormField` / `FSelect` / `FSwitch` / `FCheckbox`；不新增 Material `TextFormField` / `DropdownButton` / `Switch` / `Checkbox`。

## Markdown 渲染（2026-08-03 起，2026-08-17 F-4 扩展）

- `lib/core/design/tokens/markdown_style.dart` 为全 App Markdown 渲染样式的唯一入口（`MarkdownStyle` 抽象类），所有 `MarkdownBody` 调用点禁止本地 `fromTheme(...).copyWith(...)` 漂移。
- 两套预置：
  - `MarkdownStyle.legal(context)` — 正式文档（法律文书详情、帮助页 FAQ）：正文 sm (16px) / 行高 1.7、h1-h3 强层级递减、中性 `SemanticColor.neutral.border(context)` 引用左条。
  - `MarkdownStyle.ai(context, {background, paragraphWeight, emphasizeLinks})` — AI 生成内容（聊天气泡、Today 摘要/建议、报告总结）：正文 sm / 行高 1.6、`SemanticColor.primary.solid(context)` 引用左条与列表 bullet、代码块圆角 + 等宽字体 + 主题背景；`background` 传入气泡/容器底色使代码背景自适配，`paragraphWeight` 支持摘要 w600 / 报告总结 w700 覆盖。
- F-4 扩展（2026-08-17，仅 `MarkdownStyle.ai`）：
  - 标题完整字号阶梯 h1-h6：h1→lg (w700)、h2→md、h3→sm（同正文、加粗区分）、h4→xs、h5→xs2、h6→xs2（降一档字重收尾），各带递减 `*Padding`。
  - 列表缩进走 `Spacing` token（level5=20/级），bullet 与文字间距 `listBulletPadding` level2=6。
  - 引用块：primary 4px 左侧色条 + `SemanticColor.primary.subtle` 底色（深浅色自动适配），四边 padding。
  - 表格：`tableColumnWidth: IntrinsicColumnWidth` —— flutter_markdown_plus 检测到该列宽类型时自动把表格包进横向 `SingleChildScrollView`，窄屏可横向滚动而不是挤压列；表头 `colors.secondary` 背景 + `SemanticColor.neutral.border(context)` 边框不变。
  - **代码块限制（已记录）**：flutter_markdown_plus 把 `pre` 硬编码为横向 ScrollView，样式表无折行开关；折行会破坏代码缩进，故保持库默认横向滚动，不硬造自定义 builder。
- 链接契约（F-4，仅助手消息气泡）：链接默认不自动跳转；点击先弹确认对话框（`assistantMarkdownLink*` 文案，取消复用 `commonCancel`），确认后经 `ExternalUrlLauncher` 打开；仅放行 http/https 方案。表格列数 / 链接域白名单硬校验规则未定，暂不做。
- 两套均基于 `Spacing` / `SemanticColor` 与 Forui `FColors` / `context.theme.typography.body/display.*` 解析（圆角走 `context.theme.style.borderRadius.*`），深浅色自动适配；代码块/行内代码/表格/分割线/链接统一接入主题 token。
- 全部 6 处渲染点已迁移：legal 2 处（`legal/detail.dart`、`settings/help.dart`）+ ai 4 处（`assistant/flowui_adapter.dart` 的 `FlowMessage` custom part、`today/summary.dart`、`today/suggestion_interactive.dart`、`report/ai_summary.dart`）。
