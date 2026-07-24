# Luminous 桌面端 UI/UX 专项优化方案

Last updated: 2026-07-24

## 一、现状深度审查

### 1.1 当前桌面端适配现状

**断点体系**（`lib/core/design/breakpoints.dart`）：
- `mobile=600` / `tablet=960` / `desktop=1200` / `wide=1400`
- 全项目统一使用 `width >= Breakpoints.desktop` 做"是否桌面端"二元判断
- **缺失**：无 `compact`(≤360) 档、无 `ultrawide`(≥1920) 档，960–1200 区间落入"移动端"布局

**Shell 导航**（`lib/features/shell/presentation/page.dart`）：
- 桌面端用 `FSidebar` 固定宽度，无折叠/展开切换
- 侧边栏仅有 Logo + 5 个 Tab + 底部设置/帮助
- **缺失**：无用户头像、无全局搜索入口、无通知红点、无主题快切
- 移动端用 `FBottomNavigationBar`，切换逻辑正确

**DesktopTabShell**（`lib/features/shell/presentation/desktop_tab_shell.dart`）：
- 统一 `FHeader.nested` + `maxContentWidth` 约束 + muted 背景
- 各页面的桌面布局均为 7:5 或 7:3 双列 `Row`
- **缺失**：无面包屑、无命令面板、无上下文侧边面板、无状态栏

**子页面路由**：
- 全部为 `StatefulShellRoute` 外的顶层全屏路由（`go_router_builder` 生成）
- 桌面端 push 子页时侧边栏消失，窗口被整体覆盖
- **缺失**：无侧面板/抽屉式子页面、无就地编辑

### 1.2 各功能页面桌面端布局审查

| 页面 | 桌面布局 | 问题 |
|------|---------|------|
| **Today** | 7:5 双列（建议+摘要 \| 次级建议+观察） | 顶部 `TodayTopBar` 与 `DesktopTabShell` 的 header 有 `showHeader: false` 绕过逻辑；快捷操作在最底部全宽，大屏浪费空间 |
| **Record** | 三列（日历+筛选 \| 摘要网格+时间线 \| 新建入口） | 布局最丰富，但三列在 1200–1400 区间偏挤；AI/语音/拍照入口在桌面端缺失（仅移动端有） |
| **Medicine** | 7:5 双列（药盒+记录+安全 \| 快捷操作） | 右栏仅放快捷操作，大量空白；搜索栏复用移动端 `_MedicineMobileSearchBar`，未做桌面端加宽 |
| **Report** | 7:5 双列（就绪+趋势+发现+历史 \| 指标+导出+AI摘要+模式） | 左栏过长，右栏也过长，双列高度不等齐；AI摘要与导出在右栏底部需大幅滚动 |
| **Mine** | 7:5 双列（同步横幅+账号+归档+通知 \| AI隐私+安全） | 左栏内容远多于右栏，高度严重不等齐 |
| **Search** | 7:3 双列（搜索面板 \| 预览面板） | `DesktopTabs` 组件是硬编码的图标行，无实际 Tab 切换逻辑；预览面板内容空 |
| **Assistant** | 全屏 `PageScaffold` + `ResponsiveContentFrame` | 不在 Shell 内，无侧边栏；控制面板和最近对话用 `showFSheet` 弹出，桌面端应改为常驻侧面板 |
| **Settings** | 单列长滚动 | 桌面端应为主-从布局（左导航+右内容），当前为移动端长列表直接拉伸 |

### 1.3 系统级缺失项

| 类别 | 现状 | 影响 |
|------|------|------|
| **窗口管理** | 无 `window_manager` 依赖，使用默认 OS 窗口 | 无自定义标题栏、无最小窗口尺寸、无窗口位置记忆 |
| **键盘快捷键** | 全项目仅 2 处 `FocusNode` 使用（OCR 对话、聊天滚动） | 无 Ctrl+K 命令面板、无 Ctrl+N 新建、无 Ctrl+Tab 切 Tab、无 Esc 关闭、无 Enter 提交 |
| **鼠标交互** | 仅 1 个文件有 `MouseRegion` | 无自定义鼠标光标、无 hover 态增强（卡片/磁贴无悬浮反馈） |
| **右键菜单** | 0 处 `ContextMenuController` | 时间线条目、药品卡片、记录列表无右键操作 |
| **拖拽** | 0 处 `Draggable`/`DragTarget` | 无法拖拽排序、拖拽改日期 |
| **工具提示** | 仅 3 处 `FTooltip`（Today 助手按钮、Today 通知、Medicine 安全覆盖/通知） | 大量图标按钮无 tooltip |
| **对话框尺寸** | `dialogMaxWidth=360`、`wideDialogMaxWidth=420` | 桌面端对话框过窄，未按屏宽自适应 |
| **平台检测** | 0 处 `Platform.isWindows/isMacOS/isLinux`（搜索页 scanner 除外） | 无平台特化行为（如 macOS 红绿灯按钮位置） |
| **平板档** | 960–1200 区间使用移动布局 | 平板/小屏笔记本体验差 |
| **主题快切** | 需进入 Settings → Theme | 无侧边栏快速切换深色/浅色模式 |

### 1.4 做得好的部分（保留）

- **设计 Token 体系**：`Spacing`/`RadiusTokens`/`TypographyToken`/`DurationTokens`/`SemanticColor` 全量 Token 化，Forui 主题驱动
- **骨架屏**：`SkeletonScope` + shimmer 统一加载态，5 个 Tab 全部覆盖
- **状态机**：`PageStateSwitch` + `resolvePageViewState` 统一 loading/error/preview/ready 状态
- **Toast 反馈**：`AppToast` 统一轻量反馈
- **L10n**：全量 ARB + 分片合并流程，无硬编码字符串
- **响应式 helper**：`ResponsiveSizing`/`LayoutScaleResolver` 已就位
- **Today/Record 桌面布局**：双列/三列拆分思路正确，信息密度合理

---

## 二、优化方案总览

### 2.1 设计原则

1. **桌面优先 ≠ 移动端退化**：桌面端布局独立设计，不是移动端的简单拉伸
2. **信息密度**：桌面端用户期望更高的信息密度——更小的间距、更紧凑的列表、更多可见数据
3. **键鼠优先**：键盘快捷键、右键菜单、hover 态、拖拽是桌面端的核心交互
4. **空间利用**：大屏不是留白的理由，是多列布局、侧面板、上下文信息的机遇
5. **保持 Forui 体系**：不引入 `fluent_ui` 或 `macos_ui`，在 Forui 基础上扩展桌面交互层

### 2.2 新增依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| `window_manager` | ^0.4.3 | 窗口管理：最小尺寸、标题栏自定义、位置记忆 |
| `context_menus` | ^2.0.0 | 跨平台右键菜单（或使用 Flutter 原生 `ContextMenuController`） |
| `super_drag_and_drop` | ^0.9.0 | 桌面级拖拽（如需跨窗口拖拽，否则用原生 `Draggable`） |

> **注**：`window_manager` 是必选依赖；`context_menus` 和 `super_drag_and_drop` 视实现范围可选。

### 2.3 工作分解（按优先级）

---

## P0 — 桌面端基础设施

### Task 1: 窗口管理基础设施

**目标**：引入 `window_manager`，设置最小窗口尺寸、初始化窗口配置。

**文件变更**：
- `pubspec.yaml` — 添加 `window_manager: ^0.4.3`
- `lib/app/bootstrap.dart` — 在 `LuminousApp` 初始化前调用 `windowManager.ensureInitialized()` + 设置最小尺寸
- `lib/main.dart` — 桌面平台条件初始化

**关键实现**：
```dart
// bootstrap.dart
if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(const Size(480, 720));
  await windowManager.setTitle('Luminous');
}
```

**验收标准**：
- 桌面端窗口不可缩小到 480×720 以下
- 窗口标题显示 "Luminous"
- Web/移动端不受影响

---

### Task 2: 可折叠侧边栏

**目标**：将 `_DesktopSidebar` 升级为可折叠侧边栏——展开态显示图标+文字（当前行为），折叠态仅显示图标（rail 模式）。

**文件变更**：
- `lib/features/shell/presentation/page.dart` — `ShellPage` 增加侧边栏折叠状态管理
- `lib/features/shell/presentation/desktop_tab_shell.dart` — 内容区根据侧边栏折叠态调整 `maxContentWidth`
- 新增 `lib/core/providers/sidebar_preference.dart` — 持久化侧边栏折叠偏好（SharedPreferences）

**关键实现**：
- 在 `ShellPage` build 中根据折叠状态切换 `FSidebar` 宽度
- 折叠态宽度 ~56px（仅图标），展开态保持当前 `ResponsiveSizing.sidebarWidth`
- 在侧边栏底部增加折叠/展开切换按钮（`FLucideIcons.panelLeft` / `panelLeftClose`）
- 折叠态时 `FSidebarItem` 的 label 通过 tooltip 显示

**验收标准**：
- 侧边栏可折叠/展开，状态持久化
- 折叠态仅显示图标，hover 时 tooltip 显示文字
- 内容区宽度自动适应侧边栏状态

---

### Task 3: 侧边栏信息增强

**目标**：在侧边栏顶部增加用户头像 + 名称，底部增加主题快切 + 通知红点。

**文件变更**：
- `lib/features/shell/presentation/page.dart` — `_DesktopSidebar` header 改为用户卡片，footer 增加主题切换和通知入口

**关键实现**：
- **Header**：用户头像（`FAvatar.raw`）+ 昵称，点击跳转 Mine 页
- **Footer** 增加：
  - 主题快切按钮（`FLucideIcons.sun`/`moon`/`monitor`）— 三态循环切换 system/light/dark
  - 通知入口带红点（复用 `notificationUnreadCountProvider`）
  - 全局搜索入口（`FLucideIcons.search`）— 触发命令面板（P1 实现）

**验收标准**：
- 未登录时 header 显示"点击登录"提示
- 已登录时 header 显示用户头像和昵称
- 主题快切即时生效，状态持久化
- 通知红点与移动端行为一致

---

### Task 4: 桌面端对话框/Sheet 尺寸自适应

**目标**：对话框和 Sheet 在桌面端按屏宽自适应，不再固定 360/420px。

**文件变更**：
- `lib/core/design/layout_scale.dart` — `LayoutScaleResolver` 增加桌面端对话框宽度计算
- `lib/core/widgets/common/dialog_shell.dart` — 使用自适应宽度

**关键实现**：
```dart
// layout_scale.dart
static double dialogMaxWidthFor(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.desktop) return 560;
  if (width >= Breakpoints.tablet) return 480;
  return dialogMaxWidth; // 360
}
static double wideDialogMaxWidthFor(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= Breakpoints.desktop) return 640;
  if (width >= Breakpoints.tablet) return 520;
  return wideDialogMaxWidth; // 420
}
```

**验收标准**：
- 桌面端对话框宽度 ≥480px，不再像移动端一样窄
- Sheet（`showFSheet`）在桌面端宽度自适应（如助手控制面板从 400px → 480px+）

---

### Task 5: 桌面端 Tooltip 全覆盖

**目标**：所有仅图标按钮（icon-only `FButton.icon`、`FHeader.suffixes`/`prefixes` 中的图标按钮）增加 `FTooltip`。

**文件变更**：
- `lib/features/today/presentation/widgets/shared/top_bar.dart` — 已有，保持
- `lib/features/medicine/presentation/pages/page.dart` — `_MedicineSafeGuardPill` 已有，`_MedicineNotificationButton` 已有；补充搜索栏 tooltip
- `lib/features/mine/presentation/pages/page.dart` — 通知/设置按钮用 `IconActionButton` 已有 tooltip
- `lib/features/report/presentation/pages/page.dart` — 补充 suffixes tooltip
- `lib/features/record/presentation/pages/page.dart` — 补充 header action chips tooltip
- `lib/features/assistant/presentation/pages/page.dart` — 补充 header actions tooltip
- `lib/features/shell/presentation/page.dart` — 折叠态侧边栏 item 的 tooltip

**验收标准**：
- 所有仅图标按钮 hover 时显示 tooltip
- Tooltip 文案通过 ARB 本地化

---

## P1 — 桌面端核心交互

### Task 6: 键盘快捷键体系

**目标**：在 app 根部注入全局 `Shortcuts` + `Actions`，覆盖高频操作。

**文件变更**：
- 新增 `lib/core/widgets/shortcuts/app_shortcuts.dart` — 全局快捷键定义
- `lib/app/router.dart` 或 `lib/main.dart` — 在 `MaterialApp.router` 外层包裹 `Shortcuts` + `Actions`

**快捷键映射**：

| 快捷键 | 动作 | 说明 |
|--------|------|------|
| `Ctrl/Cmd+K` | 打开命令面板 | 全局搜索/快速导航 |
| `Ctrl/Cmd+N` | 新建记录 | 跳转 `/record/create` |
| `Ctrl/Cmd+1..5` | 切换 Tab | Today/Record/Medicine/Report/Mine |
| `Ctrl/Cmd+,` | 打开设置 | 跳转 `/settings` |
| `Ctrl/Cmd+Shift+A` | 打开助手 | 跳转 `/assistant` |
| `Ctrl/Cmd+B` | 折叠/展开侧边栏 | 切换 sidebar 折叠态 |
| `Escape` | 关闭对话框/Sheet/面板 | 逐层退出 |
| `Enter` | 提交表单 | 焦点在表单内时 |

**关键实现**：
```dart
// app_shortcuts.dart
class AppShortcuts extends StatelessWidget {
  const AppShortcuts({super.key, required this.child});
  final Widget child;

  static final _shortcuts = <ShortcutSerializer, Intent>{
    const SingleActivator(LogicalKeyboardKey.keyK, control: true): const OpenCommandPaletteIntent(),
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): const CreateRecordIntent(),
    // ... Ctrl+1..5 使用 digit1..digit5
    const SingleActivator(LogicalKeyboardKey.comma, control: true): const OpenSettingsIntent(),
    // ...
  };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(shortcuts: _shortcuts, child: Actions(actions: {...}, child: child));
  }
}
```

**验收标准**：
- 快捷键不与浏览器/OS 保留快捷键冲突
- 在文本输入框内时快捷键降级（不触发全局动作，除了 Escape）
- 快捷键行为可通过 `Actions` 在子页面覆盖

---

### Task 7: 命令面板（Ctrl+K）

**目标**：全局命令面板，支持快速导航、搜索药品、新建记录。

**文件变更**：
- 新增 `lib/core/widgets/command_palette/command_palette.dart` — 命令面板 UI
- 新增 `lib/core/widgets/command_palette/command_provider.dart` — 命令注册与执行
- `lib/app/router.dart` — 全局 `Actions` 中注册 `OpenCommandPaletteAction`

**功能范围**：
- **导航命令**：跳转到 5 个 Tab + Settings + Assistant
- **操作命令**：新建记录、新建提醒、搜索药品、生成 AI 摘要
- **设置命令**：切换主题、切换语言

**关键实现**：
- 使用 `FDialog` 或 `showFDialog` 弹出模态搜索框
- `TextField` 自动聚焦 + `ListView` 实时过滤
- 支持模糊搜索命令名（中文+英文）
- `ArrowUp`/`ArrowDown` 键盘导航结果列表
- `Enter` 执行选中命令，`Escape` 关闭

**验收标准**：
- `Ctrl+K` 打开命令面板
- 输入"记录"/"record" 可快速跳转 Record 页
- 输入"新建"/"new" 可触发新建记录流程
- 键盘导航完整可用

---

### Task 8: 桌面端 Hover 态增强

**目标**：为 `FCard`、`FTile`、`FTappable` 在桌面端增加 hover 反馈。

**文件变更**：
- 新增 `lib/core/widgets/common/desktop_hover.dart` — `DesktopHoverCard` wrapper
- 关键页面卡片组件包装

**关键实现**：
```dart
class DesktopHoverCard extends StatefulWidget {
  // 仅在桌面端生效，移动端透传
  // hover 时：背景色微亮 + 边框色变化 + 阴影 + 鼠标光标 pointer
}
```

- 仅在 `width >= Breakpoints.desktop` 时启用 hover 效果
- 移动端直接返回 child，无额外 Widget 开销
- hover 效果通过 `MouseRegion` + `AnimatedContainer` 实现
- 颜色变化使用 `SemanticColor` 体系，不引入新色值

**验收标准**：
- 桌面端卡片 hover 有明显的视觉反馈（背景微亮 + 边框变化）
- 移动端无 hover 态，无性能开销
- hover 动画时长使用 `DurationTokens.widgetQuick`

---

### Task 9: 右键上下文菜单

**目标**：在记录时间线条目、药品列表项、记录列表项上增加右键菜单。

**文件变更**：
- 新增 `lib/core/widgets/common/context_menu.dart` — 统一右键菜单 wrapper
- `lib/features/record/presentation/widgets/sections/timeline.dart` — `_TimelineCard` 增加右键
- `lib/features/medicine/presentation/widgets/sections/mobile_records.dart` — 药品记录项增加右键
- `lib/features/mine/presentation/widgets/sections/archive.dart` — 归档项增加右键

**右键菜单项**：
- **记录时间线**：编辑 / 删除 / 复制日期 / 查看详情
- **药品记录**：编辑提醒 / 查看详情 / 删除 / 加入药盒
- **归档项**：编辑 / 删除

**关键实现**：
```dart
// context_menu.dart
Widget desktopContextMenu({
  required BuildContext context,
  required Widget child,
  required List<ContextMenuEntry> items,
}) {
  if (!isDesktop) return child;
  return GestureDetector(
    onSecondaryTapDown: (details) => _showMenu(context, details, items),
    child: child,
  );
}
```

**验收标准**：
- 桌面端右键弹出上下文菜单
- 移动端长按可触发相同菜单（或不启用）
- 菜单项与页面内已有操作按钮一致，不引入新功能

---

## P2 — 桌面端布局优化

### Task 10: 断点体系完善

**目标**：增加 `compact` 和 `ultrawide` 断点，960–1200 区间使用"小平板"布局。

**文件变更**：
- `lib/core/design/breakpoints.dart` — 增加 `compact=360`、`ultrawide=1920`
- `lib/core/design/layout_scale.dart` — 增加 960–1200 区间的 `LayoutScale`
- `lib/core/design/responsive_sizing.dart` — `gridCrossAxisCount` 增加 ultrawide 档

**关键实现**：
```dart
abstract final class Breakpoints {
  static const double compact = 360;
  static const double mobile = 600;
  static const double tablet = 960;
  static const double smallDesktop = 1080;  // 新增：小平板/小笔记本
  static const double desktop = 1200;
  static const double wide = 1400;
  static const double ultrawide = 1920;
}
```

- 960–1200 区间：单列 + 卡片网格（2列），不使用双列布局
- 1200–1400：当前桌面双列布局
- 1400–1920：当前布局 + 更宽的 `maxContentWidth`
- ≥1920：三列布局或更宽内容区

**验收标准**：
- 960–1200 区间不再使用移动端单列布局，改为 2 列卡片网格
- 1920+ 屏幕不再有大量留白
- 现有断点行为不受影响

---

### Task 11: Medicine 页桌面布局重设计

**目标**：解决右栏空白问题，重构为三列或双列+底部网格。

**文件变更**：
- `lib/features/medicine/presentation/widgets/views/mobile_dashboard_view.dart` — `_buildDesktopLayout` 重构

**新布局方案**：
- **左列（flex 5）**：药盒（`_DrugBoxSection`）
- **中列（flex 7）**：用药记录（`_MedicineRecordsSection`）+ 安全引擎（`_SafetyEngineSection`）
- **右列（flex 4）**：快捷操作 + 今日计划概要
- 在 <1400 时退化为双列（药盒+记录 | 安全+操作）

**验收标准**：
- 桌面端无大面积空白
- 三列在 1400px 屏宽下不拥挤
- 双列降级在 1200–1400 区间合理

---

### Task 12: Report 页桌面布局重设计

**目标**：解决双列高度不等齐问题，重组信息层次。

**文件变更**：
- `lib/features/report/presentation/widgets/views/dashboard_view.dart` — `_buildDesktopLayout` 重构

**新布局方案**：
- **顶部全宽**：就绪状态 + 评分概要 + 操作栏（生成AI / 同步 / 导出）
- **左列（flex 7）**：趋势图 + 发现 + 建议历史
- **右列（flex 5）**：指标网格 + AI 摘要 + 模式 + 免责声明
- 去除重复的日期范围标签和操作栏（当前 DesktopTabShell + 页面内容有重复）

**验收标准**：
- 双列高度差异 ≤100px
- AI 摘要和导出操作不再需要大幅滚动
- 操作栏不重复出现

---

### Task 13: Mine 页桌面布局重设计

**目标**：解决左右栏高度严重不等齐。

**文件变更**：
- `lib/features/mine/presentation/widgets/views/dashboard_view.dart` — `_buildDesktopLayout` 重构

**新布局方案**：
- **左列（flex 6）**：同步横幅 + 账号 Hero + 归档
- **右列（flex 4）**：AI 隐私 + 通知提醒 + 账号安全
- 或改为三列：账号Hero（全宽顶） → 左：归档+通知 | 中：AI隐私+安全 | 右：快捷操作

**验收标准**：
- 双列高度差异 ≤100px
- 信息分组清晰

---

### Task 14: Settings 页桌面主-从布局

**目标**：桌面端 Settings 从单列长滚动改为左导航+右内容的主-从布局。

**文件变更**：
- `lib/features/settings/presentation/pages/page.dart` — 桌面端使用双列布局
- 新增 `lib/features/settings/presentation/widgets/settings_master_detail.dart`

**关键实现**：
- 左侧（~280px）：分组导航（账号安全 / 通用 / 快速记录 / AI隐私 / 关于）
- 右侧：选中分组的设置项
- 移动端保持当前单列长滚动
- 路由不变，仅桌面端布局变化

**验收标准**：
- 桌面端设置页无需长滚动
- 左侧导航高亮当前分组
- 子页面（主题、语言等）仍为全屏路由

---

### Task 15: Assistant 桌面常驻面板

**目标**：桌面端 Assistant 不再使用 Sheet 弹出控制面板和最近对话，改为常驻侧面板。

**文件变更**：
- `lib/features/assistant/presentation/pages/page.dart` — 桌面端布局重构
- `lib/features/assistant/presentation/widgets/sections/controls_panel.dart` — 适配常驻面板
- `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart` — 适配常驻面板

**新布局方案**：
- **桌面端三列**：
  - 左列（~280px）：最近对话列表（常驻）
  - 中列（flex 1）：对话区 + 输入框
  - 右列（~320px）：控制面板（能力开关、上下文设置）
- **移动端**保持当前 Sheet 弹出行为

**验收标准**：
- 桌面端不再使用 `showFSheet` 弹出面板
- 三列布局在 1200px 屏宽下可用
- 对话区宽度有合理上限（~720px），避免文本行过宽

---

## P3 — 桌面端体验增强

### Task 16: 子页面侧面板化（CRUD 页面）

**目标**：桌面端的 Record 创建/编辑、Medicine 提醒编辑等 CRUD 页面从全屏路由改为侧面板。

**文件变更**：
- `lib/app/router.dart` — 桌面端 CRUD 路由使用 `DialogPage` 或 `BottomSheetPage` 替代全屏 push
- 各 CRUD 页面适配面板宽度

**关键实现**：
- 使用 GoRouter 的 `pageBuilder` 返回 `DialogPage`（桌面端）或全屏 `MaterialPage`（移动端）
- 桌面端 CRUD 页面以右侧滑入面板形式呈现（宽度 ~560px），侧边栏保持可见
- 面板内使用 `PageScaffold` 但去掉返回按钮（用关闭按钮代替）

**验收标准**：
- 桌面端新建记录时侧边栏不消失
- 面板宽度合理，内容不拥挤
- 移动端保持全屏路由行为

---

### Task 17: 拖拽支持（可选）

**目标**：在 Record 时间线支持拖拽改变记录日期。

**文件变更**：
- `lib/features/record/presentation/widgets/sections/timeline.dart` — 时间线卡片增加 `Draggable`
- `lib/features/record/presentation/widgets/sections/sidebar.dart` — 日历日期增加 `DragTarget`

**验收标准**：
- 拖拽时间线卡片到日历某天可改变记录日期
- 拖拽有视觉反馈（源卡片半透明、目标日期高亮）
- 移动端不启用拖拽（长按触发日期选择器替代）

---

### Task 18: 窗口标题栏自定义（可选）

**目标**：使用 `window_manager` 自定义标题栏，集成到侧边栏顶部。

**文件变更**：
- `lib/app/bootstrap.dart` — `windowManager.setTitleBarStyle('hidden')`
- `lib/features/shell/presentation/page.dart` — 侧边栏顶部增加拖拽区域 + 窗口控制按钮

**验收标准**：
- macOS 红绿灯按钮位置正确
- Windows/Linux 显示自定义最小化/最大化/关闭按钮
- 标题栏可拖拽移动窗口

---

## 三、实施顺序与里程碑

### Sprint 1（P0 基础设施，~5 个工作日）

1. Task 1: 窗口管理基础设施
2. Task 2: 可折叠侧边栏
3. Task 3: 侧边栏信息增强
4. Task 4: 桌面端对话框尺寸自适应
5. Task 5: Tooltip 全覆盖

### Sprint 2（P1 核心交互，~7 个工作日）

6. Task 6: 键盘快捷键体系
7. Task 7: 命令面板
8. Task 8: Hover 态增强
9. Task 9: 右键上下文菜单

### Sprint 3（P2 布局优化，~8 个工作日）

10. Task 10: 断点体系完善
11. Task 11: Medicine 桌面布局重设计
12. Task 12: Report 桌面布局重设计
13. Task 13: Mine 桌面布局重设计
14. Task 14: Settings 主-从布局
15. Task 15: Assistant 常驻面板

### Sprint 4（P3 体验增强，~5 个工作日）

16. Task 16: 子页面侧面板化
17. Task 17: 拖拽支持（可选）
18. Task 18: 窗口标题栏自定义（可选）

---

## 四、技术约束

### 4.1 不可破坏的约束

- **Forui 优先**：不引入 `fluent_ui`/`macos_ui`/`adaptive_navigation`，在 Forui 基础上扩展
- **Riverpod 状态管理**：所有新增状态使用 `@riverpod` 注解或手写 `NotifierProvider`
- **GoRouter 路由**：不使用 `Navigator.push(MaterialPageRoute(...))`
- **ARB 本地化**：所有新增文案通过 `lib/l10n/src/` 分片 → merge → gen-l10n
- **Token 体系**：间距用 `Spacing`、圆角用 `RadiusTokens`、字体用 `TypographyToken`、动画时长用 `DurationTokens`、颜色用 `SemanticColor`
- **移动端不受影响**：所有桌面端适配必须以 `isDesktop` / `width >= Breakpoints.desktop` 守卫，移动端代码路径不变

### 4.2 文档更新

- 每个 Sprint 完成后在 `docs/03-logs/migration-log/YYYY-MM-DD.md` 追加迁移日志
- 更新 `docs/00-current/Runtime_Snapshot.md` 的响应式布局部分
- 更新 `docs/02-reference/Design_System.md` 的 Shell 与页面 chrome 部分
- 新增 `docs/00-current/Desktop_UI.md` 记录桌面端适配现状

### 4.3 测试策略

- 每个新增 Widget 需要对应的 widget test
- 桌面端布局在 1200px / 1440px / 1920px 三个宽度下验证
- 移动端布局在 390px / 768px 两个宽度下验证不退化
- 键盘快捷键需要 integration test 验证
