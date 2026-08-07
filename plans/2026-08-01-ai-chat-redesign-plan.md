# AI 对话页重构：未完成实施方案

Created: 2026-08-01
Updated: 2026-08-07（合并原 `ai-chat-redesign-problems.md` 和 `ai-chat-redesign.md`）

> 进度说明（2026-08-03 更新）：原实施方案中**阶段 1、2、4、5 与阶段 3 的 UI 部分
> （抽屉、分组、搜索、高亮）已完成**，最终阶段映射与验收见
> `docs/03-logs/migration-log/2026-08-01.md`。本文件仅保留**未实施**的部分：
> 阶段 3 的会话删除/重命名（后端接口阻塞）与阶段 6 桌面 split-view。
>
> 2026-08-07 合并说明：原 `2026-08-01-ai-chat-redesign-problems.md`（问题清单，
> 仅剩 #8 未修复）和 `2026-08-01-ai-chat-redesign.md`（未完成部分概要）
> 内容与本文件高度重叠，已合并到本文件并删除。

## 现状与问题

当前用户无法：
- 重命名当前会话标题（始终为"未命名会话"或后端生成标题，用户难以识别）
- 删除某条历史会话（长期使用后历史会话堆积，无法清理）
- 清空当前会话（有"新对话"按钮，但不清空历史列表中的当前会话）
- 查看会话创建时间

相关代码位置：
- `lib/features/assistant/presentation/providers/conversation.dart` — 没有 `renameConversation` / `deleteConversation`
- `lib/features/assistant/presentation/pages/page.dart` — `handleStartNewConversation` 只调用 `clearConversation`

## 未完成部分

### 阶段 3（剩余）：会话删除与重命名（阻塞：后端接口未提供）

当前 `AssistantConversationDrawerList` 已支持分组、搜索、高亮与新建；重命名/删除
入口为禁用态提示"即将支持"。

前端待办（后端接口就绪后启用）：

1. `AssistantController` 新增：
   - `renameConversation(String id, String title)`（调用后端 `PATCH`）。
   - `deleteConversation(String id)`（调用后端 `DELETE`）。
2. `AssistantRepository` / data source 层新增对应接口
   （`lib/features/assistant/domain/repositories/assistant.dart`、
   `lib/features/assistant/data/repositories/lucent.dart`、
   `lib/features/assistant/data/datasources/assistant.dart`）。
3. 侧边栏当前项右键/长按菜单：重命名、删除；重命名本地先更新再异步同步，
   失败回滚并 toast 提示；删除二次确认。
4. 侧边栏顶部 action 合并：保留"会话"图标按钮，"新对话"移到侧边栏顶部。

### 阶段 6：桌面端 split-view 与收尾（阻塞：依赖 `DesktopTabShell` 适配）

目标：桌面端提供常驻会话列表 + 聊天区，移动端保持抽屉。

1. **响应式布局**
   - 断点 `< Breakpoints.tablet`：使用现有页面内不透明 push drawer 承载会话列表。
   - 断点 `>= Breakpoints.tablet`：左侧固定 280-320px 会话列表 + 右侧聊天区
     （参考 `DesktopTabShell` 和 Settings 主-从布局模式）。
2. **`ResponsiveContentFrame` 移除或调整**
   - 聊天区不再使用 `FCard` 外壳，桌面端聊天内容区 max-width 720px 居中。
   - 移动端聊天内容区全宽（保留安全边距）。
3. **新增 widget 测试**
   - 空态展示快捷提问；消息气泡复制菜单；侧边栏分组与高亮；
     发送消息后输入框清空。

## 后端需新增接口（阶段 3 剩余）

| 方法 | 端点 | 用途 | 备注 |
|------|------|------|------|
| `DELETE` | `/api/v1/user/assistant/conversations/:conversationId` | 软删除历史会话 | 需新增 `deleted` status 或 `deletedAt` 字段 |
| `PATCH` | `/api/v1/user/assistant/conversations/:conversationId` | 重命名会话 title | body `{ title: string }`，仅允许 title |

实现建议：
- 优先使用软删除，保留 `archived` 语义不变。
  - `AssistantConversation.status` 枚举当前只有 `active` / `archived`，且 `archived`
    已被用于"非当前活跃"语义，不适合复用为"已删除"。
  - 需在 `AssistantConversationStatus` 枚举中增加 `deleted`（或新增 `isDeleted` /
    `deletedAt` 字段）。
- `listRecentSummaries` 默认过滤 `deleted`。
- 若选择硬删除，注意 `AssistantMessage` 外键级联删除。

## 验收标准（未完成项）

| 阶段 | 关键验收项 | 验证命令 |
|------|-----------|---------|
| 3（剩余） | 侧边栏支持新建/切换/删除/重命名；历史分组正确 | 手动测试 + widget 测试 |
| 6 | 桌面 split-view 常驻；移动端抽屉流畅；新增测试覆盖 ≥ 60% | `flutter test` + 多分辨率手动验证 |

## 风险与回退策略（未完成项）

1. **后端接口未就绪**：阶段 3 的删除/重命名先 UI 占位 + 禁用，等后端接口 ready 后启用（现状）。
2. **桌面 split-view 与 `DesktopTabShell` 冲突**：阶段 6 开始前先验证 `DesktopTabShell`
   对非 shell 页面的支持，必要时只在小范围内使用 split-view。

## 备注

- 会话重命名与删除已记录到 `docs/00-current/TODO.md`，等待后端 API。
- 所有用户可见文案变更必须通过 ARB fragment 流程，禁止直接修改 `app_zh.arb` / `app_en.arb`。
