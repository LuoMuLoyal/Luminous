# 桌面端 UI 适配现状

本文档记录 Luminous 桌面端 UI/UX 专项优化的完整实现状态。源方案见 `plans/2026-07-24-desktop-uiux-optimization.md`。

## 断点体系

| 断点 | 值 | 用途 |
|------|-----|------|
| compact | 360 | 极小屏（折叠态侧边栏图标尺寸等） |
| mobile | 600 | 移动端 / 桌面端二元判断分界 |
| tablet | 960 | 平板档 |
| smallDesktop | 1080 | 小笔记本 |
| desktop | 1200 | 桌面端布局启用阈值 |
| wide | 1400 | 宽屏桌面 |
| ultrawide | 1920 | 超宽屏（6 列网格） |

`LayoutScale` 在 1200–1400 和 ≥1400 使用不同 `maxContentWidth`（1400 vs 1600）。

## Shell 导航

### 侧边栏

- `FSidebar` 固定宽度，始终展开（图标 + 文字）
- **Header**：`_WindowTitleBar` 包裹 `DragToMoveArea`（拖拽移动窗口）
  - Windows/Linux：自定义 `_WindowControlButtons`（最小化/最大化/关闭，hover 态反馈，关闭按钮 hover 变红）
  - macOS：系统红绿灯按钮自动叠加，header 左侧加 70px padding
  - 未登录时显示 Logo + 标题；已登录显示用户头像 + 昵称
- **Footer**：通知入口（带红点）、主题快切（system/light/dark 三态循环）、设置、帮助

### DesktopTabShell

- 统一 `FHeader.nested` + `maxContentWidth` 约束 + muted 背景 + 可选 RefreshIndicator
- 5 个 Tab 页面全部迁移到 `DesktopTabShell`

### 键盘快捷键

通过 `AppShortcuts`（StatelessWidget）注入到 `FToaster` 内层：

| 快捷键 | 动作 |
|--------|------|
| Ctrl/Cmd+K | 打开命令面板 |
| Ctrl/Cmd+N | 新建记录 |
| Ctrl/Cmd+1..5 | 切换 Tab |
| Ctrl/Cmd+, | 打开设置 |
| Ctrl/Cmd+Shift+A | 打开助手 |

### 命令面板（Ctrl+K）

- 模态搜索框 + `ListView` 实时过滤
- 导航命令（5 个 Tab + Settings + Assistant）+ 操作命令
- 中英文模糊搜索，`ArrowUp`/`ArrowDown` 键盘导航，`Enter` 执行，`Escape` 关闭

## 桌面端交互

### Hover 态

- `DesktopHoverCard` 通过 `MouseRegion` + `AnimatedContainer` 追踪 hover
- 悬浮时背景色 `primary.withValues(alpha: 0.04)` + 边框 `primary.withValues(alpha: 0.15)`
- 移动端 pass-through（无额外 Widget 开销）
- 已接入：Record 时间线卡片

### 右键上下文菜单

- 使用 Forui `FContextMenu.tiles`，桌面端右键触发，移动端长按触发
- 已接入：
  - Record 时间线卡片：查看详情 / 编辑
  - Medicine 用药记录项：用药提醒详情 / 编辑提醒
  - Mine 归档项：查看详情 / 编辑

### 拖拽支持

- `TimelineDragData` 拖拽数据模型（`recordId` + `RecordTimelineEntry`）
- 时间线卡片（桌面端 + `recordId != null`）包裹 `Draggable<TimelineDragData>`
  - 源卡片半透明（opacity 0.4）
  - 拖拽预览：紧凑浮动卡片（图标 + 标题 + 日历图标），带阴影和边框
- 日历日期单元格（`_MonthDayCell`，StatefulWidget）包裹 `DragTarget<TimelineDragData>`
  - 悬浮高亮：背景 `primary.withValues(alpha: 0.15)` + 边框 `primary.withValues(alpha: 0.4)`
  - 仅 `day.inMonth` 的日期接受拖拽
- 成功后调用 `dailyRecordRepositoryProvider.update()` 更新 `occurredAt`，发射 `DataChangeTopic.dailyRecords` 触发看板刷新，自动导航到新日期，Toast 反馈
- 移动端不启用拖拽

### CRUD 路由侧面板化

- `sidePanelPage` helper：桌面端右侧滑入面板（maxWidth 560，半透明遮罩 `Colors.black.withValues(alpha: 0.4)`，`barrierDismissible`，`opaque: false`），移动端降级为 `slidePage`
- 已迁移路由：
  - Record：create / detail / edit
  - Medicine：reminders/new / reminders/:id / reminders/:id/edit
- 搜索和风险检查路由保持全屏（非 CRUD 表单）

### 对话框尺寸自适应

- `LayoutScaleResolver.dialogMaxWidthFor()`：桌面 560 / 平板 480 / 移动 360
- `LayoutScaleResolver.wideDialogMaxWidthFor()`：桌面 640 / 平板 520 / 移动 420
- 9 处对话框调用已迁移到自适应宽度

### Tooltip 全覆盖

- 所有仅图标按钮 hover 时显示 tooltip
- 侧边栏折叠态 items、助手 header actions、记录编辑按钮、日历图标按钮、返回按钮等

## 页面桌面布局

### Today

- 双栏 `Row[左7: Primary+Summary | 右5: Secondary+Observation]` + QuickActions
- `showHeader: false` 绕过 DesktopTabShell header，由内容区 `TodayTopBar` 提供唯一标题

### Record

- 三栏：左（日历+筛选 sidebar）+ 中（摘要+时间线）+ 右（新建入口）
- 桌面端拖拽改日期
- 时间线卡片右键菜单

### Medicine

- ≥1400：三列（药盒 | 记录+安全 | 操作）
- 1200–1400：双列（药盒+记录 | 安全+操作）
- 用药记录项右键菜单

### Report

- 顶部全宽（就绪+指标+导出）+ 下方双列（趋势+发现+历史 | AI摘要+模式+免责）

### Mine

- 6:4 均衡双列（同步横幅+账号+归档+通知 | AI隐私+安全）
- 归档项右键菜单

### Settings

- ≥1200：`_SettingsMasterDetail` 主-从布局（左导航 260px 高亮当前分组 + 右内容滚动）
- 移动端：单列长滚动

## 窗口管理

- `window_manager` 设置：
  - 最小窗口尺寸 480×720
  - 窗口标题 "Luminous"
  - `TitleBarStyle.hidden` 隐藏原生标题栏
- Web/移动端为 no-op
