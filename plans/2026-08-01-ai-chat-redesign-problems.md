# AI 对话页重构：未解决问题清单

Created: 2026-08-01
Updated: 2026-08-03

> 进度说明（2026-08-03 更新）：原问题清单中 **#1-7、#9、#10 已修复**（首屏去工程化、
> 侧边栏会话管理器、输入区、工具 chip 隐藏、建议卡片简化、页面拆分、空态文案、
> 状态管理粒度下沉、上下文菜单升级），见 `docs/03-logs/migration-log/2026-08-01.md`
> 与 `docs/00-current/Active_UI_Today.md`。本文件仅保留**未修复**的问题 8。

## 8. 缺少会话级操作（未修复，阻塞：后端接口未提供）

### 现象

当前用户无法：
- 重命名当前会话标题。
- 删除某条历史会话。
- 清空当前会话（有"新对话"按钮，但不清空历史列表中的当前会话）。
- 查看会话创建时间。

### 代码位置

- `lib/features/assistant/presentation/providers/conversation.dart` — 没有 `renameConversation` / `deleteConversation`。
- `lib/features/assistant/presentation/pages/page.dart` — `handleStartNewConversation` 只调用 `clearConversation`。

### 影响

- 长期使用后历史会话堆积，无法清理。
- 会话标题始终为"未命名会话"或后端生成标题，用户难以识别。

### 期望

- 侧边栏支持长按/右键菜单：重命名、删除。
- 顶部 action 保留"新对话"，但旧会话仍保留在历史列表中，当前会话标题可编辑。
- 后端需新增 `DELETE /conversations/:id` 和 `PATCH /conversations/:id`（或等效端点）。
