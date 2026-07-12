# Luminous 桌面端 UI 优化计划

> 创建日期：2026-07-12
> 状态：待评审
> 涉及仓库：Luminous

---

## 一、背景与问题概述

用户反馈桌面端体验存在四个核心问题：

1. **页面布局不一致** — 有的页面显示侧边栏，有的页面全屏，切换时视觉跳变严重
2. **动画不流畅** — Tab 切换、侧边栏展开/收起、页面过渡存在卡顿和闪烁
3. **侧边栏子项设计不合理** — 子项像是硬凑的，数量不均、层级混乱
4. **右侧内容区视觉不佳** — 缺少统一的视觉框架，各页 padding/topbar/scroll 各自为政

---

## 二、现有状态分析（已与代码库核实）

### 2.1 架构总览

```
app/router.dart
  └─ StatefulShellRoute.indexedStack
       ├─ Branch 0: TodayPage   (NoTransitionPage)
       ├─ Branch 1: RecordPage  (NoTransitionPage)
       ├─ Branch 2: MedicinePage(NoTransitionPage)
       ├─ Branch 3: ReportPage  (NoTransitionPage)
       ├─ Branch 4: MinePage    (NoTransitionPage)
       └─ 全屏路由（slidePage / fadePage）
            ├─ SettingsPage (PageScaffold + ResponsiveContentFrame)
            ├─ RecordCreate / MedicineSearch / ...
            └─ ...
```

桌面端（width >= 1200px）Shell 结构（`shell/presentation/page.dart`）：

```
FScaffold
  ├─ sidebar: _DesktopSidebar (FSidebar)
  │    ├─ header: app icon + title
  │    ├─ children: Today / Record(1 child) / Medicine(3 children) / Report / Mine(4 children)
  │    └─ footer: Settings(9 children!) / Help
  └─ child: SafeArea + Padding(16) + Column
       ├─ _DesktopBreadcrumb (FBreadcrumb)
       └─ Expanded(content = navigationShell)
```

### 2.2 问题一：页面布局不一致

**根因：每个 Tab 页面自己决定桌面端布局，没有统一的桌面端 Shell 约束。**

| Tab 页 | 桌面端布局 | 自有 TopBar | 滚动容器 | 外层 Padding |
|---|---|---|---|---|
| TodayPage | `LayoutBuilder` + `Center` + `ConstrainedBox(maxWidth)` | 无 | 无（内容自管） | Shell 提供 8px left |
| RecordPage | `ShellDeferredContent` + `FScaffold(header: AppTopBar)` + `ResponsiveContentFrame` + `SingleChildScrollView` | `AppTopBar` | `SingleChildScrollView` | Shell 8px + ResponsiveContentFrame horizontal padding |
| MedicinePage | `ShellDeferredContent` + `_MedicineDesktopShell`（自定义 `ListView`） | 无（搜索栏在 ListView 内） | `ListView` | `Spacing.level6` 全方位 |
| ReportPage | `ShellDeferredContent` + `_ReportDesktopShell`（自定义 `ListView`） | `ReportTopBar`（在 ListView 内） | `ListView` | `Spacing.level6` 全方位 |
| MinePage | `ShellDeferredContent` + `_MineDesktopShell`（自定义 `ListView`） | `MineTopBar`（在 ListView 内） | `ListView` | `Spacing.level6` 全方位 |

**问题细节：**

- TodayPage 没有 TopBar，直接渲染内容；其他页面都有 TopBar → 视觉不一致
- RecordPage 使用 `FScaffold` + `AppTopBar`（嵌入 header），而 Medicine/Report/Mine 各自定义 `_XxxDesktopShell` 用 `ListView` 内嵌 TopBar → 两种不同的 TopBar 集成方式
- 桌面端全屏路由（如 SettingsPage）使用 `PageScaffold` + `FHeader.nested` → 第三种顶部样式
- 内容区最大宽度不统一：TodayPage 用 `LayoutScaleResolver.maxContentWidth`（1400px），RecordPage 用 `ResponsiveContentFrame`（1400px），Medicine/Report/Mine 没有最大宽度限制（撑满 ListView）
- Record 页桌面端的 `AppTopBar` 会额外加一次 `SafeArea` + `pageHorizontalPadding`，而 Shell 已经加了 Padding → **双重 padding**

### 2.3 问题二：动画不流畅

**根因：`NoTransitionPage` + `ShellDeferredContent` 的组合导致 Tab 切换时先闪骨架再弹内容。**

- **Tab 切换无过渡动画**：所有 5 个 Tab 的 `pageBuilder` 都使用 `NoTransitionPage`，切换时内容直接替换，没有任何过渡
- **ShellDeferredContent 闪烁**：每次 Tab 首次进入时，先渲染骨架占位（`_DefaultTabPlaceholder`），下一帧才渲染真实内容 → 用户看到一次骨架→内容的闪烁
- **侧边栏子项展开/收起**：`FSidebarItem.children` 的展开收起由 Forui 内部控制，动画时长和曲线不可配置，可能存在不流畅
- **全屏路由 slidePage 过渡**：使用 `Curves.easeOutCubic`，220ms 入 / 150ms 出 — 这部分本身没有问题，但如果叠加 `ShellDeferredContent` 在子页面中，也会有骨架闪烁

### 2.4 问题三：侧边栏子项设计不合理

当前侧边栏子项分布：

```
Today      (无子项)
Record     (1 子项: 新建记录)          ← 只有 1 个，展开后显得空旷
Medicine   (3 子项: 搜索/安全检查/提醒)
Report     (无子项)
Mine       (4 子项: 资料/过敏/健康/用药档案)
─────────────────────────────────
Footer:
Settings   (9 子项!)                   ← 通知/主题/语言/无障碍/AI/导出/存储/安全锁/关于
Help       (无子项)
```

**问题：**

1. **Settings 的 9 个子项过多** — 全部展开后侧边栏被塞满，视觉拥挤
2. **Record 只有 1 个子项** — 展开后只有一行，显得多余
3. **Today 和 Report 没有子项** — 与有子项的页面视觉不平衡
4. **子项功能与页面内实际功能不匹配** — 例如 Medicine 页面桌面端有搜索栏和安全检查按钮，侧边栏的子项重复了这些入口；而 Record 页面的"新建记录"在页面内已有 prominent 按钮
5. **层级混乱** — Settings 是 footer 区域的全屏路由，但它的子项也是全屏路由，用户点击后侧边栏消失，体验割裂

### 2.5 问题四：右侧内容区视觉不佳

**问题：**

1. **面包屑太简陋** — 只有 `App Title > Tab Name` 两级，且样式朴素，占据顶部空间但信息量极低
2. **内容区无视觉边界** — 内容直接渲染在 Shell 的 Padding 内，没有 Card/Container 包裹，与侧边栏之间缺少视觉分隔
3. **各页内容区宽度不一致** — Today/Record 限制 maxWidth 1400px 并居中，Medicine/Report/Mine 撑满全部剩余宽度
4. **背景色单调** — 内容区与侧边栏使用相同的 `theme.colors.background`，没有层次感
5. **TopBar 样式不统一** — Record 用 `AppTopBar`（大标题 + trailing actions），Medicine/Report/Mine 各自内嵌不同结构的 TopBar，Today 没有 TopBar

---

## 三、优化方案

### 3.1 统一桌面端 Shell 布局

**目标：** 所有 Tab 页面在桌面端共享统一的外壳结构，各页面只负责提供内容内容和可选的 TopBar 配置。

#### 3.1.1 新建 `DesktopTabShell` 组件

位置：`lib/features/shell/presentation/desktop_tab_shell.dart`

```
DesktopTabShell
  ├─ TopBar 区域（统一 AppTopBar，由各页面通过参数配置）
  │   ├─ title（必填）
  │   ├─ trailing actions（可选）
  │   └─ bottom（可选，如 Report 的日期选择器）
  ├─ Content 区域
  │   ├─ 统一 maxWidth 约束（由 LayoutScaleResolver 决定）
  │   ├─ 统一滚动容器（CustomScrollView 或 SingleChildScrollView）
  │   └─ 统一 padding
  └─ 统一背景色（内容区使用 subtle muted 背景，与侧边栏区分）
```

各 Tab 页面只需返回内容 Widget，不再自己包裹 Shell/Padding/TopBar。

#### 3.1.2 简化 ShellPage 桌面端结构

```
ShellPage (桌面端)
  ├─ FScaffold
  │   ├─ sidebar: _DesktopSidebar (优化后，见 3.3)
  │   └─ child: DesktopTabShell
  │        ├─ AppTopBar (由当前 Tab 配置)
  │        └─ Expanded(content)
  └─ 移除 _DesktopBreadcrumb（信息量太低，用 AppTopBar 的标题替代）
```

#### 3.1.3 全屏路由桌面端行为

全屏路由（Settings、RecordCreate 等）在桌面端的优化策略：

- **方案 A（推荐）：** 桌面端全屏路由仍覆盖整个窗口（隐藏侧边栏），但使用 `PageScaffold` 统一顶部样式。这是当前行为，保持不变。
- **方案 B（备选）：** 桌面端全屏路由在侧边栏右侧渲染（保留侧边栏）。需要改造路由结构，工作量较大。

> 选择方案 A，因为全屏路由通常是临时操作（创建记录、编辑设置），完成后返回。保留侧边栏反而增加复杂度。

### 3.2 优化动画流畅度

#### 3.2.1 Tab 切换动画

将 `NoTransitionPage` 替换为轻量 `fadePage` 过渡：

```dart
// app/router.dart — 每个 Branch 的 pageBuilder
pageBuilder: (context, state) => CustomTransitionPage(
  key: state.pageKey,
  child: const TodayPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child),
  transitionDuration: const Duration(milliseconds: 150),
  reverseTransitionDuration: Duration.zero,
),
```

- 150ms 淡入，无淡出（切走时直接消失），避免双向动画造成的视觉干扰
- 比 `NoTransitionPage` 多一丝过渡感，但不至于像 slide 那样明显

#### 3.2.2 移除 ShellDeferredContent 的骨架闪烁

**方案：** 将 `ShellDeferredContent` 的默认 placeholder 从骨架屏改为透明/背景色占位：

```dart
// 修改 deferred_content.dart
// 之前：placeholder 显示骨架
// 之后：placeholder 为透明 ColoredBox，仅延迟一帧构建真实内容
return widget.placeholder ??
    ColoredBox(color: Colors.transparent, child: const SizedBox.expand());
```

这样 Tab 切换时不会看到骨架→内容的闪烁，只会看到 150ms 的淡入。

> **注意：** 保留 `ShellDeferredContent` 的延迟构建机制（避免首次 Tab 切换卡顿），只改 placeholder 视觉。

#### 3.2.3 侧边栏子项展开动画

如果 Forui `FSidebarItem.children` 的展开动画不够流畅，考虑：

- 使用 `FSidebarItem` 的 `initialExpanded` 属性预展开当前选中 Tab 的子项
- 或者完全移除可展开子项（见 3.3），改用扁平化导航

### 3.3 重新设计侧边栏

#### 3.3.1 设计原则

- 主导航项 = 5 个 Tab（Today / Record / Medicine / Report / Mine），不含子项
- 底部固定区 = Settings + Help，不含子项
- **移除所有 FSidebarItem.children** — 侧边栏只做一级导航，不做二级展开
- 二级导航通过页面内的 TopBar actions、页面内卡片/按钮入口实现

#### 3.3.2 新侧边栏结构

```
FSidebar
  ├─ header: app icon + title（不变）
  ├─ children: 5 个扁平 Tab 项（无 children）
  │    ├─ Today
  │    ├─ Record
  │    ├─ Medicine
  │    ├─ Report
  │    └─ Mine
  └─ footer:
       ├─ Settings（无 children，点击直接跳全屏设置页）
       └─ Help（不变）
```

#### 3.3.3 各 Tab 页面的二级入口

移除侧边栏子项后，需要在页面内提供等价入口：

| 原侧边栏子项 | 新位置 |
|---|---|
| Record → 新建记录 | Record 页 TopBar trailing 的 `+` 按钮（已有） |
| Medicine → 药品搜索 | Medicine 页顶部搜索栏（已有） |
| Medicine → 安全检查 | Medicine 页 TopBar trailing 的安全检查按钮（已有 `_MedicineSafeGuardPill`） |
| Medicine → 用药提醒 | Medicine 页 TopBar trailing 的提醒按钮（已有 `_MedicineNotificationButton`） |
| Mine → 个人资料 | Mine 页内的资料编辑卡片（已有） |
| Mine → 过敏史 | Mine 页健康档案区的入口（已有） |
| Mine → 健康状况 | Mine 页健康档案区的入口（已有） |
| Mine → 用药档案 | Mine 页健康档案区的入口（已有） |
| Settings → 各子项 | Settings 全屏页内的分组列表（已有） |

> **所有原侧边栏子项在页面内都已有对应入口，移除子项不会丢失功能。**

#### 3.3.4 ARB 清理

移除以下不再使用的 ARB key（如果确认无其他引用）：

```
sidebarRecordCreate
sidebarMedicineSearch
sidebarMedicineRiskCheck
sidebarMedicineReminders
sidebarMineProfile
sidebarMineAllergy
sidebarMineCondition
sidebarMineMedicine
sidebarSettingsNotifications
sidebarSettingsTheme
sidebarSettingsLanguage
sidebarSettingsAccessibility
sidebarSettingsAi
sidebarSettingsExport
sidebarSettingsSecurityPin
sidebarSettingsAbout
```

> 需要先 `grep` 确认这些 key 没有在其他位置引用。`settingsDataStorageTitle` 在 SettingsPage 中直接使用，需保留。

### 3.4 优化右侧内容区视觉

#### 3.4.1 内容区背景层次

```
侧边栏背景:  theme.colors.background (默认)
内容区背景:  theme.colors.background (默认)
内容卡片:    白色/暗色 elevated surface
```

改为：

```
侧边栏背景:  theme.colors.background (不变)
内容区背景:  SemanticColor.neutral.muted(context).withValues(alpha: 0.32)
           (浅灰/浅暗背景，与侧边栏区分)
内容卡片:    theme.colors.background (实色卡片浮在 muted 背景上)
```

> Medicine/Report/Mine 页面已经在用 `SemanticColor.neutral.muted` 作为背景色，统一推广到所有页面。

#### 3.4.2 统一 TopBar

所有 Tab 页面桌面端统一使用 `AppTopBar`：

| Tab | title | trailing |
|---|---|---|
| Today | `l10n.tabToday` | 无 |
| Record | `l10n.tabRecord` | 日期导航按钮组 + 新建按钮（已有） |
| Medicine | `l10n.tabMedicine` | 安全检查 + 提醒按钮 + 搜索入口（已有） |
| Report | `l10n.tabReport` | 日期范围 + 查询切换 + 生成/同步按钮（已有） |
| Mine | `l10n.tabMine` | 通知 + 设置按钮（已有） |

#### 3.4.3 内容区最大宽度

所有 Tab 页面桌面端统一使用 `LayoutScaleResolver.maxContentWidth`（当前 1400px）居中约束。

- 移除各页面自己的 `ConstrainedBox` / `ResponsiveContentFrame` 宽度逻辑
- 由 `DesktopTabShell` 统一处理

#### 3.4.4 移除面包屑

移除 `_DesktopBreadcrumb`，用 `AppTopBar` 的大标题替代面包屑的信息功能。

- 面包屑只有 `App Title > Tab Name` 两级，信息量极低
- `AppTopBar` 的大标题已经标明当前页面
- 移除后面内容区顶部更简洁

---

## 四、实施步骤

### 第一阶段：侧边栏精简 + Shell 结构统一（核心改动）

| 步骤 | 内容 | 涉及文件 | 工作量 |
|---|---|---|---|
| 1 | 新建 `DesktopTabShell` 组件 | `lib/features/shell/presentation/desktop_tab_shell.dart`（新建） | 1h |
| 2 | 重构 `ShellPage` 桌面端布局 | `lib/features/shell/presentation/page.dart` | 1h |
| 3 | 移除 `_DesktopSidebar` 中所有 `FSidebarItem.children` | `lib/features/shell/presentation/page.dart` | 0.5h |
| 4 | 移除 `_DesktopBreadcrumb` | `lib/features/shell/presentation/page.dart` | 0.25h |
| 5 | 改造 `TodayPage` 桌面端使用 `DesktopTabShell` | `lib/features/today/presentation/pages/page.dart` | 0.5h |
| 6 | 改造 `RecordPage` 桌面端使用 `DesktopTabShell` | `lib/features/record/presentation/pages/page.dart` | 1h |
| 7 | 改造 `MedicinePage` 桌面端使用 `DesktopTabShell` | `lib/features/medicine/presentation/pages/page.dart` | 1h |
| 8 | 改造 `ReportPage` 桌面端使用 `DesktopTabShell` | `lib/features/report/presentation/pages/page.dart` | 1h |
| 9 | 改造 `MinePage` 桌面端使用 `DesktopTabShell` | `lib/features/mine/presentation/pages/page.dart` | 0.5h |

### 第二阶段：动画优化

| 步骤 | 内容 | 涉及文件 | 工作量 |
|---|---|---|---|
| 10 | 将 Tab 路由 `NoTransitionPage` 改为轻量 fade 过渡 | `lib/app/router.dart` | 0.25h |
| 11 | 修改 `ShellDeferredContent` 默认 placeholder 为透明 | `lib/features/shell/presentation/deferred_content.dart` | 0.25h |

### 第三阶段：视觉统一 + 清理

| 步骤 | 内容 | 涉及文件 | 工作量 |
|---|---|---|---|
| 12 | 统一内容区背景色为 `SemanticColor.neutral.muted` | `DesktopTabShell`（步骤 1 中处理） | — |
| 13 | 统一内容区 maxWidth 约束 | `DesktopTabShell`（步骤 1 中处理） | — |
| 14 | grep 确认 sidebar ARB key 无其他引用后清理 | `lib/l10n/src/settings_zh.arb`、`settings_en.arb` | 0.5h |
| 15 | 运行 `flutter gen-l10n` | — | 0.1h |

### 第四阶段：验证

| 步骤 | 内容 | 工作量 |
|---|---|---|
| 16 | `flutter analyze` 零问题 | 0.25h |
| 17 | `flutter test` 全部通过 | 0.25h |
| 18 | 桌面端手动验证：Tab 切换流畅、侧边栏简洁、各页布局统一、全屏路由正常 | 0.5h |

---

## 五、DesktopTabShell 设计草案

```dart
/// 桌面端 Tab 页面统一外壳。
///
/// 由 [ShellPage] 在桌面端使用，为所有 Tab 页面提供统一的：
/// - AppTopBar（标题 + trailing actions + 可选 bottom）
/// - 内容区最大宽度约束
/// - 内容区背景色（muted，与侧边栏区分）
/// - 统一 padding
class DesktopTabShell extends StatelessWidget {
  const DesktopTabShell({
    super.key,
    required this.title,
    this.trailing = const [],
    this.bottom,
    required this.child,
    this.scrollable = true,
  });

  final String title;
  final List<Widget> trailing;
  final Widget? bottom;
  final Widget child;

  /// 是否使用滚动容器包裹内容。默认 true。
  /// 某些页面（如 Today）可能自行管理滚动，设为 false。
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = LayoutScaleResolver.resolve(width);
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.muted(context).withValues(alpha: 0.32),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 统一 TopBar
            AppTopBar(
              title: title,
              trailing: trailing,
              bottom: bottom,
            ),
            // 内容区
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: layout.maxContentWidth,
                  ),
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.pageHorizontalPadding,
                            vertical: Spacing.level5,
                          ),
                          child: child,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: layout.pageHorizontalPadding,
                            vertical: Spacing.level5,
                          ),
                          child: child,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 六、各页面改造要点

### 6.1 TodayPage

**当前：** `LayoutBuilder` + `Center` + `ConstrainedBox` + `SafeArea`，无 TopBar

**改造后：**

```dart
return DesktopTabShell(
  title: l10n.tabToday,
  child: PageStateSwitch(...),
);
```

- 移除 `LayoutBuilder` / `Center` / `ConstrainedBox` / `SafeArea`（由 DesktopTabShell 处理）
- 移除 `DecoratedBox`（由 DesktopTabShell 处理）
- `maxWidth` 由 DesktopTabShell 统一处理

### 6.2 RecordPage

**当前：** `ShellDeferredContent` + `FScaffold(header: AppTopBar)` + `ResponsiveContentFrame` + `SingleChildScrollView`

**改造后：**

```dart
return ShellDeferredContent(
  child: DesktopTabShell(
    title: l10n.tabRecord,
    trailing: headerActions,
    child: PageStateSwitch(...),
  ),
);
```

- 移除 `FScaffold` + `AppTopBar`（由 DesktopTabShell 处理）
- 移除 `ResponsiveContentFrame`（由 DesktopTabShell 处理）
- 移除 `SafeArea`（由 DesktopTabShell 处理）
- 保留 `ShellDeferredContent` 延迟构建机制
- 保留 `headerActions`（传给 DesktopTabShell.trailing）

### 6.3 MedicinePage

**当前：** `ShellDeferredContent` + `_MedicineDesktopShell`（自定义 ListView + 搜索栏内嵌）

**改造后：**

```dart
return ShellDeferredContent(
  child: PageStateSwitch(
    ...
    readyBuilder: (workspace, isPreview) => DesktopTabShell(
      title: l10n.tabMedicine,
      trailing: [
        _MedicineSafeGuardPill(),
        _MedicineNotificationButton(),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MedicineMobileSearchBar(), // 搜索栏移到内容区顶部
          SizedBox(height: Spacing.level4),
          content,
        ],
      ),
    ),
  ),
);
```

- 删除 `_MedicineDesktopShell`
- 搜索栏从 ListView 内移到 DesktopTabShell 内容区顶部
- 保留 `_MedicineSafeGuardPill` 和 `_MedicineNotificationButton` 作为 trailing

### 6.4 ReportPage

**当前：** `ShellDeferredContent` + `_ReportDesktopShell`（自定义 ListView + `ReportTopBar` 内嵌）

**改造后：**

```dart
return ShellDeferredContent(
  child: PageStateSwitch(
    ...
    readyBuilder: (dashboard, isPreview) => DesktopTabShell(
      title: l10n.tabReport,
      bottom: ReportTopBar(
        dateRangeLabel: ...,
        selectedQuery: ...,
        onQueryChanged: ...,
        ...
      ),
      child: dashboardView,
    ),
  ),
);
```

- 删除 `_ReportDesktopShell`
- `ReportTopBar` 作为 `DesktopTabShell.bottom` 传入
- `onGenerate` / `onSync` / `onRefresh` 等回调逻辑不变

### 6.5 MinePage

**当前：** `ShellDeferredContent` + `_MineDesktopShell`（自定义 ListView + `MineTopBar` 内嵌）

**改造后：**

```dart
return ShellDeferredContent(
  child: DesktopTabShell(
    title: l10n.tabMine,
    trailing: [
      MineTopBar(
        onNotificationsTap: () => context.push(AppRoutes.notifications),
        onSettingsTap: () => context.push(AppRoutes.settings),
      ),
    ],
    child: body,
  ),
);
```

- 删除 `_MineDesktopShell`
- `MineTopBar` 的通知/设置按钮作为 trailing
- 保留 `RefreshIndicator` 和滚动逻辑（如果 `DesktopTabShell.scrollable` = true，则不需要额外 ListView）

> 注意：`MineTopBar` 当前是一个 Widget（不只是 actions），需要拆分或调整。

---

## 七、验证清单

- [ ] `flutter analyze` 零问题
- [ ] `flutter test` 全部通过
- [ ] `flutter gen-l10n` 无错误
- [ ] 桌面端 Tab 切换有轻量淡入过渡，无骨架闪烁
- [ ] 侧边栏只有 5 个扁平导航项 + Settings + Help，无可展开子项
- [ ] 所有 Tab 页面桌面端有统一的 AppTopBar
- [ ] 所有 Tab 页面内容区有统一的 maxWidth 约束和 padding
- [ ] 内容区背景色与侧边栏有视觉层次区分
- [ ] 面包屑已移除
- [ ] 全屏路由（Settings 等）在桌面端正常显示，返回后侧边栏正常
- [ ] 移动端（width < 1200px）布局不受影响
- [ ] 已清理的 ARB key 确认无残留引用

---

## 八、注意事项

### 8.1 移动端不受影响

本计划所有改动仅影响桌面端（width >= `Breakpoints.desktop` = 1200px）。
移动端继续使用 `FBottomNavigationBar` + 各页面的移动端布局。
`ShellPage` 中的 `isDesktop` 分支判断保持不变。

### 8.2 ShellDeferredContent 保留

`ShellDeferredContent` 的延迟构建机制仍然需要（避免首次 Tab 切换时一次性构建所有页面导致卡顿），只改 placeholder 视觉从骨架屏改为透明。

### 8.3 ARB 清理需确认

移除 sidebar 子项相关的 ARB key 前，必须 `grep` 确认这些 key 没有在以下位置被引用：
- 测试文件
- 其他 Widget 中作为 fallback 字符串
- 文档中作为参考

### 8.4 MineTopBar 拆分

当前 `MineTopBar` 是一个完整的 Widget（包含头像 + 通知按钮 + 设置按钮），如果要用作 `DesktopTabShell.trailing`，需要拆分为只含通知/设置按钮的 Widget。检查 `MineTopBar` 的实现确认拆分方案。

### 8.5 Report 页面 bottom 参数

`ReportTopBar` 包含日期范围、查询切换、生成/同步按钮等复杂内容，作为 `DesktopTabShell.bottom` 传入时需要确认布局正确（`AppTopBar.bottom` 已支持 Widget）。

### 8.6 阶段化推进

如果希望分批合并，可以按以下顺序：

1. **先做侧边栏精简**（步骤 3-4）— 改动最小，效果最明显
2. **再做动画优化**（步骤 10-11）— 独立改动，不影响布局
3. **最后做 Shell 统一**（步骤 1-2, 5-9）— 改动最大，需要逐页验证
