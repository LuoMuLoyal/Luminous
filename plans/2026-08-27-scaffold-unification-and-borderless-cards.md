# Scaffold 背景统一 & 无边框卡片方案

> 日期: 2026-08-27
> 状态: 待实施

## 背景

当前移动端 5 个 tab 页面背景色设置方式不统一——有的用 `FScaffold`，有的用 `DecoratedBox(color: colors.background)` 手动包。同时 light 模式下 `background` 和 `card` 都是纯白 `#FFFFFF`，卡片完全靠 `border` 区分，视觉噪音偏高。成熟应用（iOS Health、Linear、Notion）普遍采用灰底 + 白卡 + 无边框的色差分层策略。

## 目标

1. 统一 Scaffold 用法——只保留 `FScaffold` 一条路径提供背景色
2. scaffold 背景从纯白改为淡灰（`colors.secondary` = `#F5F5F5`）
3. 卡片去掉边框（urgent/warning 语义强调除外）

## 改动清单

### 1. `lib/core/theme/theme.dart`

#### 1a. `appThemeData()` — 增加 scaffoldStyle override

在 `FThemeData` 构造中传入自定义 `scaffoldStyle`，把 `backgroundColor` 和 `sidebarBackgroundColor` 从默认的 `colors.background`（纯白）改为 `colors.secondary`（`#F5F5F5`）。

dark 模式下用 `Color.lerp(colors.background, colors.secondary, 0.5)` 做一个介于两者之间的值，避免 dark 模式背景过亮。

```dart
final scaffoldBackgroundColor = isDark
    ? Color.lerp(colors.background, colors.secondary, 0.5)!
    : colors.secondary;

return FThemeData(
  ...
  scaffoldStyle: FScaffoldStyle.inherit(
    colors: colors,
    style: base.style,
  ).copyWith(
    backgroundColor: scaffoldBackgroundColor,
    sidebarBackgroundColor: scaffoldBackgroundColor,
  ),
  ...
);
```

#### 1b. `appThemeData()` — 增加 cardStyle override（去边框）

在 `FThemeData` 构造中传入自定义 `cardStyle`，去掉默认的 `BorderSide(color: colors.border)`：

```dart
cardStyle: base.cardStyle.copyWith(
  decoration: .delta([
    .base(
      .shapeDelta(
        color: colors.card,
        shape: RoundedSuperellipseBorder(
          borderRadius: base.style.borderRadius.lg,
        ),
      ),
    ),
  ]),
),
```

#### 1c. `foruiMaterialTheme()` — 同步 scaffold 背景色 + Material card 去边框

```dart
final scaffoldBg = theme.scaffoldStyle.backgroundColor;
return material.copyWith(
  scaffoldBackgroundColor: scaffoldBg,
  canvasColor: scaffoldBg,
  cardColor: theme.colors.card,
  dividerColor: theme.colors.border,
  shadowColor: ElevationTokens.shadowColor(theme.colors),
  cardTheme: material.cardTheme.copyWith(
    shape: RoundedSuperellipseBorder(
      borderRadius: theme.style.borderRadius.md,
    ),
  ),
);
```

### 2. `lib/features/today/presentation/widgets/shared/card_style.dart` — `todayCardStyle` 去边框

- `emphasis`、`soft`、`neutral` 三种 tone：边框改为 `BorderSide.none`
- `urgent`、`warning` 两种 tone：**保留语义色边框**（这是警示而非分隔）

### 3. `lib/features/today/presentation/widgets/views/dashboard_view.dart` — `_HealthEventCard` 去边框

当前手动 `DecoratedBox` 带 `Border.all(color: colors.border)`，去掉 border 行即可。

### 4. `lib/features/today/presentation/widgets/sections/suggestion_state_views.dart` — `SuggestionSkeleton` 去边框

`SuggestionSkeleton` 的 `BoxDecoration` 有 `border: Border.all(color: colors.border)`，去掉 border 行。

### 5. 移动端 tab 页面 — 去掉 `DecoratedBox(color: colors.background)` 包裹

以下 4 个位置去掉手动背景色，让顶层 `ShellPage` 的 `FScaffold` 统一提供：

| 文件 | 位置 | 改动 |
|---|---|---|
| `lib/features/today/presentation/pages/page.dart` | 移动端 `DecoratedBox(color: colors.background)` | 改为 `SafeArea(bottom: false, child: content)` |
| `lib/features/mine/presentation/pages/page.dart` | 移动端 `DecoratedBox(color: colors.background)` | 改为 `SafeArea(bottom: false, child: ...)` + 删除未使用的 `colors` 变量 |
| `lib/features/report/presentation/pages/page.dart` | `_ReportMobileShell` 的 `DecoratedBox` | 改为 `SafeArea(bottom: false, child: ...)` |
| `lib/features/medicine/presentation/pages/page.dart` | `_MedicineMobileShell` 的 `DecoratedBox` | 改为 `SafeArea(bottom: false, child: ...)` + 删除未使用的 `colors` 变量 |

### 6. `lib/features/shell/presentation/desktop_tab_shell.dart` — 统一背景色

当前内容区背景用 `SemanticColor.neutral.shimmerBase(context)`，改为 `context.theme.scaffoldStyle.backgroundColor`，与移动端统一。

### 7. 不改动的地方

- `lib/features/shell/presentation/page.dart` — 桌面端 sidebar 用 `colors.background`（纯白），**保留不变**。白色 sidebar vs 灰色内容区是好对比，符合成熟桌面应用惯例。
- `lib/features/auth/presentation/widgets/shared/shell.dart` — 认证页面是特殊全屏体验，`ColoredBox(color: colors.background)` **保留不变**。
- `lib/core/widgets/layout/page_scaffold.dart` — 子页面 `PageScaffold` 用 `FScaffold`，背景自动从 theme 继承，**无需改动**。
- `lib/core/design/elevation.dart` — shadow tokens **保留不变**，去边框后如果某些卡片需要微弱 elevation 可以后续按需启用。

## 影响面

- **视觉**：light 模式所有页面背景从纯白变淡灰，卡片从有边框变无边框。dark 模式变化极小（背景微调）。
- **代码**：6 个文件改动，均为小改动，无逻辑变更。
- **风险**：低。`colors.background` token 本身不动，只改 `FScaffoldStyle.backgroundColor`，不影响用 `colors.background` 做边框/前景色的业务代码。

## 验证

```bash
cd Luminous
flutter analyze
dart run scripts/check_doc_coverage.dart --warning-only
```
