# AI 对话页重构：问题清单

Created: 2026-08-01

本文是 [AI Chat Redesign](2026-08-01-ai-chat-redesign.md) 的子文档，逐项列出当前 AI 对话页与正常聊天应用之间的差距，附代码位置与影响面。

## 1. Hero 状态卡过度技术化

### 现象

进入 `/assistant` 后，首屏顶部展示一块状态卡，内含：
- "工具 14/14"
- "上下文 4/4"
- "流式输出"
- "RAG"

这些标签直接对应后端 `AssistantCapabilities` 中的 `tools`、`assistantContext.enabledCount`、`streamingSupported`、`ragEnabled`。

### 代码位置

- `lib/features/assistant/presentation/widgets/sections/hero.dart:125-148` — `_FullHero` 的 `Wrap` 内 `_StatusChip` 列表。
- `lib/features/assistant/presentation/pages/page.dart:138-143` — `statusSummaryText` 使用 "后端能力已就绪" 等工程师文案。
- `lib/l10n/src/assistant_zh.arb:22-25` / `assistant_en.arb:22-25` — `assistantStatusToolsLabel`、`assistantStatusContextLabel`、`assistantStatusStreamingLabel`、`assistantStatusRagLabel`。

### 影响

- 普通用户不理解 "RAG"、"流式输出"、"工具 14/14" 的含义。
- 首屏被状态卡占据，消息历史和输入区被压到下方。
- 与 ChatGPT / Claude / Gemini 等主流 AI 聊天应用首屏差距明显。

### 期望

- 首屏顶部只保留 minimal chrome：页面标题（可选）+ 一个可折叠的轻量状态提示（例如只显示一个点表示可用/不可用）。
- 详细状态移入设置页或调试抽屉，不在主路径展示。

## 2. 侧边栏不是会话管理器

### 现象

历史会话通过右上角"最近会话"图标触发一个右侧 sheet 抽屉：
- 无标题编辑能力。
- 无删除会话能力。
- 无搜索、分组（今天/昨天/更早）。
- 当前会话仅用 "当前" 标签高亮，视觉上不够清晰。
- 抽屉宽度在手机端为屏幕 80%，与常规聊天应用侧边栏行为不一致。

### 代码位置

- `lib/features/assistant/presentation/pages/page.dart:292-316` — `openRecentConversationsDrawer` 用 `showFSheet` 从右侧弹出。
- `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart` — 整个 `AssistantConversationDrawer` 实现。
- `lib/features/assistant/presentation/providers/conversation.dart:154-189` — 只提供 `listRecentConversations` 和 `openConversation`，没有 `deleteConversation` / `renameConversation`。

### 影响

- 用户无法管理历史会话，长期会变成不可维护的列表。
- 新会话与切换会话操作都放在顶部 action 区，缺少统一的会话上下文。

### 期望

- 侧边栏成为独立的会话管理器：左侧/右侧抽屉，包含新建会话、历史列表分组、标题编辑、删除、当前高亮。
- 桌面端可常驻 split-view：左侧会话列表 + 右侧聊天区。

## 3. 输入区视觉与交互过重

### 现象

- 输入框最小 2 行、最大 6 行，默认高度较高。
- 发送按钮是完整的 `FButton`，位于输入框右侧，视觉占比大。
- 桌面快捷键提示 "Ctrl/⌘ + Enter 发送" 常驻在输入框下方，对普通用户 noisy。
- 禁用状态下输入框上方显示一行提示 "AI 对话已关闭，输入暂不可用"。
- 没有快捷提问（starter prompts）区域。

### 代码位置

- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart:253-368` — `_InputComposer`。
- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart:117-125` — 输入区上方常驻错误提示区。

### 影响

- 输入区像表单而不是聊天输入条。
- 新用户打开页面后没有提示可以问什么。
- 移动端屏幕被输入框和 Hero 卡挤压，历史消息可视区域小。

### 期望

- 输入框默认 1 行，随内容自动扩展到最多 4-5 行。
- 发送按钮改为圆形图标按钮（类似 Messages / WhatsApp / ChatGPT）。
- 空会话时展示 3-4 个快捷提问 chip（可滚动），帮助用户开始对话。
- 快捷键提示只在获得焦点且桌面端时短暂显示，不常驻。

## 4. 每条助手消息都暴露工具调用

### 现象

每条助手消息下方若 `usedTools` 非空，会用 `Wrap` 渲染多个 `AssistantToolChip`，例如：
- "今日记录"
- "中文说明书检索"
- "DrugBank 实体定位"
- "保存建议"

### 代码位置

- `lib/features/assistant/presentation/widgets/shared/message_bubble.dart:127-139` — 工具 chip 渲染。
- `lib/features/assistant/presentation/widgets/shared/chips.dart` — `AssistantToolChip` 组件。
- `lib/features/assistant/presentation/utils/ui_formatters.dart:9-33` — `localizeToolName` 把 tool ID 翻译为用户可见文案。

### 影响

- 工具名对普通用户是噪音，打断阅读。
- 即使只是普通问答，也可能因为隐式调用工具而展示 chip，造成"AI 在背着我操作"的错觉。

### 期望

- 默认不展示工具 chip。
- 若需要向用户解释"参考了哪些数据"，改为统一的"来源"或"基于你的健康档案"一句话摘要，而不是 tool ID 列表。
- 调试/高级模式下可展开查看完整调用链，但不在主路径展示。

## 5. 建议卡片把后端元数据当正文

### 现象

建议卡片（`AssistantProposalCard`）当前展示：
- 标题 + 摘要
- `目标`：例如某条记录 ID 或设置项标签
- `定位方式`：matchedBy 字段
- `设置项`：settingKeys 字段
- `过期时间`
- `确认前约束`：后端 constraints 列表

### 代码位置

- `lib/features/assistant/presentation/widgets/shared/proposal_card.dart:94-211` — `_ProposalMetaSection` 渲染所有元数据。
- `lib/l10n/src/assistant_zh.arb:81-86` — `assistantProposalTargetLabel`、`assistantProposalMatchedByLabel`、`assistantProposalSettingKeysLabel`、`assistantProposalExpiresAtLabel`、`assistantProposalConstraintsLabel`。

### 影响

- 用户需要确认的操作被淹没在工程字段中。
- "确认前约束" 直接罗列后端文本，可能包含内部字段名或格式。
- 卡片高度不稳定，长 constraints 列表会撑开布局。

### 期望

- 建议卡片只保留：图标 + 标题 + 摘要 + 关键预览字段（如剂量、时间）+ 确认/取消按钮。
- 过期、失败、执行状态用轻量 tag 或 subtle 文案表达，不展示过期时间戳和内部状态字段。
- 详细的执行日志/失败原因移入二级展开区或 toast。

## 6. 页面结构空间利用率低

### 现象

`AssistantConversationSurface` 外层使用 `FCard` + `Padding(Spacing.level5)` + `Column`，整个聊天区域被包裹在一张卡片内：
- 移动端上下左右留白过大。
- 消息列表与输入区被边框和底色割裂，不像沉浸式聊天界面。
- 外层 `PageScaffold` 本身又有 `ResponsiveContentFrame` 限宽，进一步压缩内容区。

### 代码位置

- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart:62-128` — `FCard` + `Padding` 外壳。
- `lib/features/assistant/presentation/pages/page.dart:401-535` — `ResponsiveContentFrame` + 外层 `Column`。

### 影响

- 移动端可视区域小，长对话需要频繁滚动。
- 聊天界面应该全宽或接近全宽，当前被卡片边框限制。

### 期望

- 聊天区使用全宽布局，消息气泡在移动端接近屏幕边缘（保留安全边距）。
- 桌面端使用 max-width 约束（如 720px）居中，符合阅读体验。
- 移除 `FCard` 外壳，改用直接背景色或透明背景。

## 7. 空态与错误态文案技术化

### 现象

- 未就绪时："交互式对话链路还没有完全就绪。"
- 就绪时："后端能力已就绪，可以开始对话。"
- 模型缺失时："服务端还没有可用的聊天模型配置。"
- 加载失败回退："能力信息这次没有取到，可以重新拉取一次。"

### 代码位置

- `lib/l10n/src/assistant_zh.arb:16-20`、`27-29`、`31` 等。
- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart:166-184` — 空态/禁用态 `StateMessageView`。

### 影响

- 用户看到"链路"、"后端"、"能力信息"等词会感到困惑和不信任。
- 空态没有引导用户开始提问，只做了功能说明。

### 期望

- 未就绪："AI 助手正在准备中，请稍后再试。"
- 就绪："你好，我可以帮你整理健康记录、解释用药提醒。"
- 模型缺失："AI 助手暂时不可用，请稍后再试。"（更模糊，不暴露内部配置）
- 空态：用问候语 + 快捷提问引导，而不是"开始第一条消息"。

## 8. 缺少会话级操作

### 现象

当前用户无法：
- 重命名当前会话标题。
- 删除某条历史会话。
- 清空当前会话（有"新对话"按钮，但不清空历史列表中的当前会话）。
- 查看会话创建时间。

### 代码位置

- `lib/features/assistant/presentation/providers/conversation.dart` — 没有 `renameConversation` / `deleteConversation`。
- `lib/features/assistant/presentation/pages/page.dart:261-264` — `handleStartNewConversation` 只调用 `clearConversation`。

### 影响

- 长期使用后历史会话堆积，无法清理。
- 会话标题始终为"未命名会话"或后端生成标题，用户难以识别。

### 期望

- 侧边栏支持长按/右键菜单：重命名、删除。
- 顶部 action 保留"新对话"，但旧会话仍保留在历史列表中，当前会话标题可编辑。
- 后端需新增 `DELETE /conversations/:id` 和 `PATCH /conversations/:id`（或等效端点）。

## 9. 状态管理粒度与页面职责

### 现象

`AssistantPage` 当前订阅了 9 个 `select` 切片，并在页面内处理所有业务回调（启用/禁用、上下文开关、发送、重试、建议确认、侧边栏打开）。
- `pages/page.dart` 539 行。
- `widgets/views/conversation_surface.dart` 369 行。
- `widgets/sections/hero.dart` 343 行。

### 代码位置

- `lib/features/assistant/presentation/pages/page.dart:38-62` — 多个 `ref.watch(select(...))`。
- `lib/features/assistant/presentation/pages/page.dart:145-349` — 大量业务回调函数内联在页面中。

### 影响

- 页面文件难以维护，新增功能会进一步膨胀。
- 子组件无法独立测试，因为所有逻辑都在页面层。

### 期望

- 拆分为：
  - `AssistantChatPage`：只负责路由入口和布局 shell。
  - `AssistantChatShell`：桌面端 split-view / 移动端 drawer 布局。
  - `AssistantMessageList`：消息列表、空态、滚动控制。
  - `AssistantInputBar`：输入框、发送、快捷提问、禁用态。
  - `AssistantConversationDrawer`：会话列表、分组、操作。
  - `AssistantSettingsSheet`：AI 启用、记忆、上下文源开关（保持现有能力但入口更深）。
- 页面层只保留与路由/布局相关的逻辑，业务回调下沉到组件或 orchestrator。

## 10. 其他体验细节

### 10.1 复制操作仅通过长按弹出原生菜单

- 当前实现：`message_bubble.dart:183-221` 用 `GestureDetector.onLongPress` + `showMenu`。
- 问题：桌面端缺少右键菜单，且只提供"复制文本"，没有"复制代码块"等细分能力。
- 期望：使用 `FContextMenu.tiles`（项目已有桌面端右键 + 移动端长按统一方案）替代原生 `showMenu`。

### 10.2 流式指示器位置

- 当前实现：`message_bubble.dart:111-126` 在气泡内部渲染三个跳动圆点 + "正在生成"。
- 问题：文案 "正在生成" 占据空间，且跳动圆点颜色与主题背景对比度不够时不易看清。
- 期望：改为简洁的 typing indicator（例如右下角或气泡底部的小脉冲），不重复文字标签。

### 10.3 没有重发最后一条用户消息的能力

- 当前实现：只有全局错误时提供 `assistantRetryAction` 重新发送上一次失败的输入。
- 问题：用户无法单独对某条用户消息点击重发。
- 期望：每条用户消息的长按/右键菜单提供"重新发送"，以及每条助手消息提供"重新生成"。

### 10.4 顶部 action 区图标过多

- 当前实现：`pages/page.dart:355-399` 同时展示"最近会话"、"新对话"、"助手设置"三个图标按钮。
- 问题：新用户进入页面面对三个图标，认知负担高。
- 期望：侧边栏入口合并为一个"会话"按钮；新会话放入侧边栏或输入区左侧；设置移入用户头像/菜单或侧边栏底部。

## 汇总表

| 问题 | 严重程度 | 用户可见 | 代码位置 | 依赖后端 |
|------|----------|----------|----------|----------|
| Hero 技术标签 | 高 | 是 | `hero.dart` | 否 |
| 侧边栏非会话管理器 | 高 | 是 | `conversation_drawer.dart` | 是（删除/重命名） |
| 输入区过重 | 中 | 是 | `conversation_surface.dart` | 否 |
| 工具 chip 暴露 | 高 | 是 | `message_bubble.dart` | 否 |
| 建议卡片元数据 | 高 | 是 | `proposal_card.dart` | 否 |
| 空间利用率低 | 中 | 是 | `conversation_surface.dart` | 否 |
| 文案技术化 | 中 | 是 | ARB | 否 |
| 缺少会话操作 | 中 | 是 | `conversation.dart` | 是 |
| 页面职责过重 | 中 | 否（维护债） | `page.dart` | 否 |
| 复制/右键菜单 | 低 | 是 | `message_bubble.dart` | 否 |

