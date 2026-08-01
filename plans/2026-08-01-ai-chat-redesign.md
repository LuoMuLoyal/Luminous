# AI 对话页大重构规划

Created: 2026-08-01

状态：规划文档，待产品确认后进入 Phase 6 实施。

## 背景

当前 `lib/features/assistant/presentation/pages/page.dart` 构建的 AI 对话页与正常消费级 AI 聊天应用差距显著：首屏把工具数量、上下文开关、RAG 状态等后端实现细节直接暴露给用户；侧边栏以右侧抽屉承载历史会话，缺少标题编辑、删除、分组等基础能力；输入区、消息气泡、建议卡片也普遍存在"工程师视图"过重的问题。用户已明确反馈"不像一个正常应用的 AI 聊天界面"。

本规划将当前对话页做一次以"聊天优先、隐藏实现、强化会话管理"为主线的重构，目标是把 `/assistant` 从能力演示面板改成交付自然对话体验的独立工作区。

## 重构目标

- **首屏第一印象像聊天应用**：进入页面后主体是消息历史 + 输入区，而不是状态仪表盘。
- **隐藏实现细节**：工具、RAG、流式协议、上下文源等技术状态从主界面移除，只在出错或调试入口中可见。
- **可管理的会话侧边栏**：左侧/右侧抽屉支持历史会话列表、标题、当前高亮、删除、新会话。
- **消息体验对齐标杆**：用户气泡、助手气泡、流式指示、复制、重发、markdown 渲染、代码块等符合主流习惯。
- **建议卡片去工程化**：保存/修改/删除建议只保留用户可理解的核心信息，去除目标 ID、定位方式、设置项 key 等元数据展示。
- **可维护的代码结构**：把当前 539 行的 `AssistantPage` 和 369 行的 `AssistantConversationSurface` 拆分为职责单一的子组件。

## 当前核心问题速览

详细问题清单与代码定位见 [AI Chat Redesign Problems](2026-08-01-ai-chat-redesign-problems.md)。

1. **Hero 状态卡过度技术化** — 展示"工具 14/14、上下文 4/4、RAG、流式输出"等实现标签。
2. **侧边栏不是会话管理器** — 历史会话从右侧 sheet 弹出，无标题编辑、删除、搜索、日期分组。
3. **输入区占据过多视觉权重** — 固定 2 行最小高度、发送按钮在右侧，缺少快捷提问、语音入口（可选）。
4. **每条助手消息下都挂工具 chip** — 泄露调用链路，干扰阅读。
5. **建议卡片把后端元数据当正文** — `目标`、`定位方式`、`设置项`、`过期时间`、`确认前约束` 全部平铺。
6. **页面结构空间利用率低** — `FCard` 套 `Padding` 再套 `Column`，移动端内容区被边框和留白挤压。
7. **空态与错误态过于技术** — "后端能力已就绪"、"交互式对话链路还没有完全就绪"等文案不像用户语言。
8. **缺少会话级操作** — 无法重命名、删除、清空当前会话。
9. **状态管理粒度仍偏重** — 页面级 `select` 切片过多，拆分后应下沉到子组件。
10. **上下文菜单与重发能力缺失** — 仅支持长按复制，无桌面右键、无单条重发/重生成。

## 重构原则

1. **聊天优先，状态后置** — 主界面只保留对话与输入；状态、设置、调试信息移入二级入口或设置页。
2. **默认隐藏，出错才揭示** — 工具、RAG、上下文源默认不展示；只有在需要用户决策或报错时才出现。
3. **会话是可管理的对象** — 侧边栏按"今天 / 最近 7 天 / 更早"分组，支持标题、删除、新会话。
4. **消息气泡自包含** — 用户消息可复制、助手消息可复制 + 重发；建议卡片只展示用户需要确认的内容。
5. **移动优先，桌面增强** — 移动端抽屉承载侧边栏；桌面端可常驻 split-view（类似 Messages / ChatGPT）。
6. **渐进式实施** — 先重构布局与文案，再拆组件，最后引入会话管理能力；每阶段可独立验证。

## 文档结构

- [AI Chat Redesign Problems](2026-08-01-ai-chat-redesign-problems.md) — 逐项问题、当前代码位置、影响面。
- [AI Chat Redesign Plan](2026-08-01-ai-chat-redesign-plan.md) — 分阶段实施计划、文件拆分、接口调整、验收标准。
- [Product AI Design](../docs/01-product/Product_AI_Design.md) — 本重构需继续遵循的 AI 能力边界与安全规则。
- [Active UI Today](../docs/00-current/Active_UI_Today.md) — 助手入口在 Today 的展示方式，本重构不改动入口。

## 分阶段概要

| 阶段 | 主题 | 交付物 | 阻塞点 |
|------|------|--------|--------|
| 1 | 首屏去工程化 | Hero 移除技术 chip、空态/错误态文案重写、状态卡默认折叠 | 无 |
| 2 | 输入区与消息气泡 | 单行输入框、发送图标按钮、工具 chip 隐藏、复制/重发统一 | 无 |
| 3 | 侧边栏重构 | 抽屉改为会话管理器、分组、当前高亮、删除、新会话 | 需后端新增 `DELETE /conversations/:id` 与 `PATCH /conversations/:id` |
| 4 | 建议卡片简化 | 去除元数据区、保留标题+摘要+预览字段+操作按钮 | 后端 proposal schema 可不变 |
| 5 | 代码结构拆分 | `AssistantPage` 拆分为 page / chat-shell / input-bar / message-list / drawer | 无 |
| 6 | 桌面端 split-view | 桌面端常驻侧边栏 + 右侧聊天区 | 依赖 `DesktopTabShell` 适配 |

完整实施细节、文件映射、ARB 键变更、验收 checklist 见 [AI Chat Redesign Plan](2026-08-01-ai-chat-redesign-plan.md)。

## 后端接口确认（已核实）

截至 2026-08-01，Lucent `AssistantController` 已暴露的会话相关端点：

- `GET /api/v1/user/assistant/conversations` — 列出最近会话
- `GET /api/v1/user/assistant/latest` — 获取最新活跃会话
- `POST /api/v1/user/assistant/conversations/:conversationId/open` — 激活并打开指定会话
- `POST /api/v1/user/assistant/conversations/:conversationId/confirm` — 确认/拒绝提案
- `POST /api/v1/user/assistant/latest/clear` — 将当前最新活跃会话标记为 `archived`
- `POST /api/v1/user/assistant/messages/stream` — 流式对话

**尚未提供**：
- `DELETE /api/v1/user/assistant/conversations/:id`（或等效软删除端点）
- `PATCH /api/v1/user/assistant/conversations/:id`（重命名 title）

`AssistantConversation` 当前 `status` 枚举只有 `active` / `archived`，且 `archived` 已被用于"非当前活跃"语义，不适合直接复用为"已删除"。因此阶段 3 的"删除历史会话"能力需要后端新增：

1. 在 `AssistantConversationStatus` 枚举中增加 `deleted`（或新增 `isDeleted` / `deletedAt` 字段），并迁移 `listRecentSummaries` 过滤掉 deleted。
2. 在 `AssistantController` 增加 `DELETE /conversations/:conversationId`（软删除）或 `POST /conversations/:conversationId/delete`。
3. 在 `AssistantController` 增加 `PATCH /conversations/:conversationId` 或 `POST /conversations/:conversationId/rename`，仅允许更新 `title`。

阶段 3 实施时应先在 UI 中预留入口但默认禁用（或显示"即将支持"），等后端接口 ready 后启用。详见实施计划文档。

## 不纳入本次重构的范围

- 不改变后端工具/上下文/RAG 能力本身，只改变前端展示。
- 不引入语音输入、图片输入、文件附件；如后续需要，另开独立规划。
- 不改变 Today 页顶部的助手入口。
- 不引入 GenUI 开放式组件渲染；保持现有 4 种 proposal 类型不变，仅简化展示。
- 不改动 `AssistantController` 的 SSE 流式逻辑与错误分类；只调整其消费者布局。

## 验收总标准

- `AssistantPage` 主文件行数 < 200，子组件文件 < 250。
- 进入 `/assistant` 首屏时，主视觉区域 70% 以上被消息历史或输入区占据，不出现工具/上下文/RAG 标签。
- 侧边栏能在 3 步内完成：新建会话、切换历史会话、删除旧会话。
- 建议卡片元数据（目标、定位方式、设置项、过期时间、约束）不再显示在主路径上。
- `flutter analyze` 与 `flutter test` 保持通过；新增 widget 测试覆盖侧边栏与消息气泡。
