---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-02
---

# AI Chat UI Redesign

## Goal

把 Luminous 的 AI 对话页调整为参考图所示的主流 AI 应用结构：轻量顶部栏、空会话欢迎区、底部浮动输入框，以及从左侧滑出的会话抽屉。保持现有 AI 会话数据流和受控健康上下文行为不变。

## Scope

### In scope

- 重做 `AssistantPageBody` 的页面 chrome，使顶部操作区更接近参考图。
- 空会话时展示居中的欢迎内容和 starter prompts；有消息后保持消息列表优先。
- 重做 `AssistantInputBar` 的 Forui 视觉层级和操作布局，不改变发送、流式生成、快捷键和禁用状态。
- 将当前 Material `Drawer` 替换为 Forui 的侧滑 sheet，从左侧打开。
- 在会话抽屉中增加 Forui 搜索框，并对已加载的最近会话做本地过滤。
- 保留今天 / 最近 7 天 / 更早三个时间分组，以及当前会话高亮和现有会话切换逻辑。
- 在 Luminous TODO 中记录会话重命名和删除能力，暂不新增后端调用。

### Out of scope

- 不新增模型切换接口或后端模型配置。
- 不实现会话重命名、删除、批量管理。
- 不修改 assistant controller、repository、API contract 或消息实体。
- 不改变设置 sheet 中的 AI 开关、记忆和健康上下文开关。

## UX design

### Main chat page

- 页面使用现有 Forui 主题、spacing、radius、typography 和 Lucide icon tokens。
- 顶部栏保留新建会话和设置入口，新增/调整会话抽屉入口，使入口语义接近参考图的菜单按钮。
- 标题区域保持 Luminous 的本地化文案；不虚构后端模型名称。
- 空会话欢迎区使用 AI 标识、欢迎标题、简短说明和 starter prompt 操作，操作仍调用现有 `onStarterPrompt`/`sendMessage` 路径。
- 输入区使用 Forui text field/button primitives，保留多行输入、发送中状态、不可发送状态、桌面快捷键提示和滚动到底部行为。

### Conversation drawer

- 使用 `showFSheet` + `FLayout.ltr`，从左侧滑出并覆盖当前聊天页。
- 抽屉顶部提供搜索框、新建会话按钮和关闭按钮。
- 搜索按照会话标题过滤当前已加载的 `recentConversations`；空搜索显示完整列表。
- 搜索结果仍按 today / this week / older 分组，空结果显示 Forui 状态视图。
- 点击会话先关闭 sheet，再复用现有 `openConversation`；新建会话先关闭 sheet，再复用现有 `clearConversation`。
- 搜索文本是抽屉本地 UI 状态，不写入 controller，不触发网络请求。

## Component boundaries

- `AssistantPage`: 继续持有输入/滚动 controller，并负责打开会话 sheet 的协调。
- `AssistantPageBody`: 负责页面状态分支、顶部动作和主内容布局。
- `AssistantStatusBar`: 缩减或迁移为欢迎区所需的非技术状态提示；设置入口仍调用现有 settings sheet。
- `AssistantConversationSurface`: 继续组合消息列表、错误提示和输入区。
- `AssistantInputBar`: 只负责输入区视觉和输入交互，不承载会话业务逻辑。
- `AssistantConversationDrawer`: 改为 Forui sheet 内容壳，保持回调契约。
- `AssistantConversationDrawerList`: 负责搜索过滤、分组和会话项渲染。

## Data flow and error handling

- `AssistantState`、能力加载、会话加载、流式消息和提议确认全部保持现有来源。
- 抽屉打开期间沿用 `isLoadingRecentConversations`、`recentConversationError` 和 `isOpeningConversation` 状态。
- 会话列表加载失败继续显示项目现有 `StateMessageView` 和重试回调。
- 搜索无匹配只显示本地空结果，不把它误报为网络错误。
- 未登录、能力加载失败、会话加载失败等页面状态不改变其现有行为。

## Verification

- 添加/更新 assistant widget tests，覆盖：顶部抽屉入口、空会话欢迎内容、发送入口、搜索过滤、分组会话点击和关闭 sheet。
- 运行目标测试：`flutter test test/assistant`（若测试目录结构不同，使用实际 assistant 相关文件）。
- 运行 `flutter analyze`。
- 运行 `dart format --set-exit-if-changed` 对本次改动涉及的 Dart 文件。
- 运行 `dart run scripts/check_doc_coverage.dart --warning-only`。
- 如环境支持，运行 assistant 相关页面的移动端 widget/integration 流程，确认 sheet 可打开、可关闭、可切换会话。

## Deferred TODO

- 会话重命名：等待后端提供更新会话标题的 API。
- 会话删除：等待后端提供删除会话的 API，并补充确认交互和错误反馈。
