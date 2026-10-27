# lib/core/design — 设计 token 与设计系统执行层

## Summary

design 层集中存放全部设计 token（颜色/间距/图标/动效/布局）的**定义与解析入口**，是 Forui-led 主题体系在代码侧的"执行层"。
业务代码一律通过本层取 token，不在 widget 内内联裸数值或临时 `LinearGradient`；圆角与字体不在此层定义，直接取 Forui 主题（见下）。

与 `docs/reference/design-system.md` 互补：本 README 面向**代码阅读者**（文件清单、类名、取法）；
该文档面向**架构理解者**（token 演进历史、主题族策略、Shell chrome 决策）。

## 目录文件清单

17 个文件，按 `color/`、`tokens/`、`layout/` 三组分组，barrel `design.dart` 留在根：

- 根 — `design.dart`：barrel，导出除 `lucide_icon_bridge.dart` 外的 15 个文件。
- `color/` — `semantic_color.dart`（`SemanticColor` enum 6 色 + `SemanticColorResolution` 解析扩展）、`palette.dart`（`SemanticColorPalette`：单个语义色的 10 tone 值对象）、`theme_extension.dart`（`SemanticColors`：`ThemeExtension`，注入 `FColors.extensions`，提供 `colors.semantic` 访问）、`high_contrast.dart`（`HighContrastColors`：高对比度无障碍覆盖色）。
- `tokens/` — `spacing.dart`（`Spacing`：12 级间距 token + `TitleContentGapTokens`：标题与其内容之间的统一间距）、`icon_size.dart`（`IconSizeTokens`：8 级图标尺寸 token）、`semantic_icons.dart`（`SemanticIcons`：语义图标注册表，`{域}{语义}` 命名如 `safetyCaution`）、`breakpoints.dart`（`Breakpoints`：响应式断点常量）、`elevation.dart`（`ElevationTokens`：`raised` / `glow` / `shadowColor`）、`motion.dart`（`MotionTokens` 6 条 curve + `DurationTokens` 时长）、`markdown_style.dart`（`MarkdownStyle`：`legal` / `ai` 两套 Markdown 样式工厂）、`lucide_icon_bridge.dart`（`LucideIconBridge`：kebab-case 图标名 ↔ `FLucideIcons`，**生成文件**，由 `scripts/setup/generate_lucide_bridge.dart` 生成，**不在 barrel 内**，按需直接 import）。
- `layout/` — `gradient.dart`（`GradientTokens`：`semanticFill` / `tintFade` 两个命名渐变，**禁止内联 `LinearGradient`**）、`layout_scale.dart`（`LayoutScale` 值对象 + `LayoutScaleResolver`：按屏宽解析 + 对话框宽度 + 生效字号收口 + `isCompact` 断点判定）、`responsive_sizing.dart`（`ResponsiveSizing`：卡宽/侧栏宽/网格列数/按宽高缩放）、`surface.dart`（`SurfaceTokens`：scaffold 背景 / 容器边框）。

## Token 体系概览

- **`Spacing`**（12 级）/ **`IconSizeTokens`**（8 级）— 语义名为**主命名**：`Spacing` `xs`(4)/`sm`(6)/`md`(10)/`lg`(14)/`xl`(16)/`xl2`(20)/`xl3`(24)/`xl4`(32)/`xl5`(56)/`xl6`(72)/`xl7`(96)/`xl8`(128)；`IconSizeTokens` `xs`(12)/`sm`(16)/`md`(20)/`lg`(24)/`xl`(28)/`xl2`(32)/`xl3`(48)/`xl4`(64)。两者的 `levelN` 向后兼容别名已于 2026-09-11 全部退役。`Spacing` 上半档（`xl`–`xl4`）按卡片密度收过一档，`xl5` 起是页面/hero 间距不受密度调整影响，取值以 spacing.dart 注释为准。
- **`SemanticColor`** — 6 色 enum：`primary` / `success` / `warning` / `info` / `destructive` / `neutral`。domain/data 层用它保持 theme-agnostic；widget 层再解析为具体颜色。
- **`SemanticColorPalette`** — 每色 10 个**预计算** tone：`solid` / `foreground` / `muted` / `subtle` / `border` / `shimmerBase` / `disabled` / `borderStrong` / `fill` / `fillStrong`。暗色模式 alpha 补偿在主题创建时烘焙，widget 代码不做亮度分支。
- **`SemanticColors`** — 每 (主题族, 明暗) 创建一次，经 `FColors.extensions` 注入；访问路径 `context.theme.colors.semantic`（`colors.semantic.of(color)` 取 palette）。

## 圆角 / 字体不在此层

- 圆角：`context.theme.style.borderRadius.*`（`FBorderRadius` scale）。
- 字体：`context.theme.typography.body/display.*`（`FTypeface` scale）。
- 字阶是 Forui 的**紧凑（desktop）基线**：主题在 `lib/core/theme/family.dart` 里固定
  `touch: false`，组件几何与文字一起走紧凑档。此前只压组件、保留 touch 字阶，两面不合，
  字比同类 App 大一档且行距更松。
- 行高由主题统一压成 1.0（`lib/core/theme/family.dart` 的 `_flattenLineHeight`）：
  每行只占字号本身的高度，纵向节奏交给显式间距，不在 widget 里逐处设 `height`。
  需要长文阅读行距的场景（法律文书正文）在本层的 `MarkdownStyle.legal` 里单独保留宽松行高。
- 字重只有两档：正文 w400、强调 w700。本层的 `MarkdownStyle` 两套工厂按此收口（强调、
  标题、表头一律 w700；AI 样式里最末的 h6 退回 w400），不再出现 w500 / w600。
- 历史：`RadiusTokens` / `TypographyToken` 已于 2026-08-30 退役，本层不再定义。

## 标题与内容的间距

- 全应用统一走 `context.titleContentGap`（`TitleContentGapTokens`）：值取自 Forui 主题
  `context.theme.style.borderRadius.lg`（= 14，与 `Spacing.lg` 同值）。
- 覆盖范围：区块标题/分组标签 → 其直接统领的内容（`TodaySection`、`ReviewSectionCard`、
  `SettingsSectionLabel` 等所有调用点）。标题与其副标题/说明之间的紧凑间距不适用本约定；
  桌面端布局的区块分隔各自处理。
- 与圆角、字体一致：值从 context 取，不在 widget 内联 `Spacing.*` 或裸数值。

## 取法约定

- 同一方法内对同一来源（`context.theme.style.borderRadius` / `context.theme.typography` / `context.theme.colors`）取用 **≥2 次**时，在方法顶部提取一次局部变量（`final colors = context.theme.colors`）再使用；单次使用保持内联。
- `SemanticColor.*.tone(context)`（如 `SemanticColor.neutral.solid(context)`）是**规范形态**，每次调用直接传 `context`，不做变量化。
- 自带 `context` 参数的内嵌闭包（如 `FBadge.raw(builder: (context, style) {...})`）内照常直接 `context.theme.*`，不引用外层方法提取的变量，避免取值来源漂移。
- 业务代码引用图标走 `SemanticIcons`（`lib/core/design/tokens/semantic_icons.dart`），不直接散用 `FLucideIcons`；`Icons.*` 视为迁移债。

## 图标约定（`SemanticIcons`）

- **唯一入口**：业务代码只通过 `SemanticIcons.<语义名>` 取 `IconData`；`lib/features/` 下不得出现裸 `FLucideIcons.*`。
- **一个语义一个字形**：两个不同的语义名不得映射到同一字形（含 Lucide/Phosphor 跨族同形，如 `circleCheck` vs `checkCircle`）。
- **同类通用语义应复用**：返回、提示、错误、关闭、搜索、导航、确认、删除等标准控件动作，
  在不同页面出现时应共用同一个语义 token，不要为了「页面内不重复」而拆散。
- **具体功能含义必须独占**：只有一个页面/模块特有的功能入口才需要单独 token；
  不同含义共用一个字形（例如把「已确认安全」画成「需谨慎」的盾牌）是错配，必须拆开。
- **尺寸只用 `IconSizeTokens`**：`Icon(size:)` / `iconSize:` 一律取 `IconSizeTokens.*`，
  不得传 `Spacing.*`（那是间距刻度，`Spacing.xl`=16 与 `IconSizeTokens.sm`=16 只是数值巧合）。
- **不加装饰性衬底**：裸字形是默认形态。只有承担触摸目标、状态面、强调层级或固定导航槽位时才允许底衬；
  不要为了给图标一个背景而包一层容器。
