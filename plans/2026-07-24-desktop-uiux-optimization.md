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
| `super_drag_and_drop` | ^0.9.0 | 桌面级拖拽（如需跨窗口拖拽，否则用原生 `Draggable`） |

> **注**：`super_drag_and_drop` 视实现范围可选。

### 2.3 工作分解（按优先级）

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
