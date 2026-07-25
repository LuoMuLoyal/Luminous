# Luminous 桌面端审查问题修复计划

> 创建日期：2026-07-25
> 来源：`plans/Luminous-review-2026-07-25.md`（全仓库审查报告）
> 状态：W1/W3/W4/W5/W6 已修复，W2 设计系统缺口待实施
> 涉及仓库：Luminous

---

## 一、背景

2026-07-25 对 Luminous `refactor` 分支进行了全仓库审查（`lib/` + `test/`），覆盖最近 5 个 commit 的桌面端 UI/UX 优化变更。审查结论：**无 🔴 严重问题**，但发现 6 个 🟡 警告（W1–W6）及若干测试覆盖缺口。所有警告已经过代码回查，确认真实存在。

W1、W3、W4、W5、W6 已于 2026-07-25 修复完成（迁移日志见 `docs/03-logs/migration-log/2026-07-25.md`）。W2 根因为设计系统覆盖缺口，待任务 8 解决。

---

## 二、待修复问题

### W2: `withValues` API 与 SDK 约束不匹配（根因：设计系统覆盖缺口）

- **文件**: 26 个文件使用 `withValues(alpha:)`，包括 `lib/core/theme/theme.dart`、`lib/features/shell/presentation/page.dart`、`lib/core/widgets/command_palette/command_palette.dart` 等
- **现状**: `pubspec.yaml` SDK 约束为 `>=3.12.0 <4.0.0`。当前开发环境使用 Flutter 3.44.0，`withValues` API 完全可用，SDK 约束不改。
- **验证**: 已确认 `pubspec.yaml` 第 23 行 `sdk: ">=3.12.0 <4.0.0"`；`withValues` 在 26 个源文件中使用。

#### 根因分析：为什么有完整颜色系统却仍然出现 `withValues`

项目有完整的二维语义颜色系统 `SemanticColorPalette`（5 个预计算 tone：`solid` / `foreground` / `muted` / `subtle` / `border`），其文档明确声明：

> "Each tone is a pre-computed concrete `Color` — no runtime alpha arithmetic."
>
> | Tone | Old pattern | Use case |
> |---|---|---|
> | muted | `color.withValues(alpha: 0.08~0.12)` | Chip/badge/tag backgrounds |
> | subtle | `color.withValues(alpha: 0.04~0.06)` | Container/empty-state backgrounds |
> | border | `color.withValues(alpha: 0.18~0.25)` | Colored container borders |

tone 在 `_fixedPalette()` 中按亮暗模式预计算：`subtle` (light 0.05 / dark 0.10)、`muted` (light 0.10 / dark 0.18)、`border` (light 0.20 / dark 0.35)。设计意图就是消灭运行时 alpha 计算。

但 26 处 `withValues` 仍然存在，分为三类：

**A 类 — 迁移未完成（可直接映射到现有 tone）**

这些用法的 alpha 值落在现有 tone 范围内或非常接近，属于旧模式遗留：

| 文件 | alpha | 应映射 tone | tone alpha (light/dark) |
|---|---|---|---|
| `desktop_hover.dart:64` | 0.04 | `subtle` | 0.05 / 0.10 |
| `settings/page.dart:357` | 0.08 | `muted` | 0.10 / 0.18 |
| `command_palette.dart:274` | 0.08 | `muted` | 0.10 / 0.18 |
| `desktop_hover.dart:69` | 0.15 | `border` | 0.20 / 0.35 |
| `sidebar.dart:392` | 0.15 | `border` | 0.20 / 0.35 |
| `card_style.dart:27` | 0.86 (on border) | `border` | 直接用 tone |
| `page_state.dart:222` | 0.88 (on border) | `border` | 直接用 tone |

**B 类 — 设计系统覆盖缺口（5-tone 粒度不足）**

这些用法使用中间 alpha 值，对应的 UI 场景未被 5-tone 体系覆盖。tone 系统只设计了「背景着色」和「边框着色」两个维度，缺少以下语义：

| 场景 | 文件 | alpha 值 | 缺失的语义 tone |
|---|---|---|---|
| 遮罩/scrims | `helpers.dart:81` | 0.4 | `scrim` / `overlay` |
| 遮罩 | `barcode_scanner.dart:281,290` | 0.45 | `scrim` |
| 半透明覆盖 | `risk_red_flag.dart:77` | 0.84 | `cover` |
| 渐变端点 | `components.dart:29,90` | 0.92, 0.74 | `gradientStrong` |
| 禁用态 | `button_styles.dart:147` | 0.5 | `disabled` |
| 骨架屏/shimmer | `desktop_tab_shell.dart:73` | 0.32 | `shimmerBase` |
| 骨架屏 | `deferred_content.dart:46` | 0.32 | `shimmerBase` |
| 骨架屏 | `view.dart:108` | 0.35 | `shimmerBase` |
| 半透明填充 | `new_entry_panel.dart:119` | 0.68 | `fillStrong` |
| 半透明填充 | `voice_entry_dialog.dart:178` | 0.55 | `fillStrong` |
| 半透明填充 | `risk_finding_tile.dart:37` | 0.56 | `fillStrong` |
| 半透明填充 | `mobile_drugbox.dart:376,398` | 0.78, 0.92 | `fillStrong` |
| 半透明填充 | `categories.dart:76` | 0.74 | `fillStrong` |
| 半透明填充 | `hero.dart:318` | 0.24 | `fillStrong` |
| 半透明填充 | `voice_entry_dialog.dart:312` | 0.2 | `fillStrong` |
| 拖拽指示 | `sidebar.dart:397` | 0.4 | `fillStrong` |
| 拖拽边框 | `timeline.dart:583` | 0.3 | `border` (接近) |
| 边框 | `account_settings_sections.dart:495` | 0.4 | `border` (接近) |

**C 类 — 合理的非语义用法**

纯黑遮罩/阴影不属于语义颜色范畴，不应纳入 tone 系统：

| 文件 | 用法 | 说明 |
|---|---|---|
| `helpers.dart:81` | `Colors.black.withValues(alpha: 0.4)` | 对话框 barrier 色 |
| `timeline.dart:586` | `Colors.black.withValues(alpha: 0.12)` | 阴影色 |
| `theme.dart:209` | `colors.foreground.withValues(alpha: 0.16/0.06)` | Material shadowColor |

**结论**：W2 的本质是**设计系统自身的迁移未完成（A 类）+ tone 粒度不足以覆盖所有场景（B 类）**，导致开发者不得不回退到 `withValues`。

#### 平台分布：缺口非桌面端独有

审查报告因覆盖范围是最近 5 个桌面端 commit 的增量变更，容易给人"这是桌面端问题"的错觉。实际全仓库 grep `lib/` 的 25 个使用文件（排除文档注释）分布如下：

| 平台 | 文件数 | 占比 | 代表文件 |
|---|---|---|---|
| 桌面端特有 | 6 | 24% | `desktop_hover.dart`、`command_palette.dart`、`desktop_tab_shell.dart`、`page.dart`（窗口标题栏）、`deferred_content.dart`、`sidebar.dart` |
| 通用 / 移动端 | 19 | 76% | `button_styles.dart`、`theme.dart`、`page_state.dart`、`helpers.dart`、`barcode_scanner.dart`、`mobile_drugbox.dart`、`timeline.dart`、`voice_entry_dialog.dart`、`risk_red_flag.dart`、`hero.dart` 等 |

桌面端仅占约 1/4，通用和移动端代码占约 3/4。B 类缺口（骨架屏 `shimmerBase`、遮罩 `scrim`、禁用态 `disabled`、半透明填充 `fillStrong`）在移动端和通用代码中出现得比桌面端更早、更多。**这是全仓库范围的既有设计系统债务，不是桌面端变更引入的新问题。**

---

## 三、修复任务

### 任务 8: 扩展语义颜色系统 tone 覆盖（W2 — 治本）

**文件**: `lib/core/design/semantic_color_palette.dart`、`lib/core/theme/theme.dart`

**背景**: 见 W2 根因分析。当前 5-tone 体系（solid/foreground/muted/subtle/border）覆盖了「背景着色」和「边框着色」，但缺少「遮罩」「半透明填充」「骨架屏」「禁用态」等语义。开发者不得不回退到 `withValues(alpha:)`，违背了设计系统「no runtime alpha arithmetic」的核心原则。

**方案**: 分两步推进。

**步骤 1 — A 类迁移（低风险，先做）**

将 7 处可直接映射到现有 tone 的 `withValues` 替换为 `SemanticColor.xxx.subtle/muted/border(context)` 调用：

| 文件 | 替换前 | 替换后 |
|---|---|---|
| `desktop_hover.dart:64` | `colors.primary.withValues(alpha: 0.04)` | `SemanticColor.primary.subtle(context)` |
| `settings/page.dart:357` | `colors.primary.withValues(alpha: 0.08)` | `SemanticColor.primary.muted(context)` |
| `command_palette.dart:274` | `theme.colors.primary.withValues(alpha: 0.08)` | `SemanticColor.primary.muted(context)` |
| `desktop_hover.dart:69` | `colors.primary.withValues(alpha: 0.15)` | `SemanticColor.primary.border(context)` |
| `sidebar.dart:392` | `colors.primary.withValues(alpha: 0.15)` | `SemanticColor.primary.border(context)` |
| `card_style.dart:27` | `SemanticColor.neutral.border(context).withValues(alpha: 0.86)` | `SemanticColor.neutral.border(context)` |
| `page_state.dart:222` | `SemanticColor.neutral.border(context).withValues(alpha: 0.88)` | `SemanticColor.neutral.border(context)` |

**步骤 2 — B 类扩展（需设计决策）**

在 `SemanticColorPalette` 中新增 tone 以覆盖 B 类场景。建议新增以下 tone：

```dart
@immutable
class SemanticColorPalette {
  const SemanticColorPalette({
    required this.solid,
    required this.foreground,
    required this.muted,
    required this.subtle,
    required this.border,
    // 新增
    required this.scrim,        // 遮罩/overlay（alpha ≈ 0.4-0.5）
    required this.fillStrong,   // 半透明实色填充（alpha ≈ 0.5-0.9）
    required this.shimmerBase,  // 骨架屏/shimmer 基色（alpha ≈ 0.3-0.35）
    required this.disabled,     // 禁用态色（alpha ≈ 0.5）
  });

  // ... 现有字段 ...

  /// Scrim/overlay background — dialogs, modals, barcode scanner overlays.
  final Color scrim;

  /// Strong semi-transparent fill — drag indicators, gradient stops,
  /// semi-opaque container fills.
  final Color fillStrong;

  /// Shimmer/skeleton base color — loading placeholders.
  final Color shimmerBase;

  /// Disabled state — muted but distinguishable.
  final Color disabled;
}
```

在 `_fixedPalette()` 中预计算这些新 tone（亮暗模式分别计算），与现有 tone 一样在主题创建时烘焙，不做运行时 alpha 计算。

**注意事项**:
- 步骤 2 需要先确认各 B 类场景的 alpha 值是否真的需要统一——部分场景（如渐变端点 0.92 vs 0.74）可能是刻意微调的，不宜强行统一到一个 tone。
- 新增 tone 后，`SemanticColor` 的 `palette()` / `solid()` / `muted()` 等扩展方法需同步增加 `scrim()` / `fillStrong()` / `shimmerBase()` / `disabled()` 快捷方法。
- `SemanticColors._lerpPalette()` 和 `copyWith()` 需同步更新。
- C 类（`Colors.black.withValues`）不纳入 tone 系统，保持原样。
- 此任务规模较大，建议作为独立 PR 提交。

---

## 四、实施顺序与依赖

```
任务 8-A (tone 迁移)        ── 独立，可先行
任务 8-B (tone 扩展)        ── 依赖任务 8-A（先迁移再扩展）
```

建议执行顺序：任务 8-A → 任务 8-B

---

## 五、验证清单

### 代码验证

- [ ] 任务 8-A: 7 处 A 类 `withValues` 已替换为 `SemanticColor` tone 调用
- [ ] 任务 8-B: `SemanticColorPalette` 新增 `scrim` / `fillStrong` / `shimmerBase` / `disabled` tone
- [ ] 任务 8-B: B 类 `withValues` 已替换为新 tone 调用（合理的保留除外）

### 全量验证

- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过
- [ ] `dart run tool/check_doc_coverage.dart --warning-only` 无新增警告
