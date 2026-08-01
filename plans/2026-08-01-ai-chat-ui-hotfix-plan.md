# AI 对话页 UI 热修计划

Created: 2026-08-01
Updated: 2026-08-01

状态：待实施

## 背景

当前 `/assistant` 页面存在若干直接影响用户使用的 UI 与交互问题，需要一次聚焦的热修复。本计划不替换 [AI Chat Redesign](2026-08-01-ai-chat-redesign.md) 的大重构路线，而是先解决最影响首屏体验的阻塞性问题。

## 问题清单

### 1. 盒子套盒子（首屏布局层级过深）

**现象**：聊天区域被多层容器包裹——`PageScaffold` → `ResponsiveContentFrame` → `Padding` → `Column` → `AssistantConversationStack` → `FCard` → `Padding` → `Column` → 消息列表。移动端首屏被边框和大段留白挤压，不像沉浸式聊天界面。

**截图对应**：第一张截图中可见输入区、空态提示、快捷提问都被限制在一个带圆角/底色的卡片内，四周留白过大。

**根因代码**：

- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart:60-63` — `FCard` + `Padding(Spacing.level5)` 作为聊天区外壳。
- `lib/features/assistant/presentation/widgets/sections/page_body.dart:117-123` — `ResponsiveContentFrame` + 外层 `Padding` + `Column`。

**期望**：

- 移除聊天区外层 `FCard`，改用背景色或透明背景。
- 移动端消息气泡接近屏幕边缘（保留安全边距），桌面端使用 max-width 居中。
- `PageScaffold` 内部不再套多层 `Padding`/`Column` 限高。

### 2. 设置弹窗 padding 与背景需调整

**现象**：点击右上角设置后弹出的弹窗（sheet）顶部标题与内容拥挤，背景没有正确遮挡下方内容，视觉上像浮在界面之上的一层半透明白板，且边缘与下方圆角卡片错位。

**截图对应**：第二张截图中 "Assistant settings" 弹窗右侧/顶部留白不均，标题 "Current status" 与关闭按钮间距过小。

**根因代码**：

- `lib/features/assistant/presentation/widgets/controls_sheet.dart:42-46` — `SizedBox(width)` + `SafeArea` + `Padding(Spacing.level5)`，未使用 Forui 的 `FSheet` 语义化布局。
- `lib/features/assistant/presentation/widgets/sections/controls_panel.dart` — 内部 tile 缺少上下间距与分隔。

**期望**：

- 弹窗使用项目统一的 sheet/dialog 规范（参考 `FSheet`/`FDialog` 或 `showModalBottomSheet` 的默认 padding）。
- 标题区与内容区间距统一为 `Spacing.level4`。
- 背景遮罩使用 `FThemeData.colorScheme.background` 或 `barrierColor`，确保底层内容被压暗。
- 移动端弹窗宽度改为 `MediaQuery.width * 0.92` 并保留底部安全区，桌面端固定 400px。

### 3. 选择会话历史应为抽屉式侧边栏，而非弹窗

**现象**：当前点击"历史会话"图标从右侧弹出一个 `showFSheet` 侧边栏，本质仍是弹窗，没有真正抽屉的进入动画与手势返回体验，且与设置弹窗在视觉上叠加混乱。

**根因代码**：

- `lib/features/assistant/presentation/pages/page.dart:109-135` — `openRecentConversationsDrawer()` 使用 `showFSheet` 从 `FLayout.rtl` 弹出。
- `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart` — 当前实现本质是 `SizedBox` 套 `Padding`，不是 `Drawer`。

**期望**：

- 使用 `Drawer`（或 Forui 的 `FDrawer`）承载会话历史，从左侧或右侧滑出。
- 保留手势返回与遮罩点击关闭。
- 在桌面端（`>= Breakpoints.tablet`）改为常驻侧边栏 split-view（与现有大重构计划阶段 6 一致，热修阶段可先只改抽屉）。

### 4. 点击加号（新建会话）后端报错 400

**现象**：用户点击顶部 "+"（新建会话）按钮后，后端收到请求并返回：

```text
2026-08-01 16:33:27.188 warn [ApiExceptionFilter] Handled exception: Unexpected end of JSON input [POST /api/v1/user/assistant/latest/clear 400]
```

**根因**：

- 前端调用 `assistantControllerClearLatestConversationV1()` 时，生成代码未设置 `contentType: 'application/json'`，也未发送请求体（`data` 参数缺失）。
- Lucent 后端 `POST /api/v1/user/assistant/latest/clear` 期望解析 JSON body（可能是空对象 `{}`），收到无 body 的 POST 后解析失败，抛出 `Unexpected end of JSON input`。

**相关代码**：

- `Luminous/generated/lucent_api/lib/src/api/assistant_api.dart:38-61` — `assistantControllerClearLatestConversationV1` 方法中无 `contentType`，无 `_bodyData`。
- `Luminous/lib/features/assistant/presentation/providers/conversation.dart:342-368` — `clearConversation()` 调用仓库方法。
- `Luminous/lib/features/assistant/presentation/pages/page.dart:78-81` — 加号按钮触发 `handleStartNewConversation()` → `clearConversation()`。

**期望**：

- 修复 OpenAPI 生成或 dio 调用，使 `clearLatestConversation` 发送 `Content-Type: application/json` 与空 body `{}`。
- 临时方案（如无法立即重新生成 client）：在 datasource 层手动包装请求，显式传入 `data: '{}'` 与对应 headers。
- 后端如确实不需要 body，应允许空 body 或改为 `POST` 无 body；但热修阶段优先让前端符合后端当前契约。

## 实施步骤

### 步骤 1：修复后端 400 错误（最高优先级）

1. 在 `Luminous/lib/features/assistant/data/datasources/assistant.dart:64-67` 临时绕过生成代码，显式使用 dio 发送带 `Content-Type: application/json` 与空 `{}` body 的 POST 请求。
2. 或检查 Lucent OpenAPI 定义，确认 `/latest/clear` 是否缺少 body schema；若缺失，补充 body schema 后重新生成 `generated/lucent_api`。
3. 验证：点击加号后不再出现 400，且当前会话被正确归档。

### 步骤 2：移除盒子套盒子

1. 修改 `lib/features/assistant/presentation/widgets/views/conversation_surface.dart`：
   - 移除外层 `FCard`。
   - 将 `Padding(Spacing.level5)` 改为 `EdgeInsets.symmetric(horizontal: Spacing.level3)` 或零 padding（由父级统一控制）。
2. 修改 `lib/features/assistant/presentation/widgets/sections/page_body.dart`：
   - 保留 `PageScaffold` 和 `ResponsiveContentFrame`，但减少内部嵌套 `Padding`。
   - 将 `AssistantStatusBar` 与 `AssistantConversationStack` 之间的 `SizedBox` 高度从 `Spacing.level4` 调整为 `Spacing.level3`。
3. 验证：首屏消息/输入区占比提升，移动端不再有厚重卡片边框。

### 步骤 3：调整设置弹窗

1. 修改 `lib/features/assistant/presentation/widgets/controls_sheet.dart`：
   - 宽度：移动端 `MediaQuery.width * 0.92`，桌面端 400。
   - `Padding` 改为 `EdgeInsets.fromLTRB(Spacing.level5, Spacing.level4, Spacing.level5, Spacing.level4)`，底部额外加 `MediaQuery.padding.bottom`。
2. 修改 `lib/features/assistant/presentation/widgets/sections/controls_panel.dart`：
   - 每个 tile 之间增加 `SizedBox(height: Spacing.level3)`。
   - 标题与第一个 tile 之间增加 `SizedBox(height: Spacing.level4)`。
3. 验证：设置弹窗打开后标题、开关、关闭按钮间距舒适，背景正确压暗底层内容。

### 步骤 4：会话历史改为抽屉

1. 修改 `lib/features/assistant/presentation/pages/page.dart`：
   - 将 `showFSheet` 替换为 `Scaffold.of(context).openEndDrawer()` 或 `showFDrawer`。
2. 新建/修改 `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart`：
   - 改为返回 `Drawer` widget，内部保持现有 header/list 结构。
   - 宽度逻辑保留：移动端 85%，桌面端 320px。
3. 在 `AssistantPageBody` 的 `PageScaffold` 中注入 `endDrawer: AssistantConversationDrawer(...)`，避免嵌套弹窗。
4. 验证：历史会话从右侧/左侧滑出，可手势关闭，不再与设置弹窗叠加。

## 验收标准

- [ ] 点击顶部 "+" 不再触发后端 400，`/api/v1/user/assistant/latest/clear` 返回 200/201。
- [ ] 首屏聊天区域不再被厚重 `FCard` 包裹，移动端上下留白 ≤ 16dp。
- [ ] 设置弹窗 padding 统一，背景遮罩正常，标题与开关间距清晰。
- [ ] 会话历史以抽屉形式出现，支持点击遮罩或手势关闭。
- [ ] `flutter analyze` 通过，无新增 lint 错误。
- [ ] 在 `docs/03-logs/migration-log/2026-08-01.md` 追加本次热修记录（按 AGENTS.md 规则）。

## 风险与回退

- **生成代码回写风险**：`generated/lucent_api` 是自动生成文件，手动绕过只是临时方案，最终应通过 OpenAPI 修正后重新生成。热修阶段需注释说明临时性。
- **抽屉与 split-view 冲突**：本次热修只做移动端抽屉；桌面端 split-view 保留在大重构阶段 6 实施，避免一次改动过大。
- **FCard 移除影响暗色主题**：移除 `FCard` 后需确保 `PageScaffold` 背景色在暗色/亮色主题下均正确，必要时给聊天区显式 `Container(color: colors.background)`。

## 相关文档

- [AI Chat Redesign](2026-08-01-ai-chat-redesign.md) — 大重构主规划。
- [AI Chat Redesign Plan](2026-08-01-ai-chat-redesign-plan.md) — 分阶段实施方案。
- [AI Chat Redesign Problems](2026-08-01-ai-chat-redesign-problems.md) — 问题清单。
- `lib/features/assistant/presentation/pages/page.dart`
- `lib/features/assistant/presentation/widgets/sections/page_body.dart`
- `lib/features/assistant/presentation/widgets/views/conversation_surface.dart`
- `lib/features/assistant/presentation/widgets/controls_sheet.dart`
- `lib/features/assistant/presentation/widgets/dialogs/conversation_drawer.dart`
- `lib/features/assistant/data/datasources/assistant.dart`
- `generated/lucent_api/lib/src/api/assistant_api.dart`
