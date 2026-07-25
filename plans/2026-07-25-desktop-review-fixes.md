# Luminous 桌面端审查问题修复计划

> 创建日期：2026-07-25
> 来源：`plans/Luminous-review-2026-07-25.md`（全仓库审查报告）
> 状态：待实施
> 涉及仓库：Luminous

---

## 一、背景

2026-07-25 对 Luminous `refactor` 分支进行了全仓库审查（`lib/` + `test/`），覆盖最近 5 个 commit 的桌面端 UI/UX 优化变更。审查结论：**无 🔴 严重问题**，但发现 6 个 🟡 警告（W1–W6）及若干测试覆盖缺口。所有警告已经过代码回查，确认真实存在。

本计划将审查报告中的每条警告转化为可执行的修复任务。

---

## 二、已核实问题清单

> 以下所有问题均已通过读取源码验证，确认真实存在。

### W1: `_WindowTitleBarState` 未监听窗口最大化/恢复事件

- **文件**: `lib/features/shell/presentation/page.dart`
- **行号**: 178–193
- **现状**: `_checkMaximized()` 仅在 `initState()` 中调用一次。用户通过双击标题栏、系统菜单、Win+↑/⌘+M 等方式最大化/恢复窗口后，`_isMaximized` 状态不会更新，导致最大化/恢复按钮显示错误图标和行为。
- **验证**: 已确认 `_WindowTitleBarState` 未实现 `WindowListener` 接口，`_checkMaximized()` 为一次性调用。

### W2: `withValues` API 与 SDK 约束不匹配（根因：设计系统覆盖缺口）

- **文件**: 26 个文件使用 `withValues(alpha:)`，包括 `lib/core/theme/theme.dart`、`lib/features/shell/presentation/page.dart`、`lib/core/widgets/command_palette/command_palette.dart` 等
- **现状**: `pubspec.yaml` SDK 约束为 `>=3.12.0 <4.0.0`（对应 Flutter ≈ 3.22），但 `Color.withValues()` 是 Flutter 3.27+ (Dart 3.6) 引入的 API。贡献者或 CI 环境使用 Flutter 3.22–3.24 会导致编译失败。
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

**结论**：W2 的本质不仅是 SDK 约束不匹配，而是**设计系统自身的迁移未完成（A 类）+ tone 粒度不足以覆盖所有场景（B 类）**，导致开发者不得不回退到 `withValues`。仅提升 SDK 约束能修复编译错误，但无法解决根因。

### W3: 项目中导航 API 风格不一致

- **文件**: `lib/core/shortcuts/app_shortcuts.dart`（第 88、100、106、123 行）使用 `GoRouter.of(context).push()` / `GoRouter.of(context).go()`
- **对比**: `lib/features/shell/presentation/page.dart` 等文件使用 `context.push()` / `context.go()` 扩展方法（7 处）
- **现状**: 两种风格功能相同但风格不统一。
- **验证**: 已确认 `app_shortcuts.dart` 有 4 处 `GoRouter.of(context)`，而 `page.dart` 有 7 处 `context.push()`。

### W4: `DragTarget.onWillAcceptWithDetails` 无条件返回 `true`

- **文件**: `lib/features/record/presentation/widgets/sections/sidebar.dart`
- **行号**: 455–458
- **现状**: `onWillAcceptWithDetails` 无条件返回 `true`，即使拖拽数据类型不匹配也会设置 `_isDragHovering = true`。虽然外层有 `canAcceptDrag` 保护，但 `DragTarget` 本身的类型安全验证被绕过。
- **验证**: 已确认第 458 行 `return true;` 无条件返回。

### W5: `CommandPalette` 每次查询重建完整命令列表

- **文件**: `lib/core/widgets/command_palette/command_palette.dart`
- **行号**: 42–51
- **现状**: `_onQueryChanged` 每次触发都调用 `_buildCommands(context)` 重建完整命令列表（~15 个对象）。`_buildCommands` 包含 `AppLocalizations.of(context)!` 和 `MediaQuery.sizeOf(context)` 调用，且每次按键都触发 `setState`。
- **验证**: 已确认第 45 行 `_filtered = _buildCommands(context).where(...)` 在 `_onQueryChanged` 中每次重建。

### W6: 桌面端测试未 mock `window_manager`

- **文件**: `test/desktop/desktop_layout_test.dart`
- **行号**: 146–157
- **现状**: 测试注释明确说明 "window_manager may not be available in test environment"，但测试代码中 `ShellPage` 直接依赖 `window_manager`（通过 `_WindowTitleBar`）。当前测试在 macOS 上可能通过（`_checkMaximized` 直接 return），但 Windows/Linux 环境下运行会失败。
- **验证**: 已确认测试注释第 153–154 行，且无 mock 设置。

---

## 三、修复任务

### P0 — 功能正确性（必须修复）

#### 任务 1: 实现 `WindowListener` 同步窗口最大化状态（W1）

**文件**: `lib/features/shell/presentation/page.dart`

**方案**:

1. `_WindowTitleBarState` 实现 `WindowListener` 接口
2. 在 `initState` 中调用 `windowManager.addListener(this)`
3. 在 `dispose` 中调用 `windowManager.removeListener(this)`
4. 实现 `onWindowMaximize` / `onWindowUnmaximize` 回调，更新 `_isMaximized` 状态
5. 保留 `initState` 中的 `_checkMaximized()` 作为初始状态同步

```dart
class _WindowTitleBarState extends State<_WindowTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted && !_isMaximized) {
      setState(() => _isMaximized = true);
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted && _isMaximized) {
      setState(() => _isMaximized = false);
    }
  }

  // 保留 _checkMaximized() 用于初始化
  Future<void> _checkMaximized() async {
    if (!Platform.isWindows && !Platform.isLinux) return;
    final maximized = await windowManager.isMaximized();
    if (mounted && maximized != _isMaximized) {
      setState(() => _isMaximized = maximized);
    }
  }
  ...
}
```

**注意事项**:
- `WindowListener` 的 `onWindowMaximize` / `onWindowUnmaximize` 回调在所有平台触发，但 `_isMaximized` 的 UI 更新仅影响 Windows/Linux（macOS 使用系统按钮），所以回调中需保留平台判断或确保 macOS 上不影响 UI。
- 需确认 `window_manager` 包已在 `pubspec.yaml` 中（当前已使用，无需新增依赖）。

---

#### 任务 2: 提升 SDK 约束以匹配 `withValues` API（W2 — 治标）

**文件**: `pubspec.yaml`

**方案**:

将 SDK 约束从 `>=3.12.0 <4.0.0` 提升至 `>=3.6.0 <4.0.0`（对应 Flutter 3.27+）。

```yaml
environment:
  sdk: ">=3.6.0 <4.0.0"
```

**注意事项**:
- 提升前需确认所有依赖的最低 SDK 要求兼容 Dart 3.6。
- 建议同时添加 Flutter 版本约束注释或 `flutter` 字段（如项目使用 `flutter` 约束）。
- CI 环境（如有）需同步更新 Flutter SDK 版本。
- 26 个文件使用 `withValues`，提升后无需修改任何调用代码。
- **此任务仅修复编译兼容性，不解决根因**。根因见任务 8。

---

#### 任务 3: 统一导航 API 调用风格（W3）

**文件**: `lib/core/shortcuts/app_shortcuts.dart`

**方案**:

将 `app_shortcuts.dart` 中 4 处 `GoRouter.of(context).push()` / `GoRouter.of(context).go()` 替换为 `context.push()` / `context.go()` 扩展方法，与项目其他文件保持一致。

**具体改动**:

| 行号 | 修改前 | 修改后 |
| ---- | ------ | ------ |
| 88 | `GoRouter.of(context).push(Routes.recordCreate);` | `context.push(Routes.recordCreate);` |
| 100 | `GoRouter.of(context).push(Routes.settings);` | `context.push(Routes.settings);` |
| 106 | `GoRouter.of(context).push(Routes.assistant);` | `context.push(Routes.assistant);` |
| 123 | `GoRouter.of(context).go(tabRoutes[index]);` | `context.go(tabRoutes[index]);` |

**注意事项**:
- `context.push()` / `context.go()` 是 `go_router` 提供的 `BuildContext` 扩展方法，功能与 `GoRouter.of(context).push()` 完全相同。
- `app_shortcuts.dart` 已 import `go_router`（第 4 行），扩展方法可用。

---

### P1 — 代码质量与健壮性

#### 任务 4: 修复 `DragTarget.onWillAcceptWithDetails` 无条件返回 `true`（W4）

**文件**: `lib/features/record/presentation/widgets/sections/sidebar.dart`

**行号**: 455–458

**方案**:

将 `onWillAcceptWithDetails` 改为基于 `candidateData` 判断，并将悬停状态设置移到 `builder` 中通过 `candidateData.isNotEmpty` 判断。

```dart
return DragTarget<TimelineDragData>(
  onWillAcceptWithDetails: (details) {
    // 泛型已约束为 TimelineDragData，显式验证更安全
    return details.data is TimelineDragData;
  },
  onLeave: (_) {
    setState(() => _isDragHovering = false);
  },
  onAcceptWithDetails: (details) {
    setState(() => _isDragHovering = false);
    final targetDate = _dateForDay(widget.day, widget.viewedMonth);
    widget.onRecordDropped!(details.data.recordId, targetDate);
  },
  builder: (context, candidateData, rejectedData) {
    if (candidateData.isNotEmpty && !_isDragHovering) {
      setState(() => _isDragHovering = true);
    }
    return cellContent;
  },
  ...
);
```

**注意事项**:
- 外层 `canAcceptDrag` 检查保留，作为第一道防线。
- `DragTarget<TimelineDragData>` 的泛型已约束数据类型，但显式检查 `details.data is TimelineDragData` 提供额外安全保障。

---

#### 任务 5: 缓存 `CommandPalette` 命令列表（W5）

**文件**: `lib/core/widgets/command_palette/command_palette.dart`

**方案**:

命令列表不依赖查询内容，可在 `initState` 时构建一次并缓存为实例字段，`_onQueryChanged` 仅对缓存列表进行过滤。

```dart
class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  List<_Command> _filtered = [];
  List<_Command> _allCommands = [];  // ← 新增缓存

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    _allCommands = _buildCommands(context);  // ← 构建一次
    _filtered = _allCommands;  // ← 初始显示全部
  }

  void _onQueryChanged() {
    final query = _controller.text.toLowerCase().trim();
    setState(() {
      _filtered = _allCommands.where((cmd) {
        if (query.isEmpty) return true;
        return cmd.searchStrings.any((s) => s.toLowerCase().contains(query));
      }).toList();
      _selectedIndex = 0;
    });
  }
  ...
}
```

**注意事项**:
- `_buildCommands` 依赖 `AppLocalizations.of(context)` 和 `MediaQuery.sizeOf(context)`，在 `initState` 中调用是安全的（`context` 已可用）。
- 如果窗口尺寸在对话框打开期间发生变化（如用户调整窗口大小），命令列表不会自动更新。可接受——命令列表中 `isDesktop` 条件项仅在打开时评估一次。

---

#### 任务 6: Mock `window_manager` 以确保跨平台测试稳定（W6）

**文件**: `test/desktop/desktop_layout_test.dart`

**方案**:

在 `setUp` 中使用 `MethodChannel` mock 或创建 `window_manager` 的 stub 实现。

**方案 A — MethodChannel mock（推荐）**:

```dart
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

setUp(() async {
  // Mock window_manager MethodChannel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(windowManager.channel, (call) async {
    switch (call.method) {
      case 'isMaximized':
        return false;
      case 'getTitleBarHeight':
        return 32;
      default:
        return null;
    }
  });
  await windowManager.ensureInitialized();
});
```

**方案 B — 条件跳过**（如果 mock 过于复杂）:

在测试文件顶部添加平台判断，非 macOS 平台跳过窗口相关测试：

```dart
// 仅在 macOS 上运行窗口相关测试，其他平台跳过
// 因为 window_manager 在测试环境可能不可用
@TestOn('mac-os')
```

**注意事项**:
- 方案 A 更健壮，确保跨平台测试一致性。需研究 `window_manager` 的 channel 名称和调用方法。
- 方案 B 简单但降低了测试覆盖率。
- 建议优先尝试方案 A，如果 mock 复杂度过高再降级为方案 B。

---

### P2 — 测试覆盖补齐

#### 任务 7: 补齐桌面端测试覆盖缺口

**新增测试文件**: `test/desktop/`

审查报告指出当前 3 个桌面端测试文件（641 行）覆盖了布局和快捷键，但以下场景未覆盖：

| # | 测试场景 | 建议测试文件 | 优先级 |
| - | -------- | ------------ | ------ |
| 1 | 窗口控制按钮点击（最小化/最大化/关闭） | `test/desktop/window_controls_test.dart` | P2 |
| 2 | 命令面板键盘导航（Up/Down/Enter/Escape） | `test/desktop/command_palette_keyboard_test.dart` | P1 |
| 3 | 拖拽功能（`Draggable` + `DragTarget` 交互） | `test/desktop/drag_drop_test.dart` | P2 |
| 4 | 侧边栏折叠/展开状态持久化 | `test/desktop/sidebar_persistence_test.dart` | P2 |

**注意事项**:
- 窗口控制按钮测试依赖任务 6 的 `window_manager` mock。
- 命令面板键盘导航测试可在不依赖 `window_manager` 的情况下独立编写。
- 拖拽测试需要构造 `TimelineDragData` 测试数据。

---

#### 任务 8: 扩展语义颜色系统 tone 覆盖（W2 — 治本）

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
- 此任务规模较大，建议作为独立 PR，与任务 2（SDK 提升）分开提交。

---

## 四、实施顺序与依赖

```
任务 2 (SDK 约束)          ── 独立，可先行（治标）
任务 3 (导航 API 统一)      ── 独立，可先行
任务 5 (命令列表缓存)       ── 独立，可先行
任务 1 (WindowListener)    ── 独立
任务 6 (测试 mock)          ── 依赖任务 1（mock 需覆盖新的 WindowListener 回调）
任务 4 (DragTarget 修复)    ── 独立
任务 7 (测试补齐)           ── 依赖任务 6（窗口控制按钮测试）
任务 8-A (tone 迁移)        ── 独立，可先行
任务 8-B (tone 扩展)        ── 依赖任务 8-A（先迁移再扩展）
```

建议执行顺序：
- **快速修复批**：任务 2 → 任务 3 → 任务 5 → 任务 1 → 任务 4 → 任务 6 → 任务 7
- **设计系统批**（可并行）：任务 8-A → 任务 8-B

---

## 五、验证清单

### 代码验证

- [ ] 任务 1: 实现 `WindowListener`，窗口最大化/恢复按钮状态正确同步
- [ ] 任务 2: SDK 约束提升至 `>=3.6.0 <4.0.0`，`flutter analyze` 无错误
- [ ] 任务 3: `app_shortcuts.dart` 中无 `GoRouter.of(context)` 调用
- [ ] 任务 4: `onWillAcceptWithDetails` 不再无条件返回 `true`
- [ ] 任务 5: `_onQueryChanged` 不再调用 `_buildCommands`
- [ ] 任务 6: 桌面端测试在 Windows/Linux 环境下可运行
- [ ] 任务 8-A: 7 处 A 类 `withValues` 已替换为 `SemanticColor` tone 调用
- [ ] 任务 8-B: `SemanticColorPalette` 新增 `scrim` / `fillStrong` / `shimmerBase` / `disabled` tone
- [ ] 任务 8-B: B 类 `withValues` 已替换为新 tone 调用（合理的保留除外）

### 全量验证

- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过
- [ ] `dart run tool/check_doc_coverage.dart --warning-only` 无新增警告

---

## 六、注意事项

### 6.1 `WindowListener` 平台兼容性

`window_manager` 的 `WindowListener` 回调在所有平台触发。但 `_WindowTitleBar` 的窗口控制按钮仅在 Windows/Linux 上渲染（macOS 使用系统 traffic-light 按钮）。因此回调中需确保在 macOS 上不影响 UI——实际上由于 macOS 不渲染这些按钮，`_isMaximized` 状态变化不会产生可见影响，无需额外平台判断。

### 6.2 SDK 约束提升的影响

提升 SDK 约束至 `>=3.6.0` 会阻止使用 Dart 3.12–3.5 的环境编译。需确认：
- 本地开发环境 Flutter 版本 ≥ 3.27
- CI 环境 Flutter 版本 ≥ 3.27（检查 `.github/workflows/` 或 CI 配置）
- 所有 `pubspec.yaml` 依赖的最低 SDK 要求兼容 Dart 3.6

### 6.3 文档更新

完成代码修复后需运行 `dart run tool/check_doc_coverage.dart --warning-only` 确认文档覆盖。如有涉及 UI/运行时行为的变更（特别是任务 1 的窗口状态同步），需追加 `docs/03-logs/migration-log/YYYY-MM-DD.md` 迁移日志条目。
