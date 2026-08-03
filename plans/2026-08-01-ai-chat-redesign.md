# AI 对话页重构：未完成部分

Created: 2026-08-01
Updated: 2026-08-03

> 进度说明（2026-08-03 更新）：原规划的**阶段 1-5 已全部实施**（首屏去工程化、
> 输入区与消息气泡、侧边栏会话管理器 UI、页面拆分瘦身、设置入口重新接入、
> widget 测试覆盖），见 `docs/03-logs/migration-log/2026-08-01.md` 与
> `docs/00-current/Active_UI_Today.md`。本文件仅保留**未实施**的内容：
> 会话重命名/删除（依赖后端接口）与桌面端 split-view。

## 未完成项

### 1. 会话重命名与删除（阻塞：后端接口未提供）

截至 2026-08-01，Lucent `AssistantController` **尚未提供**：

- `DELETE /api/v1/user/assistant/conversations/:id`（或等效软删除端点）
- `PATCH /api/v1/user/assistant/conversations/:id`（重命名 title）

`AssistantConversation.status` 枚举当前只有 `active` / `archived`，且 `archived`
已被用于"非当前活跃"语义，不适合复用为"已删除"。后端需要：

1. 在 `AssistantConversationStatus` 枚举中增加 `deleted`（或新增 `isDeleted` / `deletedAt` 字段）。
2. 修改 `AssistantConversationRepository.listRecentSummaries` 过滤掉 `deleted`。
3. 新增 `DELETE /conversations/:conversationId`（软删除）。
4. 新增 `PATCH /conversations/:conversationId`（仅允许更新 `title`）。

前端待办（后端就绪后接入）：

- `AssistantConversationDrawerList` 增加重命名/删除入口（当前为禁用态提示"即将支持"）。
- `AssistantController` 新增 `renameConversation` / `deleteConversation`，repository /
  data source 层新增对应接口（`lib/features/assistant/presentation/providers/conversation.dart`、
  `domain/repositories/assistant.dart`、`data/repositories/lucent.dart`）。
- 重命名本地先更新再异步同步，失败回滚并 toast 提示；删除需二次确认。
- 已记录到 `docs/00-current/TODO.md`。

### 2. 桌面端 split-view（阶段 6，阻塞：依赖 `DesktopTabShell` 适配）

- 断点 `>= Breakpoints.tablet` 时左侧常驻 280-320px 会话列表 + 右侧聊天区
  （参考 `DesktopTabShell` 与 Settings 主-从布局模式）；移动端保持现有页面内
  不透明 push drawer。
- 桌面端聊天内容区 max-width 720px 居中，移动端全宽（保留安全边距）。
- 当前实现：历史会话使用页面内不透明 push drawer（`Stack` + 固定宽度），
  聊天页整体向右移动，无桌面常驻 split-view。

## 验收

- 后端接口就绪后，侧边栏 3 步内完成：新建会话、切换历史会话、删除旧会话；当前会话标题可编辑。
- 桌面端 `>= 960px` 时左侧会话列表常驻，右侧聊天区可滚动；移动端侧边栏仍为抽屉。
