# AI 对话页重构：实施方案

Created: 2026-08-01
Updated: 2026-08-01（本计划已按实际实施节奏完成，最终阶段映射与验收结果见 `docs/03-logs/migration-log/2026-08-01.md`）

本文是 [AI Chat Redesign](2026-08-01-ai-chat-redesign.md) 的子文档，给出分阶段实施方案、文件拆分、接口调整与验收标准。

## 后端接口现状与阶段 3 前置条件

截至 2026-08-01，Lucent 已暴露会话相关端点：

- `GET /api/v1/user/assistant/conversations`
- `GET /api/v1/user/assistant/latest`
- `POST /api/v1/user/assistant/conversations/:conversationId/open`
- `POST /api/v1/user/assistant/conversations/:conversationId/confirm`
- `POST /api/v1/user/assistant/latest/clear`
- `POST /api/v1/user/assistant/messages/stream`

**尚未提供**：
- `DELETE /api/v1/user/assistant/conversations/:conversationId`
- `PATCH /api/v1/user/assistant/conversations/:conversationId`（重命名）

`AssistantConversation.status` 枚举当前只有 `active` / `archived`，且 `archived` 已被用于"非当前活跃"语义，不适合复用为"已删除"。阶段 3 实施前需要后端：

1. 在 `AssistantConversationStatus` 枚举中增加 `deleted`（或新增 `isDeleted` / `deletedAt` 字段）。
2. 修改 `AssistantConversationRepository.listRecentSummaries` 过滤掉 `deleted`。
3. 新增 `DELETE /conversations/:conversationId`（软删除）。
4. 新增 `PATCH /conversations/:conversationId`（仅允许更新 `title`）。

如果后端接口未就绪，阶段 3 可以先完成 UI 结构与分组，删除/重命名入口设为禁用或提示"即将支持"。

## 阶段 1：首屏去工程化（P1）

目标：进入 `/assistant` 后首屏看起来像聊天应用，而不是能力仪表盘。

### 具体改动

1. **重写 `AssistantHero` 为 `AssistantStatusBar`**
   - 位置：`lib/features/assistant/presentation/widgets/sections/status_bar.dart`（新文件，可选保留旧文件直到阶段 5 删除）。
   - 默认折叠为单行：左侧小图标（sparkles / bot）+ 标题 + 状态点（绿/黄/灰）。
   - 点击单行展开为一个轻量面板，仅展示一句自然语言状态文案（例如"AI 助手已准备好" / "AI 助手正在准备中"）。
   - 移除 `_FullHero` 中所有 `_StatusChip`（工具、上下文、流式、RAG）。

2. **状态文案重写**
   - 修改 `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb`：
     - `assistantStatusReady`："AI 助手已准备好。"
     - `assistantStatusDisabled`："AI 助手已关闭。"
     - `assistantStatusModelMissing`："AI 助手暂时不可用。"
     - `assistantStatusNotReady`："AI 助手正在准备中。"
   - 执行 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n`。

3. **隐藏技术入口**
   - 设置抽屉（`AssistantControlsSheet` / `AssistantControlsPanel`）保留，但不再从顶部 action 区直接展示"齿轮"入口。
   - 在展开后的状态栏右下角放一个 subtle "管理上下文" 文字链接，或在侧边栏底部放一个"设置"入口。

### 不改动

- 不删除 `AssistantCapabilities` 数据模型，只让前端不渲染其内部字段。
- 不改动 `AssistantController` 加载逻辑。

### 验收

- 进入 `/assistant` 后首屏看不到"工具"、"RAG"、"上下文"、"流式输出"等词汇。
- `AssistantHero` 折叠态高度 ≤ 56dp。
- 首屏消息历史/输入区占据主体。

## 阶段 2：输入区与消息气泡（P1-P2）

目标：输入区更像聊天输入条，消息气泡减少实现细节暴露。

### 具体改动

1. **新建 `AssistantInputBar`**
   - 文件：`lib/features/assistant/presentation/widgets/sections/input_bar.dart`。
   - 高度默认 1 行，随内容扩展到最多 5 行。
   - 发送按钮改为圆形图标按钮（`FButton.icon` 或 `IconButton`），使用 `SemanticIcons.actionSend`。
   - 左侧增加"快捷提问"入口（只在空会话时展示）。
   - 桌面快捷键提示改为 focus 态下方 subtle 文案，2 秒后自动淡出或只在 hover 时显示。

2. **空会话快捷提问区**
   - 文件：`lib/features/assistant/presentation/widgets/sections/starter_prompts.dart`（新）。
   - 展示 3-4 个 chip：例如"总结我今天的记录"、"我最近睡眠怎么样"、"我当前在吃什么药"。
   - 点击后直接填入输入框并发送，或立即发送。

3. **隐藏消息气泡下的工具 chip**
   - 文件：`lib/features/assistant/presentation/widgets/shared/message_bubble.dart`。
   - 删除 `if (!isStreaming && usedTools.isNotEmpty)` 区块的默认渲染。
   - 保留 `usedTools` 字段，但只在高级/调试模式（后续阶段 5 引入）下展示。
   - 可选：在助手消息底部用一行小字"基于你的健康档案与当前用药"替代具体工具列表。

4. **复制/重发菜单升级**
   - 文件：`message_bubble.dart`。
   - 用 `FContextMenu.tiles` 替代 `showMenu` + `GestureDetector.onLongPress`。
   - 菜单项：
     - 复制文本
     - 重新生成（仅助手消息）
     - 重新发送（仅用户消息）
   - 桌面端右键触发，移动端长按触发（与项目其它模块一致）。

5. **流式指示器简化**
   - 文件：`message_bubble.dart`。
   - 将 "正在生成" 文字标签移除，仅保留脉冲动画或更简洁的 typing indicator。
   - 使用 `SemanticColor.primary` 的 subtle 色调，确保在暗色/亮色主题下均可见。

### 验收

- 输入框默认 1 行，空会话时展示快捷提问区。
- 发送按钮为图标按钮。
- 消息气泡不再默认展示工具 chip。
- 桌面端右键/移动端长按可唤出上下文菜单。

## 阶段 3：侧边栏重构为会话管理器（P1）

目标：历史会话可管理、可分组、可删除、可重命名。

### 具体改动

1. **新增 `AssistantConversationDrawer` 布局调整**
   - 文件：`lib/features/assistant/presentation/widgets/views/conversation_drawer.dart`（新，替换旧 `dialogs/conversation_drawer.dart`）。
   - 从右侧 sheet 改为左侧或右侧抽屉（根据平台/设置决定），并区分移动端与桌面端：
     - 移动端：抽屉。
     - 桌面端：split-view 常驻左侧 280px 面板。
   - 列表按"今天"、"最近 7 天"、"更早"分组。
   - 每个会话项展示：标题、最后消息时间、当前高亮、悬停/长按菜单。

2. **新增侧边栏操作能力**
   - 在 `AssistantController` 中新增：
     - `renameConversation(String id, String title)`（调用后端 `PATCH`）。
     - `deleteConversation(String id)`（调用后端 `DELETE`）。
   - 在 `AssistantRepository` / data source 层新增对应接口。
   - 若后端尚未支持，先以 UI 入口 + 禁用态提示"即将支持"，等后端 ready 后启用。

3. **顶部 action 合并**
   - 在 `AssistantPage` 的顶部 action 区：
     - 保留一个"会话"图标按钮（打开侧边栏）。
     - 将"新对话"移到侧边栏顶部或输入区左侧，不再在顶部展示。
     - 将"助手设置"移到侧边栏底部或展开状态栏中，不再在顶部展示齿轮。

4. **当前会话标题可编辑**
   - 在侧边栏当前项右侧显示编辑图标，或长按/右键菜单中选择"重命名"。
   - 编辑时本地先更新，再异步同步后端；失败时回滚并 toast 提示。

### 验收

- 侧边栏支持 3 步内完成：新建会话、切换历史会话、删除旧会话。
- 历史会话按时间分组。
- 当前会话高亮，标题可编辑（后端支持时启用）。

## 阶段 4：建议卡片简化（P1）

目标：建议卡片只展示用户需要确认的信息，去除后端元数据。

### 具体改动

1. **简化 `AssistantProposalCard`**
   - 文件：`lib/features/assistant/presentation/widgets/shared/proposal_card.dart`。
   - 删除 `_ProposalMetaSection` 的完整展示：
     - 不显示 `目标`。
     - 不显示 `定位方式`。
     - 不显示 `设置项`。
     - 不显示 `过期时间`（过期状态用 subtle tag 表示）。
     - 不显示 `确认前约束` 列表（约束文本可保留，但需经产品/后端重新改写为自然语言后，在摘要区或折叠区简短展示）。
   - 保留：
     - 图标 + 标题
     - 摘要
     - 原因（如果存在且自然语言化）
     - 预览字段（如剂量、时间、记录类型）
     - 确认 / 取消 按钮
     - 状态 tag（待确认 / 执行中 / 已确认 / 已取消 / 失败）

2. **失败状态处理**
   - 执行失败时，不再把 `executionError` 原始文本直接展示在卡片中。
   - 改为统一错误提示："执行失败：{错误摘要}"，并提供"重试"按钮。
   - 详细错误日志可移入调试抽屉或 talker 日志。

3. **ARB 清理**
   - 删除以下键（如果阶段 1 未删除）：
     - `assistantProposalTargetLabel`
     - `assistantProposalMatchedByLabel`
     - `assistantProposalSettingKeysLabel`
     - `assistantProposalExpiresAtLabel`
     - `assistantProposalConstraintsLabel`
   - 执行 ARB 合并与生成。

### 验收

- 建议卡片高度不超过 220dp（不含预览字段）。
- 普通用户能在不看元数据的情况下理解需要确认什么。
- 后端 schema 无需改动（仍返回相同字段，前端不渲染即可）。

## 阶段 5：代码结构拆分（P2）

目标：`AssistantPage` 和 `AssistantConversationSurface` 拆分为职责单一、可独立测试的组件。

### 目标文件结构

```text
lib/features/assistant/presentation/
  pages/
    page.dart                    # 路由入口 + 布局 shell（目标 < 200 行）
  widgets/
    chat_shell.dart              # 桌面/移动布局适配（drawer / split-view）
    views/
      message_list.dart          # 消息列表、空态、滚动、流式 draft
      conversation_drawer.dart   # 会话列表侧边栏（替换原 dialogs/conversation_drawer.dart）
    sections/
      status_bar.dart            # 单行状态栏（替换 hero.dart）
      input_bar.dart             # 输入区
      starter_prompts.dart       # 空会话快捷提问
      settings_sheet.dart        # 助手设置（迁移自 controls_sheet.dart + controls_panel.dart）
    shared/
      message_bubble.dart        # 单条消息气泡（简化后 < 200 行）
      user_message_bubble.dart   # 用户消息（可选拆分）
      assistant_message_bubble.dart # 助手消息（可选拆分）
      typing_indicator.dart      # 流式指示器
      proposal_card.dart         # 简化后的建议卡片
      context_menu.dart          # 消息上下文菜单（复用 FContextMenu）
```

### 拆分原则

- `page.dart` 只负责：订阅 `authSessionProvider`、判断登录态、渲染 `ChatShell`、处理路由返回。
- `chat_shell.dart` 负责：桌面 split-view vs 移动端 drawer 的响应式布局。
- `message_list.dart` 负责：订阅 `messages` 和 `streamingDraft`，管理 `ScrollController`，渲染空态。
- `input_bar.dart` 负责：输入框、发送、快捷键、空会话快捷提问、禁用态。
- `status_bar.dart` 负责：单行状态提示与展开面板。
- `conversation_drawer.dart` 负责：会话列表、分组、操作。
- `settings_sheet.dart` 负责：助手开关、记忆、上下文源（保持现有能力，入口更深）。

### 状态管理调整

- 保留 `AssistantController` 作为单一状态源，但减少页面级 `select` 数量。
- 子组件自行 `select` 需要的状态切片，例如 `message_list.dart` 只订阅 `messages` + `streamingDraft`。
- 将页面层内联的业务回调函数（`toggleAssistantEnabled`、`toggleContextSetting` 等）迁移到 `settings_sheet.dart` 内部通过 `ref.read` 直接调用 controller，或封装到小型 hook 中。

### 验收

- `page.dart` < 200 行。
- `message_list.dart` + `input_bar.dart` + `status_bar.dart` 各 < 250 行。
- 所有子组件可单独写 widget 测试。
- `flutter analyze` 与 `flutter test` 通过。

## 阶段 6：桌面端 split-view 与收尾（P2）

目标：桌面端提供常驻会话列表 + 聊天区，移动端保持抽屉。

### 具体改动

1. **`chat_shell.dart` 响应式布局**
   - 断点 `< Breakpoints.tablet`：使用 `FDrawer` 或 `showFSheet` 承载会话列表。
   - 断点 `>= Breakpoints.tablet`：左侧固定 280-320px 会话列表 + 右侧聊天区。
   - 参考 `DesktopTabShell` 和 Settings 主-从布局模式。

2. **`ResponsiveContentFrame` 移除或调整**
   - 聊天区不再使用 `FCard` 外壳，桌面端聊天内容区使用 max-width 720px 居中。
   - 移动端聊天内容区全宽（保留安全边距）。

3. **新增 widget 测试**
   - 测试空态展示快捷提问。
   - 测试消息气泡复制菜单。
   - 测试侧边栏分组与高亮。
   - 测试发送消息后输入框清空。

4. **文档更新**
   - 更新 `docs/00-current/Active_UI_Today.md` 中助手入口描述（如本重构改变了入口行为）。
   - 在 `docs/03-logs/migration-log/YYYY-MM-DD.md` 记录重构阶段完成条目。
   - 删除或归档本计划文件中已完成的部分（按项目规则，完成项删除，不保留标记）。

### 验收

- 桌面端 `>= 960px` 时，左侧会话列表常驻，右侧聊天区可滚动。
- 移动端侧边栏仍为抽屉，打开/关闭动画流畅。
- 新增 widget 测试覆盖率 ≥ 60%（针对重构后的 assistant presentation 层）。

## 实施顺序与依赖

```
阶段 1 ─┬──> 阶段 2 ──┬──> 阶段 3 ──┬──> 阶段 4 ──┬──> 阶段 5 ──┬──> 阶段 6
        │            │            │            │            │
        无后端依赖    无后端依赖    需会话删除/    无后端依赖    依赖阶段 1-4   依赖阶段 5
                                  重命名接口
```

建议按阶段独立提 PR，每阶段验证通过后再进入下一阶段。

## 文件改动清单

### 修改

- `lib/features/assistant/presentation/pages/page.dart` — 拆分为 shell。
- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart` — 拆分为 `message_list` + `input_bar`。
- `lib/features/assistant/presentation/widgets/sections/hero.dart` — 改为 `status_bar.dart` 或重命名。
- `lib/features/assistant/presentation/widgets/shared/message_bubble.dart` — 隐藏工具 chip、升级上下文菜单。
- `lib/features/assistant/presentation/widgets/shared/proposal_card.dart` — 删除元数据区。
- `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart` — 改为 `views/conversation_drawer.dart` 并增强。
- `lib/features/assistant/presentation/widgets/controls_sheet.dart` / `sections/controls_panel.dart` — 合并为 `sections/settings_sheet.dart`。
- `lib/l10n/src/assistant_zh.arb` / `assistant_en.arb` — 重写文案、删除不再使用的键。
- `lib/features/assistant/presentation/providers/conversation.dart` — 新增 `renameConversation` / `deleteConversation`（阶段 3）。
- `lib/features/assistant/domain/repositories/assistant.dart` / `data/repositories/lucent.dart` — 新增对应接口（阶段 3）。

### 新增

- `lib/features/assistant/presentation/widgets/chat_shell.dart`
- `lib/features/assistant/presentation/widgets/views/message_list.dart`
- `lib/features/assistant/presentation/widgets/sections/input_bar.dart`
- `lib/features/assistant/presentation/widgets/sections/starter_prompts.dart`
- `lib/features/assistant/presentation/widgets/sections/status_bar.dart`
- `lib/features/assistant/presentation/widgets/sections/settings_sheet.dart`
- `lib/features/assistant/presentation/widgets/shared/typing_indicator.dart`
- `lib/features/assistant/presentation/widgets/shared/context_menu.dart`
- `test/features/assistant/presentation/...` — 对应 widget 测试。

### 删除/归档

- 阶段 5 完成后可删除旧 `hero.dart`（若已完全替换）。
- 阶段 5 完成后可删除旧 `conversation_surface.dart`（若已拆分完毕）。
- 阶段 3 完成后可删除旧 `dialogs/conversation_drawer.dart`。

## 后端需新增接口（阶段 3）

| 方法 | 端点 | 用途 | 备注 |
|------|------|------|------|
| `DELETE` | `/api/v1/user/assistant/conversations/:conversationId` | 软删除历史会话 | 需新增 `deleted` status 或 `deletedAt` 字段 |
| `PATCH` | `/api/v1/user/assistant/conversations/:conversationId` | 重命名会话 title | body `{ title: string }`，仅允许 title |

实现建议：
- 优先使用软删除，保留 `archived` 语义不变。
- `listRecentSummaries` 默认过滤 `deleted`。
- 若选择硬删除，注意 `AssistantMessage` 外键级联删除。

## 验收标准总表

| 阶段 | 关键验收项 | 验证命令 |
|------|-----------|---------|
| 1 | 首屏无技术标签；`status_bar` 折叠态高度 ≤ 56dp | 手动截图 + `flutter analyze` |
| 2 | 输入框默认 1 行；消息气泡无工具 chip；复制菜单可用 | 手动测试 + widget 测试 |
| 3 | 侧边栏支持新建/切换/删除/重命名；历史分组正确 | 手动测试 + widget 测试 |
| 4 | 建议卡片不展示目标/定位/设置项/过期/约束；高度 ≤ 220dp | 手动截图 + widget 测试 |
| 5 | 页面文件 < 200 行；子组件 < 250 行；analyze/test 通过 | `flutter analyze` / `flutter test` |
| 6 | 桌面 split-view 常驻；移动端抽屉流畅；新增测试覆盖 ≥ 60% | `flutter test` + 多分辨率手动验证 |

## 风险与回退策略

1. **后端接口未就绪**：阶段 3 的删除/重命名可先 UI 占位 + 禁用，等后端接口 ready 后启用。
2. **空态文案变化导致测试失效**：widget 测试应使用 `Key` 而不是文案断言，避免文案微调导致测试失败。
3. **桌面 split-view 与 `DesktopTabShell` 冲突**：阶段 6 开始前先验证 `DesktopTabShell` 对非 shell 页面的支持，必要时只在小范围内使用 split-view。
4. **用户习惯已有"设置齿轮"入口**：阶段 1 将齿轮入口隐藏后，先在侧边栏/状态栏保留可发现路径，观察用户反馈再决定是否恢复顶部入口。

## 备注

- 本重构属于 `docs/00-current/Next_Plan.md` 中提到的 P3 "Assistant 嵌入式重构"，但用户反馈已将其提升为 Release Gate 后优先项。
- 实施过程中需持续遵循 [Product AI Design](../docs/01-product/Product_AI_Design.md) 的安全边界：AI 只负责解释、总结、提醒文案，不诊断、不开处方、不替代医生。
- 所有用户可见文案变更必须通过 ARB fragment 流程，禁止直接修改 `app_zh.arb` / `app_en.arb`。
