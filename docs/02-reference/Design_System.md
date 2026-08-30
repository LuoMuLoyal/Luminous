---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-30
---

# Design System

本文档保留设计系统总览与 Token。

子文档：

- [[Design_System_Components]]
- [[Design_System_Migration]]

## 根主题

- 根主题为 Forui-led，当前通过 `lib/core/theme/theme.dart` 暴露主题族目录。
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
- **窗口标题栏自定义**：`window_manager` 设置 `TitleBarStyle.hidden` 隐藏原生标题栏；`DesktopWindowChrome`（`lib/core/widgets/common/desktop_window_chrome.dart`）在应用顶部渲染 32px 全宽拖拽区 + 窗口控制按钮（Windows/Linux），位于 `bootstrap.dart` 的 app builder 中以 `Column` 布局包裹整个应用；侧边栏 header 保留 `DragToMoveArea` 作为额外拖拽区；macOS 系统红绿灯按钮自动叠加，sidebar header 左侧加 70px padding 避免重叠。
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
  - 后重新引入为 `ElevationTokens`（`lib/core/design/elevation.dart`），提供 `raised` / `glow` / `shadowColor` 三个方法，暗色模式 alpha 自动补偿。
- 所有 `App*` 前缀已移除（2026-07-09）：
  - `AppSpacingTokens` → `Spacing`
  - `AppRadiusTokens` → `RadiusTokens`（避免与 Flutter `Radius` 冲突；`RadiusTokens` 已于 2026-08-30 退役，圆角统一走 `context.theme.style.borderRadius.*`）
  - `AppTypographyToken` → `TypographyToken`（`TypographyToken` 已于 2026-08-30 退役，字体统一走 `context.theme.typography.body/display.*`）
  - `AppAnimationDurations` → `DurationTokens`（`abstract final class`，避免与 Flutter `Durations` 冲突；现位于 `motion.dart`）
  - `AppBreakpoints` → `Breakpoints`
  - `AppResponsiveSizing` → `ResponsiveSizing`
  - `AppLayoutScale` → `LayoutScale`（值对象）+ `AppLayoutTokens` → `LayoutScaleResolver`（静态工具）
- `lib/core/design/semantic_color.dart` 中 `SemanticColor` enum：
  - 6 个语义色：`primary`、`success`、`warning`、`info`、`destructive`、`neutral`
  - 每个 `SemanticColor` 解析为 `SemanticColorPalette`（10 个预计算 tone：`solid`/`foreground`/`muted`/`subtle`/`border`/`shimmerBase`/`disabled`/`borderStrong`/`fill`/`fillStrong`）
  - `SemanticColors` 通过 `FColors.extensions` 注入，暗色模式 alpha 自动补偿
  - 数据/领域层使用 `SemanticColor`；widget 通过 `palette(context)` 或 `solid/muted/subtle/border/shimmerBase/disabled/borderStrong/fill/fillStrong(context)` 解析

## 命名

- 所有 token 类名无 `App` 前缀，通过 barrel `design.dart` 统一导出。
- `Spacing` / `DurationTokens` / `IconSizeTokens` / `Breakpoints` / `ResponsiveSizing` 均暴露 `level*` 主命名。
- 字体（2026-08-30 起）：`TypographyToken` 已退役，统一使用 Forui `context.theme.typography.body/display.*`（`FTypeface` scale：`xs3`/`xs2`/`xs`/`sm`/`md`/`lg`/`xl`/`xl2`/`xl3`/`xl4`，touch 主题下对应 10/12/14/16/18/20/22/30/36/48px）。
- 圆角（2026-08-30 起）：`RadiusTokens` 已退役，统一使用 Forui `context.theme.style.borderRadius.*`（`FBorderRadius` scale：`xs2`/`xs`/`sm`/`md`/`lg`/`xl`/`xl2`/`xl3`/`pill`）。需要裸 `double` 时用 `.xxx.topLeft.x`，需要 `Radius` 时用 `.xxx.topLeft`。
- `DurationTokens` 和 `MotionTokens` 为 `abstract final class`（非 `class + const _()`），位于 `motion.dart`。
- `MotionTokens` 提供 4 个 curve token：`entrance`（easeOutCubic）、`exit`（easeInCubic）、`standard`（easeInOut）、`snappy`（easeOut）。
- `IconSizeTokens`（`icon_size.dart`）提供 8 级 icon size：level1=12, level2=16, level3=20, level4=24, level5=28, level6=32, level7=48, level8=64。原 level5=32 已拆分为 level5=28（suggestion card）和 level6=32（avatar/hero）。
- `LucideIconBridge`（`lucide_icon_bridge.dart`，generated）提供 name→IconData 正查 (`resolve`) 和 IconData→name 反查 (`nameOf`)。反查使用预计算 `_reverseMap`（O(1)），而非每次 keystroke O(N) 扫描。
- `ElevationTokens`（`elevation.dart`）提供 `raised(FColors)` / `glow(Color)` / `shadowColor(FColors)` 方法。
- `GradientTokens`（`gradient.dart`）提供 `semanticFill(SemanticColorPalette)` / `tintFade(Color, Color)` 两个命名渐变模式；禁止内联 `LinearGradient`，必须走 token。
- 旧的 `xxs/xs/...` 与 `xs/sm/...` 别名在所有调用点迁移后被移除。

## 主题偏好

- 旧主题调色板变体（`classic / bluePink / yellowGreen`）与 `theme.palette` 偏好已从活跃 UI/state 中移除。
- 当前主题偏好仅为模式（`theme.mode`）。

## 颜色

- `RecordTypeColors`（`lib/features/record/domain/entities/record_type_colors.dart`）已删除。
- 每种记录类型的颜色对现在表示为 `SemanticColor` token，在 widget build 时解析。

## 间距与布局

- 间距使用 `Spacing` token（level1=4, level2=6, level3=10, level4=14, level5=20, level6=28, level7=36, level8=44,
   level9=56, level10=72, level11=96, level12=128）。
- 硬编码像素值正被项目范围地替换为 token 引用，即使这些 token 值本身在向 Forui 靠拢。
- 断点引用 `Breakpoints` 常量；不出现硬编码 `600`。
- 响应式尺寸 helper 位于 `lib/core/design/responsive_sizing.dart`，用于卡宽、sidebar 宽、grid 高、可缩放 hero/chart
   尺寸。
- 对话框宽度 token 位于 `lib/core/design/layout_scale.dart`：`LayoutScaleResolver.dialogMaxWidth` (360)、
  `wideDialogMaxWidth` (420)、`dialogStandardMaxWidth` (440)。快速记录选择/确认类弹窗统一使用
  `dialogStandardMaxWidth`，避免 `maxWidth: 440` 硬编码分散在多处。

## Markdown 渲染（2026-08-03 起，2026-08-17 F-4 扩展）

- `lib/core/design/markdown_style.dart` 为全 App Markdown 渲染样式的唯一入口（`MarkdownStyle` 抽象类），所有 `MarkdownBody` 调用点禁止本地 `fromTheme(...).copyWith(...)` 漂移。
- 两套预置：
  - `MarkdownStyle.legal(context)` — 正式文档（法律文书详情、帮助页 FAQ）：正文 sm (16px) / 行高 1.7、h1-h3 强层级递减、中性 `colors.border` 引用左条。
  - `MarkdownStyle.ai(context, {background, paragraphWeight, emphasizeLinks})` — AI 生成内容（聊天气泡、Today 摘要/建议、报告总结）：正文 sm / 行高 1.6、`colors.primary` 引用左条与列表 bullet、代码块圆角 + 等宽字体 + 主题背景；`background` 传入气泡/容器底色使代码背景自适配，`paragraphWeight` 支持摘要 w600 / 报告总结 w700 覆盖。
- F-4 扩展（2026-08-17，仅 `MarkdownStyle.ai`）：
  - 标题完整字号阶梯 h1-h6：h1→lg (w700)、h2→md、h3→sm（同正文、加粗区分）、h4→xs、h5→xs2、h6→xs2（降一档字重收尾），各带递减 `*Padding`。
  - 列表缩进走 `Spacing` token（level5=20/级），bullet 与文字间距 `listBulletPadding` level2=6。
  - 引用块：primary 4px 左侧色条 + `SemanticColor.primary.subtle` 底色（深浅色自动适配），四边 padding。
  - 表格：`tableColumnWidth: IntrinsicColumnWidth` —— flutter_markdown_plus 检测到该列宽类型时自动把表格包进横向 `SingleChildScrollView`，窄屏可横向滚动而不是挤压列；表头 `colors.secondary` 背景 + `colors.border` 边框不变。
  - **代码块限制（已记录）**：flutter_markdown_plus 把 `pre` 硬编码为横向 ScrollView，样式表无折行开关；折行会破坏代码缩进，故保持库默认横向滚动，不硬造自定义 builder。
- 链接契约（F-4，仅助手消息气泡）：链接默认不自动跳转；点击先弹确认对话框（`assistantMarkdownLink*` 文案，取消复用 `commonCancel`），确认后经 `ExternalUrlLauncher` 打开；仅放行 http/https 方案。表格列数 / 链接域白名单硬校验规则未定，暂不做。
- 两套均基于 `Spacing` / `SemanticColor` 与 Forui `FColors` / `context.theme.typography.body/display.*` 解析（圆角走 `context.theme.style.borderRadius.*`），深浅色自动适配；代码块/行内代码/表格/分割线/链接统一接入主题 token。
- 全部 6 处渲染点已迁移：legal 2 处（`legal/detail.dart`、`settings/help.dart`）+ ai 4 处（`assistant/flowui_adapter.dart` 的 `FlowMessage` custom part、`today/summary.dart`、`today/suggestion_interactive.dart`、`report/ai_summary.dart`）。



相关子文档：
- [[Design_System_Components]]
