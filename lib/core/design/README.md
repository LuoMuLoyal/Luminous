# lib/core/design — 设计 token 与设计系统执行层

## Summary

design 层集中存放全部设计 token（颜色/间距/图标/圆角/字体/动效/布局）的**定义与解析入口**，
是 Forui-led 主题体系在代码侧的"执行层"。业务代码一律通过本层取 token，不在 widget 内
内联裸数值或临时 `LinearGradient`。圆角与字体不在此层定义，直接取 Forui 主题（见下）。

与 `docs/02-reference/Design_System.md` 互补：本 README 面向**代码阅读者**（文件清单、
类名、取法）；该文档面向**架构理解者**（token 演进历史、主题族策略、Shell chrome 决策）。

## 目录文件清单

17 个文件，全部扁平放置。唯一入口是 barrel `design.dart`：

| 文件 | 内容 |
|---|---|
| `design.dart` | barrel — 导出其余 15 个文件 |
| `spacing.dart` | `Spacing`：12 级间距 token |
| `icon_size.dart` | `IconSizeTokens`：8 级图标尺寸 token |
| `semantic_color.dart` | `SemanticColor` enum（6 色）+ `SemanticColorResolution` 解析扩展 |
| `semantic_color_palette.dart` | `SemanticColorPalette`：单个语义色的 10 tone 值对象 |
| `semantic_colors.dart` | `SemanticColors`：`ThemeExtension`，注入 `FColors.extensions`，提供 `colors.semantic` 访问 |
| `surface.dart` | `SurfaceTokens`：scaffold 背景 / 容器边框 |
| `elevation.dart` | `ElevationTokens`：`raised` / `glow` / `shadowColor` |
| `gradient.dart` | `GradientTokens`：`semanticFill` / `tintFade` 两个命名渐变 |
| `motion.dart` | `MotionTokens`（4 条 curve）+ `DurationTokens`（时长） |
| `breakpoints.dart` | `Breakpoints`：响应式断点常量 |
| `layout_scale.dart` | `LayoutScale`（值对象）+ `LayoutScaleResolver`（按屏宽解析 + 对话框宽度） |
| `responsive_sizing.dart` | `ResponsiveSizing`：卡宽/侧栏宽/网格列数/按宽高缩放 |
| `high_contrast.dart` | `HighContrastColors`：高对比度无障碍覆盖色 |
| `semantic_icons.dart` | `SemanticIcons`：语义图标注册表（`{域}{语义}` 命名，如 `safetyCaution`） |
| `markdown_style.dart` | `MarkdownStyle`：`legal` / `ai` 两套 Markdown 样式工厂 |
| `lucide_icon_bridge.dart` | `LucideIconBridge`：kebab-case 图标名 ↔ `FLucideIcons`（**生成文件**，由 `scripts/generate_lucide_bridge.dart` 生成，**不在 barrel 内**，按需直接 import） |

## Token 体系概览

- **`Spacing`** — 12 级。语义别名 `xs`(4) / `sm`(6) / `md`(10) / `lg`(14) / `xl`(20) /
  `xl2`(28) / `xl3`(36) / `xl4`(44) / `xl5`(56) / `xl6`(72) / `xl7`(96) / `xl8`(128) 为**主命名**，
  `level1`~`level12` 保留为向后兼容别名。
- **`IconSizeTokens`** — 8 级。语义别名 `xs`(12) / `sm`(16) / `md`(20) / `lg`(24) / `xl`(28) /
  `xl2`(32) / `xl3`(48) / `xl4`(64) 为**主命名**，`level1`~`level8` 为别名。
- **`SemanticColor`** — 6 色 enum：`primary` / `success` / `warning` / `info` / `destructive` /
  `neutral`。domain/data 层用它保持 theme-agnostic；widget 层再解析为具体颜色。
- **`SemanticColorPalette`** — 每色 10 个**预计算** tone：`solid` / `foreground` / `muted` /
  `subtle` / `border` / `shimmerBase` / `disabled` / `borderStrong` / `fill` / `fillStrong`。
  暗色模式 alpha 补偿在主题创建时烘焙，widget 代码不做亮度分支。
- **`SemanticColors`** — 每 (主题族, 明暗) 创建一次，经 `FColors.extensions` 注入；
  访问路径 `context.theme.colors.semantic`（`colors.semantic.of(color)` 取 palette）。
- 其余工具 token：`ElevationTokens`、`GradientTokens`（**禁止内联 `LinearGradient`**）、
  `MotionTokens` / `DurationTokens`、`Breakpoints`、`LayoutScale` / `LayoutScaleResolver`、
  `ResponsiveSizing`、`HighContrastColors`、`SurfaceTokens`、`MarkdownStyle`、`SemanticIcons`、
  `LucideIconBridge`。

## 圆角 / 字体不在此层

- 圆角：`context.theme.style.borderRadius.*`（`FBorderRadius` scale）。
- 字体：`context.theme.typography.body/display.*`（`FTypeface` scale）。
- 历史：`RadiusTokens` / `TypographyToken` 已于 2026-08-30 退役，本层不再定义。

## 取法约定

- 同一方法内对同一来源（`context.theme.style.borderRadius` / `context.theme.typography` /
  `context.theme.colors`）取用 **≥2 次**时，在方法顶部提取一次局部变量
  （`final colors = context.theme.colors`）再使用；单次使用保持内联。
- `SemanticColor.*.tone(context)`（如 `SemanticColor.neutral.solid(context)`）是**规范形态**，
  每次调用直接传 `context`，不做变量化。
- 自带 `context` 参数的内嵌闭包（如 `FBadge.raw(builder: (context, style) {...})`）内照常
  直接 `context.theme.*`，不引用外层方法提取的变量，避免取值来源漂移。
- 业务代码引用图标走 `SemanticIcons`（`lib/core/design/semantic_icons.dart`），不直接散用
  `FLucideIcons`；`Icons.*` 视为迁移债。
