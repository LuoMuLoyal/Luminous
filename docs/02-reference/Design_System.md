# Design System

本文档保留设计系统总览与 Token。

子文档：

- [[Design_System_Components]]
- [[Design_System_Migration]]

## 根主题

- 根主题为 Forui-led，当前通过 `lib/core/theme/theme.dart` 暴露主题族目录。
- Forui 0.24.0 移除了除 `neutral` 外的所有预定义颜色方案。`LuminousApp` 现通过 `_familyColorOverride()` 函数在 `FTheme.neutral` 基础上覆盖 `primary` / `primaryForeground` 来模拟原有 `blue / green / orange / red / rose / slate / violet / yellow / zinc` 主题族的 light/dark 颜色变体，再派生 app 的 `ThemeData`。
- 在 app 根注入 `FTheme`，替代 earlier green-skewed auth look。

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
  - `AppRadiusTokens` → `RadiusTokens`（避免与 Flutter `Radius` 冲突）
  - `AppTypographyToken` → `TypographyToken`
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
- `Spacing` / `RadiusTokens` / `TypographyToken` / `DurationTokens` / `IconSizeTokens` / `Breakpoints` / `ResponsiveSizing` 均暴露 `level*` 主命名。
- `DurationTokens` 和 `MotionTokens` 为 `abstract final class`（非 `class + const _()`），位于 `motion.dart`。
- `MotionTokens` 提供 4 个 curve token：`entrance`（easeOutCubic）、`exit`（easeInCubic）、`standard`（easeInOut）、`snappy`（easeOut）。
- `IconSizeTokens`（`icon_size.dart`）提供 5 级 icon size：level1=12, level2=16, level3=20, level4=24, level5=32。
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



相关子文档：
- [[Design_System_Components]]

