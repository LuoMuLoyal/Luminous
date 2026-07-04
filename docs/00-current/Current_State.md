# Luminous Current State

Last updated: 2026-07-04

本文件只保留简介和按区域链接。具体实现细节见 `00-current/` 下各子文件。

## 当前区域

- [[00-current/Project_Governance]] — 项目治理
- [[00-current/Repository_Split]] — 仓库划分
- [[00-current/Product_Surface]] — 产品表面
- [[00-current/Work_Phase_Guide]] — 阶段总纲
- [[00-current/Lucent_Contract_Snapshot]] — Lucent 合同快照
- [[00-current/Runtime_Snapshot]] — Luminous 运行时快照
- [[00-current/Active_Mobile_UI]] — 活跃移动 UI 总览
- [[00-current/Mock_Or_Deferred]] — Mock 与延后能力
- [[00-current/Removed_From_Active_Scope]] — 已移出活跃范围的功能

## 已完成基线

- 历史 completed baselines 与 audit remediation 已归档：[[04-archive/current-state-archive]]
- 文档治理现在带有 warning-only 的路径映射检查：`docs/doc-map.yaml` + `tool/check_doc_coverage.dart`
  会在 `pre-commit` 与 `tool/run_daily_checks.dart` 中提醒本次代码改动需要复核哪些文档。
- AI 开发工作流增强已接入仓库级入口：
  - 编辑器助手入口：`.github/copilot-instructions.md`
  - agent 入口：`AGENTS.md`、`CLAUDE.md`、`GEMINI.md`
  - MCP 入口：`.cursor/mcp.json`
  - VS Code 项目设置已启用 `dart.mcpServer`
  - app-side AI 试验 seam 建立在 `lib/core/ai/`，默认关闭，不替代 Lucent-backed
    assistant/report 生产链路
  - 编译期环境变量统一通过 `lib/core/config/env_keys.dart` + `env_reader.dart`
    读取，Web/JS 构建不再依赖动态 `String.fromEnvironment(key)`；`.env.example`
    现在同时承载 app 运行时与 full-stack E2E 所需键。
- Forui-first 编码统一性优化完成：
  - 页面骨架统一：`PageScaffold`（26 子页）+ `AppTopBar`（5 Tab 根页）+ `AuthShell`（5 Auth 页）。
  - Material 组件全面迁移：按钮、进度、InkWell、图标、对话框、输入、选择、列表、卡片、Chip、导航、Tab、Drawer 等。
  - 颜色系统：所有 `Color(0xFF...)` 和 `Theme.of(context).colorScheme.*` 已替换为
    `context.theme.colors.*` / `AppColors` 语义 token。
  - 排版系统：所有 `textTheme.*` 已替换为 `AppTypographyToken`。
  - `Theme.of(context).brightness` 已替换为 `MediaQuery.platformBrightnessOf(context)`。
  - 合理遗留：`RefreshIndicator`（Forui 未提供等效组件）。
  - 已迁移的剩余 Material 组件：
    - `Tooltip` → `FTooltip`（12 处）
    - `SegmentedButton` → `FSelectGroup`/`FSelectGroupItemMixin.radio`
    - `FloatingActionButton.extended` → `FButton`（Record NLP FAB）
    - `showDatePicker`/`showDateRangePicker` → `FDateField.calendar`/`FCalendar.grid`
    - `showTimePicker` → `FTimeField.picker`/`FTimePicker`
  - 已替换的手写组件：
    - Record 时间轴 → `timeline_tile`（桌面 `RecordTimelinePanel` + 移动 `RecordMobileTimeline`）
    - 通知列表滑动删除 → `flutter_slidable`（替代 `Dismissible`）
- 基础组件优化完成：
  - `AppDivider` 支持 `width` 参数，清理冗余默认色调用。
  - `AppStateViews` 拆分为 `app_state_message.dart` + `app_skeleton.dart`，修复 tone 语义，
    `AppInlineSkeletonCircle` 自动 shimmer。
  - `AssistantStateCard` 删除，合并到 `AppStateMessageView(maxWidth: 560)`。
  - `ResponsiveContentFrame` 支持 `padding` 覆盖。
  - `PageScaffold` 支持 `titleWidget` 与 `headerStyle`。
- Phase 1 可见问题修复进行中：
  - Report 页指标卡移动端 `BOTTOM OVERFLOWED BY 2.0 PIXELS` 已修复。
  - Today 页优先事项卡片右侧 action pill 文字颜色已修复，不再与背景融为一体；宽度改为 `IntrinsicWidth` 自然撑开，避免 “去服用” / “去喝水” 截断。
  - Today 页 AI 日总结 signed-out / disabled 空态 footer 已移除，只保留单条 bullet 提示，避免重复文案。
  - 登录提示弹窗（尚未登录 / 是否去登录）的取消/去登录按钮已改为横向布局，去登录位于右侧。
  - 通知页返回后若接口返回 401，`LucentDioClient` 现在会清理本地 session 并通过回调同步到 `authSessionProvider`，避免 UI 卡在“已登录但请求持续失败”的状态。
  - Today 页顶部标题从 36px 降到 30px，与其他 Tab 根页统一。
  - 胶囊按钮统一收敛到 Forui 主题样式：使用 `dart run forui style create buttons` 生成
    `lib/theme/styles/button_styles.dart`，将默认按钮圆角改为 `pill` 并接入 `FThemeData`。
    - 删除 `AppPillButton` 中间层；Today/Record/Medicine/Report 顶部与操作行中的胶囊按钮
      全部改用标准 `FButton`，依靠主题默认获得一致的 pill 外观，仅在需要处保留内边距/最小宽度覆盖。
    - Today 页“AI 对话”、优先事项“去服用/去喝水”、Report 周期选择 pill、Record 日期选择 pill、
      Record 顶部 action chips、Medicine workspace header action chip 已统一。
    - 根据移动端截图反馈，将 touch 模式下 `md`/`sm`/`lg` 按钮的 `minHeight` 与垂直内边距各下调 4px，
      使胶囊按钮看起来更紧凑。
    - 扫描并继续统一了剩余自定义圆角的胶囊操作按钮：Medicine workspace quick actions、Search 源切换、
      Record OCR 选项卡、Record 新建记录 chip。当前仅保留搜索条 `lg`、圆形图标按钮、卡片/静态 badge、
      以及 filter chips 的原有圆角。
    - Record 页“快速记录”网格已重构为 2×3 布局，底部新增占满宽度的“备注”按钮；格子改用 `FTappable` +
      `FAvatar` + `AppDivider`，去掉重复 outline 边框与手写分隔线；未启用项显示锁图标并降低透明度。
    - 修复 Record 快速记录“用药”点击断言失败：`_handleQuickAction` 现在对无法映射到 `DailyRecordKind` 的类型
      （如 medication）统一打开通用创建页，并将登录检查前置，使七个快速记录项的登录提示行为一致。
    - Record 页日期选择器重构：移除顶部左右步进按钮，改为内联 `FLineCalendar` 横向滑动选日期；
      右侧保留日历按钮，点击弹出 `FCalendar.splitGrid` 月/年网格选择器。为彻底压缩高度并避免
      `FLineCalendar` 默认 `ItemContent` 在不同屏幕下 overflow，使用自定义 `builder` 绘制紧凑日期项：
      字号调整为 weekday 11 / date 14，垂直间距 4 / 2，保留 today 指示点与选中/禁用装饰；
      自定义项用 `SizedBox.expand` 占满 `FLineCalendar` 的 item 宽度，使选中态背景接近正方形。
      `RecordDateBar` 高度改为按屏幕高度连续计算（`height * 0.055`，clamp 40~52），不再使用固定档位。
    - Record 页 UI 紧凑化与顶部按钮对齐：
      - `AppTopBar` 的 trailing 操作区改为与标题垂直居中对齐，解决右上角加号按钮偏高问题。
      - 移动端 Record 加号按钮（iconOnly + emphasized）圆角从 pill 改为 10px 圆角矩形，视觉更克制。
      - `RecordPage` body 顶部内边距改为按屏幕高度连续计算（`height * 0.012`，clamp 10~16），
        减小标题与日期条之间的空白。
      - `RecordQuickEntryPanel` 尺寸改为按屏幕短边连续计算（`(shortEdge - 600) / 280`，clamp 0~1），
        标题与卡片间距、格子垂直内边距、头像尺寸、备注按钮内边距和分隔线高度均随屏幕尺寸平滑缩放，
        避免在小屏设备上快速记录区占用过多空间。

## 相关文档

- 产品方向：[[01-product/Product_Vision]]
- 阶段总纲：[[00-current/Work_Phase_Guide]]
- 下一步工作：[[00-current/Next_Plan]]
- 避错清单：[[02-reference/Project_Guardrails]]
