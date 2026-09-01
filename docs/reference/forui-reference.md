---
status: active
owner: frontend
updated: 2026-08-31
---

# Forui 参考（项目版）

> 版本：`forui: 0.26.0`，`forui_hooks: 0.26.0`。
> **上游是真相**：文档站 https://forui.dev/docs ，API 文档 https://pub.dev/documentation/forui ；
> 本地镜像 `forui-docs/llms-full.txt`（聚合官方文档与示例，查组件用法首选）；查 API 签名/默认样式看
> Pub/Cache 源码。本文只记录本地约定，不复述上游 API。

## 仍影响本仓库的版本差异

- **0.26.x（material_ui 迁移）**：forui 内部从 `flutter/material.dart` 迁移到 `material_ui` 包。与 forui
  共享 `ThemeExtension`/`ThemeData`/`ThemeMode`/`InputBorder` 等类型的文件，import 用
  `package:material_ui/material_ui.dart`；`localizationsDelegates` 需同时包含 `material_ui` 的
  `GlobalMaterialLocalizations.delegates` 与 `flutter_localizations` 的 delegates（`RefreshIndicator` 等
  Material widget 仍需后者）；`forui_assets` 包更名为 `forui_lucide`。
- **0.24.x（对话框 API）**：`FCard.raw` / `FDialog.raw` 移除，API 合并进 `FCard` / `FDialog`；`FDialog`
  从声明式（`title`/`body`/`actions`）改为 `builder: (context, style) => ...` 模式，`style`
  提供 `titleTextStyle` / `bodyTextStyle`。项目内经 `showAppDialog` 使用时按此模式写 builder。
- **`FHeader.nested` 布局约束（崩溃级）**：必须放在 `Column` 顶部或 `FScaffold.header` 中，**不能放进
  `ListView`/`GridView` 等 tight width 滚动视图**——Forui 的 `_RenderNestedHeader.performLayout()` 在
  tight width 下会产出 `minWidth > maxWidth` 的无效约束导致崩溃。Tab 根页正确模式：
  `Column(FHeader.nested + Expanded(ListView(...)))`。

## 本地主题接入

- 根主题：`lib/core/theme/family.dart` 维护主题族目录。Forui 0.24.0 起仅保留 `neutral` 预定义方案，项目经
  `_familyColorOverride()` 在 `FTheme.neutral` 基础上覆盖 `primary` / `primaryForeground` 模拟原主题族
  颜色变体；`lib/app/bootstrap.dart` 按持久化的 `theme.family` + `theme.mode` 派生 `ThemeData`，再用
  `FTheme` 包裹整棵树。
- `lib/theme/` 为 Forui CLI 生成物（`dart run forui style create`），勿手改；需定制时更新 CLI 配置重新生成。

## Token 约定

- **字体**：正文 `context.theme.typography.body.*`，强调/大标题 `context.theme.typography.display.*`；
  Tab 根页大标题 `display.xl3` + `FontWeight.w800`。
- **圆角**：`context.theme.style.borderRadius.xs2`（4）到 `pill`（100）。
- **间距**：`Spacing.xs`（4）到 `xl8`（128），不硬编码像素。
- **图标大小**：`IconSizeTokens.xs`（12）到 `xl4`（64），不硬编码 `size: N`。
- **动画曲线**：`MotionTokens.entrance` / `exit` / `standard` / `snappy`，不硬编码 `Curves.*`。
- **动画时长**：`DurationTokens.*`（与 `MotionTokens` 同在 `motion.dart`）。
- **阴影**：`ElevationTokens.raised(colors)` / `glow(color)` / `shadowColor(colors)`，不内联 `BoxShadow`。
- **渐变**：`GradientTokens.semanticFill(palette)` / `tintFade(from, to)`，不内联 `LinearGradient`。
- **颜色**：widget 层直接读 `context.theme.colors.*`；数据/领域层用语义枚举 `SemanticColor`，在 widget 处
  `palette(context)` 解析。

## 本地组件用法

- **页面 header**：子页（有返回按钮的 drill-down 页）统一用 `PageScaffold`
  （`lib/core/widgets/layout/page_scaffold.dart`）；Tab 根页统一用 `FHeader.nested`。
- **返回按钮**：统一 `AppBackButton`（`lib/core/widgets/common/control/back_button.dart`；保留 App 前缀以
  避免与 Flutter `BackButton` 冲突）。
- **图标**：优先 Forui 自带 `FLucideIcons.*`（来自 `forui_lucide` 桥接包），禁用 Material `Icons.*`。
- **对话框**：`showAppDialog` / `DialogShell`（`lib/core/widgets/common/dialog/dialog_shell.dart`）封装
  `showFDialog` + `FDialog`，统一 `maxWidth`、padding、滚动与键盘 inset；需不可点击遮罩关闭的场景传
  `barrierDismissible: false`。
- **反馈**：Toast 用 `AppToast.show`（封装 `showFToast`）；加载 `FCircularProgress`；空/错误状态
  `AppStateErrorView` / `AppStateMessageView`。
- **设置分组标签**：`context.theme.typography.body.sm` + `w600` + `SemanticColor.neutral.solid(context)`；
  子页 `FTile` 共用外层 `FTileGroup` 边框，内部 `FTile` 不重复描边。
- **FScaffold 子页**：手写时保持 `childPad: false`，避免默认 padding 与 `ResponsiveContentFrame` 叠加。
- **样式定制**：局部覆盖用 `.delta(...)`，不自写全套 Style；大改用官方 CLI：`dart run forui style ls` /
  `dart run forui style create <component>`。

## 与 Riverpod / Hooks 的配合

- 带 controller 的 Forui 组件优先用 `forui_hooks` 的 hook（`useFSelectController<T>()`、
  `useFDateController()` 等），避免手写 `initState`/`dispose`。
- 项目已全面使用 `flutter_hooks` + `hooks_riverpod`。

## 避免的旧习惯

- 不新建 `App*` 薄包装去包 Forui 基础组件（如 `AppButton`、`AppCard`）。
- 不手写 `Material` / `InkWell` / `Scaffold` / `AppBar`。
- 不保留 `AppThemeSurface`、`AppTypographyTokens`、`AppSectionSurface`、`AppColorTokens`、
  `AppShadowTokens`、`AppInkWell`、`AppDialog` 等已删除别名。
