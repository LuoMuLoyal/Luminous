# 设计系统统一与 Token 去代理化

> 创建于 2026-08-30，合并两轮审计结论：① 设计系统使用一致性审计 ② Token 去代理化（退役纯 1:1 代理 Forui 原生 API 的自定义 token）。

## 背景

项目采用 Forui-first 设计系统 [[memory:17849504329474592541]]，自定义了一套 `lib/core/design/` token 体系。两轮审计发现：

1. **使用不统一**：部分代码绕过 `SemanticColor` 体系直接取 Forui 原生 `mutedForeground`；`BorderRadius.circular` 硬编码散布在 ~117 处。
2. **代理层冗余**：`RadiusTokens` 和 `TypographyToken` 是对 Forui `FBorderRadius` / `FTypeface` 的纯 1:1 代理，零附加值，增加了认知负担和维护成本。

## 审计数据快照

以下数据来自 2026-08-30 的全量 `rg -c` 扫描，仅作计划参考，执行时以实际扫描为准。

### 取法次数总览

| 扫描项 | 取法次数 | 说明 |
|--------|---------|------|
| `Spacing.level*` | 2,129 | design 层间距 token，使用最广泛 |
| `TypographyToken.*` | 583 | design 层字体 token（退役目标） |
| `SemanticColor.*` | 338 | design 层语义颜色系统 |
| `context.theme.colors.*`（直接取 Forui） | 121 | 绕过 design 层直接取 Forui 原生颜色 |
| `RadiusTokens.*` | 152 | design 层圆角 token（退役目标） |
| `IconSizeTokens.*` | 120 | design 层图标尺寸 token |
| `BorderRadius.circular(数字)` | 117 | 绕过 RadiusTokens 硬编码圆角 |
| `context.theme.style.borderRadius.*` | 9 | 直接取 Forui borderRadius（已是目标态） |
| `Colors.black/white` 硬编码 | 6 | 违反 Forui-first 原则 |
| `Color(0x...)` 硬编码 | 58 | 含 design 层定义 + 业务层违规 |

### `context.theme.colors.*` 121 次拆分

直接取 Forui 原生色的 121 次中（仅统计 `context.theme.colors.` 前缀），主要取的属性为：

| Forui 原生属性 | 次数 | 语义等价物 | 说明 |
|--------------|------|-----------|------|
| `mutedForeground` | 73 | `SemanticColor.neutral.solid` | 次要文字颜色，取法最多 |
| `primary`（非 `primaryForeground`） | 18 | `SemanticColor.primary.solid` | 品牌色，两种写法并存 |
| `border` | 9 | `SemanticColor.neutral.border` | 边框色 |
| `background` | 6 | 无直接等价（`SurfaceTokens.scaffoldBackground`） | 背景色，属分层职责不迁移 |
| `destructive` | 4 | `SemanticColor.destructive.solid` | 错误/危险色 |
| `primaryForeground` | 1 | `SemanticColor.primary.foreground` | 品牌色前景 |

> 注意：`colors.mutedForeground` 还以 `final colors = context.theme.colors;` 局部变量前缀形式出现于更多文件中（总计 ~369 处 `.mutedForeground` 引用含 `markdown_style.dart` 等非 `context.theme.colors.` 前缀写法）。Phase 3 迁移时需同时扫描 `colors.mutedForeground` 局部变量模式。

### `level*` 跨维度语义不一致

`level*` 编号在不同维度有不同视觉含义，开发者需要记住多套映射表：

| Level | Spacing | RadiusTokens | IconSizeTokens | TypographyToken |
|-------|---------|-------------|---------------|-----------------|
| level1 | 4px | 4px | 12px | 10px |
| level2 | 6px | 6px | 16px | 12px |
| level3 | 10px | 8px | 20px | 14px |
| level4 | 14px | 10px | 24px | 16px |
| level5 | 20px | 14px | 28px | 18px |

同一编号在不同维度值不同——`level3` 可以是 10px 间距、8px 圆角、20px 图标、14px 字体。对比之下，`MotionTokens`（entrance/exit/standard/snappy）、`ElevationTokens`（raised/glow）、`GradientTokens`（semanticFill/tintFade）已使用语义命名。

## Token 分类审判

### 退役（纯 1:1 代理，零附加值）

#### 1. `RadiusTokens` → 退役，改用 `context.theme.style.borderRadius`

`RadiusTokens`（`lib/core/design/radius.dart`）的 9 个值与 Forui `FBorderRadius`（`context.theme.style.borderRadius`）完全 1:1：

| `RadiusTokens` | px | Forui `FBorderRadius` |
|----------------|-----|----------------------|
| `level0` | 0 | `BorderRadius.zero` |
| `level1` | 4 | `xs2` |
| `level2` | 6 | `xs` |
| `level3` | 8 | `sm` |
| `level4` | 10 | `md` |
| `level5` | 14 | `lg` |
| `level6` | 18 | `xl` |
| `level7` | 22 | `xl2` |
| `level8` | 26 | `xl3` |
| `level9` / `levelFull` | 100 | `pill` |

Forui 的 `FBorderRadius` 属性返回的是 `BorderRadius` 对象（`BorderRadius.all(Radius.circular(n))`），比自定义 `double` 常量更直接可用——不需要再包一层 `BorderRadius.circular(RadiusTokens.level3)`，直接 `context.theme.style.borderRadius.sm` 即可。但裸 `double` 用法需要 `.topLeft.x` 多层访问（详见退役路径 step 2）。

**退役路径**：
1. 全局替换 `BorderRadius.circular(RadiusTokens.levelN)` → `context.theme.style.borderRadius.xxx`
2. 全局替换 `RadiusTokens.levelN` 裸 `double` 用法（约 39 处，模式多样）→ 按上下文分别处理：
   - 若需要 `BorderRadius` 值：直接用 `context.theme.style.borderRadius.xxx`
   - 若需要 `Radius` 值：用 `context.theme.style.borderRadius.xxx.topLeft`（`BorderRadius.topLeft` 返回 `Radius`）
   - 若需要裸 `double`：用 `context.theme.style.borderRadius.xxx.topLeft.x`（`Radius.x` 返回 `double`）
   - **注意**：`FBorderRadius.xxx` 返回 `BorderRadius` 对象，`BorderRadius` **没有** `.x` 属性。要取裸 `double` 需 `.topLeft.x`（或 `.topRight.x` / `.bottomLeft.x` / `.bottomRight.x`，四角值相同）
3. 同步处理 `lib/core/design/markdown_style.dart` 中的 `BorderRadius.circular(RadiusTokens.level2/level3)` 引用
4. 删除 `lib/core/design/radius.dart`
5. 从 `lib/core/design/design.dart` 移除 `export 'radius.dart'`
6. 更新 `docs/02-reference/Design_System.md` 中对 `RadiusTokens` 的引用

#### 2. `TypographyToken` → 退役，改用 `context.theme.typography`

`TypographyToken`（`lib/core/design/typography.dart`）的 10 个值与 Forui `FTypeface`（`context.theme.typography.body` / `.display`）完全 1:1：

| `TypographyToken` | px | Forui `FTypeface` |
|-------------------|-----|-------------------|
| `level1` | 10 | `xs3` |
| `level2` | 12 | `xs2` |
| `level3` | 14 | `xs` |
| `level4` | 16 | `sm` |
| `level5` | 18 | `md` |
| `level6` | 20 | `lg` |
| `level7` | 22 | `xl` |
| `level8` | 30 | `xl2` |
| `level9` | 36 | `xl3` |
| `level10` | 48 | `xl4` |

Forui 还提供了 `xl5`~`xl8`（60~108px），自定义 token 截断了这些大号尺寸。退役后可直接使用完整的 Forui typeface。

**退役路径**：
1. 全局替换 `TypographyToken.levelN.body(context)` → `context.theme.typography.body.xxx`
2. 全局替换 `TypographyToken.levelN.display(context)` → `context.theme.typography.display.xxx`
3. 全局替换 `TypographyToken.levelN.resolve(typography)` → `typography.body.xxx` / `typography.display.xxx`
4. 删除 `lib/core/design/typography.dart`
5. 从 `lib/core/design/design.dart` 移除 `export 'typography.dart'`
6. 更新 `docs/02-reference/Design_System.md` 中对 `TypographyToken` 的引用（含 Markdown 渲染段落中对 `TypographyToken` 的引用）

> **注意**：上表中的 px 值为 touch theme 默认值。`FTypeface` 在 desktop theme 下 fontSize 不同（如 `xs3` touch=10、desktop=8）。但 `TypographyToken` 的 `resolve()` 也是在运行时从当前主题取值，所以退役后 `context.theme.typography.body.xxx` 同样运行时适配，不会有视觉变化。映射的是 API 属性名（`levelN` → `xs3/xs2/...`），不是固定像素值。

### 保留（Forui 无等价物，真实增值层）

以下 token 类 Forui 没有等价物，是项目的真实增值层，**保留不动**：

| Token 类 | 文件 | 保留理由 |
|----------|------|---------|
| `Spacing` | `spacing.dart` | Forui 无通用 spacing scale，只有 `FStyle.pagePadding`（页面级 padding），非通用 |
| `IconSizeTokens` | `icon_size.dart` | Forui `FStyle.iconStyle` 只有一个 `size`（默认 20px），无多级 scale |
| `SemanticColors` / `SemanticColorPalette` | `semantic_color*.dart` | Forui 无 success/warning/info 语义色；无 tonal scale（10 种预计算色调 + 暗色补偿） |
| `SurfaceTokens` | `surface.dart` | Forui 无灰底 #FAFAFA + 超淡边框策略 |
| `ElevationTokens` | `elevation.dart` | Forui 只有一个简单 `shadow` 常量，无暗色补偿 |
| `GradientTokens` | `gradient.dart` | 禁止内联 `LinearGradient` 的执行层 |
| `MotionTokens` / `DurationTokens` | `motion.dart` | Forui 无动画曲线/时长 token |
| `Breakpoints` | `breakpoints.dart` | Forui 有 `FBreakpoints` 但项目布局断点不同 |

### 保留但改命名（`level*` → 语义别名）

`Spacing` 和 `IconSizeTokens` 保留，但 `level*` 编号认知负担太重（`Spacing.level4` 是 14px？`IconSizeTokens.level3` 是 20px？），需增加语义别名：

#### `Spacing` 语义别名

```dart
abstract final class Spacing {
  // 语义别名（推荐使用）
  static const double xs = 4;     // = level1
  static const double sm = 6;     // = level2
  static const double md = 10;    // = level3
  static const double lg = 14;    // = level4
  static const double xl = 20;   // = level5
  static const double xl2 = 28;  // = level6
  static const double xl3 = 36;  // = level7
  static const double xl4 = 44;  // = level8
  static const double xl5 = 56;  // = level9
  static const double xl6 = 72;  // = level10
  static const double xl7 = 96;  // = level11
  static const double xl8 = 128; // = level12

  // level* 保留为别名（向后兼容，迁移完成后评估是否移除）
  static const double level1 = xs;
  static const double level2 = sm;
  // ... 以此类推
}
```

#### `IconSizeTokens` 语义别名

```dart
abstract final class IconSizeTokens {
  // 语义别名（推荐使用）
  static const double xs = 12;    // = level1
  static const double sm = 16;    // = level2
  static const double md = 20;   // = level3
  static const double lg = 24;   // = level4
  static const double xl = 28;   // = level5
  static const double xl2 = 32;  // = level6
  static const double xl3 = 48;  // = level7
  static const double xl4 = 64;  // = level8

  // level* 保留为别名
  static const double level1 = xs;
  // ...
}
```

## 使用统一性修复

### 问题 1：颜色取用双轨制 — `context.theme.colors.*` vs `SemanticColor.*`

**现状**：两种取法并存且混用于同一文件。`context.theme.colors.*` 取的 Forui 原生属性主要是 `mutedForeground`（73 次，最多）、`primary`（18 次）、`border`（9 次）、`background`（6 次）、`destructive`（4 次）、`primaryForeground`（1 次）。

**根因**：
- `SemanticColor.neutral.solid` 虽映射到 `mutedForeground`，但"neutral"语义不直观——开发者写次要文字时自然取 `colors.mutedForeground`。
- `SemanticColor.primary.solid` 与 `context.theme.colors.primary` 取到同一值，但两种写法并存。
- `colors.background`、`colors.card`、`colors.foreground` 三个基础面色没有对应的 semantic tone——`neutral.subtle` = `colors.secondary`，但 `background`/`card`/`foreground` 无映射。

**修复方案**：

#### 1a. `mutedForeground` 统一

在 `SemanticColor` enum 上确认 `neutral.solid` 已映射到 `fColors.mutedForeground`（在 `theme.dart` 的 `_semanticColorsFor` 中已确认），然后全局替换。

**迁移路径**：
1. 全局替换 `context.theme.colors.mutedForeground` → `SemanticColor.neutral.solid(context)`
2. 验证视觉无变化

#### 1b. `primary` / `destructive` / `primaryForeground` 双通道统一

这三种语义色已有 `SemanticColor` 等价物，但代码中两种写法并存。统一走 `SemanticColor`。

**迁移路径**：
1. `context.theme.colors.primary` → `SemanticColor.primary.solid(context)`
2. `context.theme.colors.destructive` → `SemanticColor.destructive.solid(context)`
3. `context.theme.colors.primaryForeground` → `SemanticColor.primary.foreground(context)`

#### 1c. `background` / `card` / `foreground` 基础面缺口

这三个 Forui 原生面色没有对应的 `SemanticColor` tone。`SurfaceTokens` 部分覆盖（`scaffoldBackground`），但不完整。

**处理策略**：不在 `SemanticColor` 中强行映射这三个基础面色——它们是 Forui 主题系统的底层色，通过 `SurfaceTokens` 和 `context.theme.colors` 按需取用是合理的。但需文档明确规定：基础面色走 `context.theme.colors.*` / `SurfaceTokens.*`，语义色走 `SemanticColor.*`，两者职责不同，不是"双轨制"而是"分层职责"。

#### 1d. `border` 统一

`context.theme.colors.border`（~5 次）应统一走 `SemanticColor.neutral.border(context)`。

### 问题 2：`BorderRadius.circular` 硬编码

**现状**：~117 处 `BorderRadius.circular(N)` 硬编码散布在 widget 代码中。

**修复方案**：与 `RadiusTokens` 退役合并处理——直接替换为 `context.theme.style.borderRadius.xxx`。

迁移映射表：

| 硬编码值 | 对应 Forui `FBorderRadius` |
|---------|--------------------------|
| `BorderRadius.circular(4)` | `.xs2` |
| `BorderRadius.circular(6)` | `.xs` |
| `BorderRadius.circular(8)` | `.sm` |
| `BorderRadius.circular(10)` | `.md` |
| `BorderRadius.circular(12)` | `.sm` (8) 或 `.md` (10)，按上下文择近 |
| `BorderRadius.circular(14)` | `.lg` |
| `BorderRadius.circular(16)` | `.lg` (14) 或 `.xl` (18)，按上下文择近 |
| `BorderRadius.circular(18)` | `.xl` |
| `BorderRadius.circular(22)` | `.xl2` |
| `BorderRadius.circular(26)` | `.xl3` |
| `BorderRadius.circular(100)` | `.pill` |

不在标准 scale 上的值（如 12、16），按"择近"原则映射到最近的 token，或在代码审查时确认是否有特殊理由保留精确值。

### 问题 3：`context.theme.style.borderRadius.*` 9 处直接取 Forui

**现状**：9 处直接取 `context.theme.style.borderRadius.{sm,lg,pill}`，绕过了 `RadiusTokens`。

**处理**：退役 `RadiusTokens` 后，这 9 处已经是目标态（直接取 Forui `FBorderRadius`），无需修改。但需确认这 9 处与退役后的统一取法一致——即全项目统一用 `context.theme.style.borderRadius.*`。

### 问题 4：`Colors.black/white` 硬编码（6 处）

**现状**：6 处 `Colors.black` / `Colors.white` 硬编码，违反 Forui-first 原则。

**修复方案**：逐一审计，替换为语义等价物：
- `Colors.black` → `context.theme.colors.foreground`（暗色模式为白色，亮色模式为黑色）或具体 `SemanticColor` 的 `solid`/`fillStrong`
- `Colors.white` → `context.theme.colors.background`（亮色模式为白色，暗色模式为深色）
- 例外：barcode scanner 扫描框颜色等硬件交互场景可能需要保持硬编码

### 问题 5：`Color(0x...)` 硬编码（58 处）

**现状**：58 处 `Color(0x...)` 硬编码。其中大部分是合法的（`theme.dart` 主题族定义、OAuth 品牌色、barcode scanner 扫描框颜色），但需逐个审计确认。

**修复方案**：
1. 扫描全部 58 处，分类为"合法硬编码"（主题定义、品牌色、硬件交互）和"违规硬编码"（widget 层面应该走 token 的）
2. 违规项替换为 `SemanticColor` 或 Forui 原生色
3. 合法项添加注释说明为何硬编码

## 执行计划

### Phase 1: `RadiusTokens` 退役 + `BorderRadius.circular` 硬编码清理

- [ ] 1.1 扫描全部 `RadiusTokens` 引用和 `BorderRadius.circular` 硬编码，生成完整文件清单
- [ ] 1.2 按文件逐个替换（按 feature 迁移：today → record → medicine → report → mine → settings → search → scan → review → core）：
  - `BorderRadius.circular(RadiusTokens.levelN)` → `context.theme.style.borderRadius.xxx`
  - `RadiusTokens.levelN`（裸 `double` 用法，约 39 处）→ 按上下文用 `context.theme.style.borderRadius.xxx`（需 `BorderRadius` 时）或 `.xxx.topLeft.x`（需裸 `double` 时）
  - `BorderRadius.circular(硬编码数字)` → `context.theme.style.borderRadius.xxx`
- [ ] 1.3 确认 9 处 `context.theme.style.borderRadius.*` 直接取 Forui 的代码已是目标态，无需修改
- [ ] 1.4 删除 `lib/core/design/radius.dart`
- [ ] 1.5 从 `lib/core/design/design.dart` 移除 `export 'radius.dart'`
- [ ] 1.6 更新 `docs/02-reference/Design_System.md` 中 `RadiusTokens` 相关段落
- [ ] 1.7 同步处理 `lib/core/design/markdown_style.dart` 中的 `RadiusTokens` 引用（`BorderRadius.circular(RadiusTokens.level2/level3)`）和 `colors.mutedForeground` / `colors.border` 直接取法
- [ ] 1.8 `flutter analyze` + `flutter test` 验证

### Phase 2: `TypographyToken` 退役

- [ ] 2.1 扫描全部 `TypographyToken` 引用，生成完整文件清单
- [ ] 2.2 特别处理 `lib/core/design/markdown_style.dart`——该文件大量使用 `TypographyToken` 定义 Markdown 渲染样式（legal 和 ai 两套预置的标题阶梯、正文、行高等），退役时需同步迁移到 `context.theme.typography.body/display.*`。注意该文件还使用了 `RadiusTokens` 和 `colors.mutedForeground` / `colors.border` 直接取法，需在对应 Phase 中一并处理
- [ ] 2.3 按文件逐个替换（按 feature 迁移）：
  - `TypographyToken.levelN.body(context)` → `context.theme.typography.body.xxx`
  - `TypographyToken.levelN.display(context)` → `context.theme.typography.display.xxx`
  - `TypographyToken.levelN.resolve(typography)` → `typography.body.xxx` / `typography.display.xxx`
- [ ] 2.4 删除 `lib/core/design/typography.dart`
- [ ] 2.5 从 `lib/core/design/design.dart` 移除 `export 'typography.dart'`
- [ ] 2.6 更新 `docs/02-reference/Design_System.md` 中 `TypographyToken` 相关段落（含 Markdown 渲染段落中对 `TypographyToken` 的引用）
- [ ] 2.7 `flutter analyze` + `flutter test` 验证

### Phase 3: 颜色取用统一（`context.theme.colors.*` → `SemanticColor.*`）

- [ ] 3.1 确认 `SemanticColor.neutral.solid` 已映射到 `fColors.mutedForeground`（在 `theme.dart` 的 `_semanticColorsFor` 中已确认）
- [ ] 3.2 全局替换 `context.theme.colors.mutedForeground`（73 次）→ `SemanticColor.neutral.solid(context)`；同时扫描 `colors.mutedForeground` 局部变量模式（总计 ~369 处 `.mutedForeground` 引用含非 `context.theme.colors.` 前缀写法）
- [ ] 3.3 全局替换 `context.theme.colors.primary`（18 次，注意排除 `primaryForeground`）→ `SemanticColor.primary.solid(context)`
- [ ] 3.4 全局替换 `context.theme.colors.destructive`（4 次）→ `SemanticColor.destructive.solid(context)`
- [ ] 3.5 全局替换 `context.theme.colors.primaryForeground`（1 次）→ `SemanticColor.primary.foreground(context)`
- [ ] 3.6 全局替换 `context.theme.colors.border`（9 次）→ `SemanticColor.neutral.border(context)`
- [ ] 3.7 文档明确：`background`/`card`/`foreground` 三个基础面色走 `context.theme.colors.*` / `SurfaceTokens.*` 是合理的分层职责，不是双轨制
- [ ] 3.8 验证视觉无变化
- [ ] 3.9 `flutter analyze` + `flutter test` 验证

### Phase 4: `Spacing` / `IconSizeTokens` 语义别名

- [ ] 4.1 在 `spacing.dart` 中添加 `xs/sm/md/lg/xl...` 语义别名，`level*` 保留为别名
- [ ] 4.2 在 `icon_size.dart` 中添加 `xs/sm/md/lg/xl...` 语义别名，`level*` 保留为别名
- [ ] 4.3 更新 `docs/02-reference/Design_System.md` 中命名段落
- [ ] 4.4 `flutter analyze` 验证（不改调用点，仅添加别名，零破坏性）
- [ ] 4.5 后续渐进迁移：新代码使用语义别名，旧 `level*` 代码在自然接触时迁移

### Phase 5: `Colors.black/white` + `Color(0xFF...)` 硬编码清理

- [ ] 5.1 扫描全部 6 处 `Colors.black` / `Colors.white`，逐一替换为语义等价物（`context.theme.colors.foreground` / `context.theme.colors.background` 等），例外场景（barcode scanner 等硬件交互）保留并注释
- [ ] 5.2 扫描全部 58 处 `Color(0x...)`，分类为"合法硬编码"（主题定义、品牌色、硬件交互）和"违规硬编码"
- [ ] 5.3 违规硬编码替换为 `SemanticColor` 或 Forui 原生色
- [ ] 5.4 合法硬编码添加注释说明原因
- [ ] 5.5 `flutter analyze` + `flutter test` 验证

### Phase 6: 文档同步

- [ ] 6.1 更新 `docs/02-reference/Design_System.md`：移除 `RadiusTokens` / `TypographyToken` 段落，更新 Token 清单和命名段落
- [ ] 6.2 更新 `AGENTS.md` 中 `Design System` 段落（移除 `RadiusTokens` / `TypographyToken` 引用）
- [ ] 6.3 追加迁移日志到 `docs/03-logs/migration-log/2026-08-30.md`（注意：该文件已存在，必须追加，不能覆盖）
- [ ] 6.4 运行 `dart run scripts/check_doc_coverage.dart --warning-only` 确认文档覆盖

## 风险与注意事项

1. **`context.theme` 依赖**：退役后，圆角和字体不再是无上下文的 `const double`，而是需要 `BuildContext` 来访问 `context.theme.style.borderRadius.xxx`。在 `const` 上下文中（如 `const BoxDecoration(borderRadius: ...)`）无法直接使用。这些位置需要改用运行时构造（`BoxDecoration(borderRadius: context.theme.style.borderRadius.sm)`），或保持 `BorderRadius.circular(8)` 硬编码（如果确实在 `const` 上下文中且性能敏感）。实际审计发现绝大多数 `BorderRadius.circular` 用法已经在 `build()` 方法体内，不是 `const` 上下文。

   特别注意 `lib/core/widgets/common/skeleton.dart` 中有 `this.radius = RadiusTokens.levelN` 作为构造函数默认参数——这些是 `const` 上下文中的默认值，不能直接替换为 `context.theme.style.borderRadius.xxx`（需要 `BuildContext`）。这类位置需要改为 `null` 默认值 + `build()` 内运行时 fallback，或保持硬编码。

2. **`RadiusTokens` 裸 `double` 用法**（约 39 处）：部分代码用 `RadiusTokens.level3` 作为 `double` 值（不是 `BorderRadius.circular(RadiusTokens.level3)`），例如 `radius: RadiusTokens.level4`（构造函数参数）、`Radius.circular(RadiusTokens.level3)` 等。这些需要按上下文分别处理：
   - 需要 `BorderRadius`：直接用 `context.theme.style.borderRadius.xxx`
   - 需要 `Radius`：用 `context.theme.style.borderRadius.xxx.topLeft`（`BorderRadius.topLeft` 返回 `Radius`）
   - 需要裸 `double`：用 `context.theme.style.borderRadius.xxx.topLeft.x`（`Radius.x` 返回 `double`）
   - **API 注意**：`FBorderRadius.xxx` 返回 `BorderRadius` 对象，`BorderRadius` **没有** `.x` 属性。之前的 `.xxx.x` / `.xxx.x.x` 写法是错误的，正确路径是 `.xxx.topLeft.x`。

3. **`TypographyToken` 在 `const` 上下文**：与圆角类似，`TypographyToken.level4.body(context)` 本身已经需要 `BuildContext`，所以退役不会引入新的上下文依赖。

4. **`markdown_style.dart` 依赖 `TypographyToken`**：`lib/core/design/markdown_style.dart` 大量使用 `TypographyToken` 定义 Markdown 渲染样式（legal 和 ai 两套预置的标题阶梯、正文、行高等）。退役 `TypographyToken` 时必须同步迁移该文件到 `context.theme.typography.body/display.*`，否则编译失败。

5. **迁移策略**：建议按 feature 逐个迁移（today → record → medicine → report → mine → settings → search → scan → review → core），每个 feature 迁移后立即 `flutter analyze` 确认无新增错误。

6. **不改 Forui 原生 widget 样式**：Forui widget 内部的圆角和字体由 `FThemeData` 的 `style.borderRadius` 和 `typography` 驱动，退役自定义 token 不影响 Forui widget 本身的样式——因为自定义 token 本来就映射到相同的 Forui 值。

7. **`background`/`card`/`foreground` 不强行映射**：这三个 Forui 基础面色与 `SemanticColor` 语义不同——基础面色是"画布层"色，语义色是"语义层"色。两者并存是分层职责，不是双轨制。文档需明确这一边界。

8. **`Color(0x...)` 合法性判断**：`theme.dart` 中主题族颜色定义（`_ColorOverride` 中的 `Color(0xFF1447E6)` 等）、OAuth 品牌色、barcode scanner 扫描框颜色属于合法硬编码，不应替换。widget 层面的颜色硬编码属于违规，应替换为 token。

## 不建议做的

- **不需要重构 `SemanticColor` 架构**：6×10 的 palette + `ThemeExtension` 注入是正确的深度模型。缺口通过补便捷属性/文档解决，不需要重写。
- **不需要对齐 Material 3**：项目已明确 Forui-first 路线 [[memory:17849504329474592541]]，不要引入 surface tint / Material You dynamic color / Material 3 color scheme。
- **不急于大规模重命名 `level*` 为语义名**：2,129 次 `Spacing.level*` 调用、152 次 `RadiusTokens.level*`（退役后为 0）、120 次 `IconSizeTokens.level*`——大规模重命名风险高、收益低。用加别名 + 新代码规范的方式渐进迁移更稳妥。
