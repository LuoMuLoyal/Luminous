# Design System

本文档保留设计系统总览与 Token。

子文档：

- [[Design_System_Components]]
- [[Design_System_Migration]]

## 根主题

- 根主题为 Forui-led，当前通过 `lib/theme/theme.dart` 暴露 Forui 内置主题族目录。
- `LuminousApp` 根据本地 `theme.family` 选择 `FThemes.blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc` 的 light/dark touch 变体，再派生 app 的 `ThemeData`。
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

## Token 清理

- `AppColorTokens` 与 `AppTypographyTokens` 已删除。
- `AppShadowTokens` 也已删除且未替换：
  - 其 level1/level2 值先内联，后从 `app_toast.dart`、`app_state_views.dart`、`today_components.dart` 完全移除，
     以匹配更平的 Forui-first 视觉方向。
- `AppSpacingTokens` 与 `AppRadiusTokens` 仍作为兼容名存在，主命名为 `level*`，但实际值在 2026-07-02 被积极重置以跟踪当前
   Forui-led 基础。
- `lib/core/design/app_colors.dart` 中新增 `AppColors` enum：
  - 最小语义颜色 token：`primary`、`secondary`、`destructive`、`muted`、`background`、`border`、`foreground`
  - 数据/领域层使用
  - widget 通过 `context.theme.colors` 解析，自动切换 light/dark

## 命名

- `AppSpacingTokens` 与 `AppRadiusTokens` 暴露 `level*` 主命名（`level1`、`level2` …）。
- 旧的 `xxs/xs/...` 与 `xs/sm/...` 别名在所有调用点迁移后被移除。

## 主题偏好

- 旧主题调色板变体（`classic / bluePink / yellowGreen`）与 `theme.palette` 偏好已从活跃 UI/state 中移除。
- 当前主题偏好仅为模式（`theme.mode`）。

## 颜色

- `RecordTypeColors`（`lib/features/record/domain/entities/record_type_colors.dart`）已删除。
- 每种记录类型的颜色对现在表示为 `AppColors` token，在 widget build 时解析。

## 间距与布局

- 间距使用 retuned `AppSpacingTokens` bridge（xxs=4, xs=6, sm=10, md=14, lg=20, xl=28, x2l=36, x3l=44,
   x4l=56, x5l=72, x6l=96, section=128）。
- 硬编码像素值正被项目范围地替换为 token 引用，即使这些 token 值本身在向 Forui 靠拢。
- 断点引用 `AppBreakpoints` 常量；不出现硬编码 `600`。
- 响应式尺寸 helper 位于 `lib/core/design/app_responsive_sizing.dart`，用于卡宽、sidebar 宽、grid 高、可缩放 hero/chart
   尺寸。



相关子文档：
- [[Design_System_Components]]

