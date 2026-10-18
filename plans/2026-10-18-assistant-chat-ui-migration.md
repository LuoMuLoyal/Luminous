# Assistant 对话渲染框架迁移计划（flow_ui → flutter_gen_ai_chat_ui）

Created: 2026-10-18
Updated: 2026-10-18

> 状态：**P0 进行中**（U1 已证可解，U2/U3/U4 待验；分支 `feat/assistant-genai-ui`）。用户裁决：直接以 `flutter_gen_ai_chat_ui` 替换 `flow_ui`，落地 assistant 的
> 对话框 / 流式生成 / 工具调用 / 思考过程渲染。核心动机：`flow_ui` 0.x 单维护者、pub 数据低
> （28 likes / 749 下载），`flutter_gen_ai_chat_ui` 2.20.0 社区数据高一个量级（102 likes / 3.88k 下载）、
> MIT、活跃维护。**本计划不是纯升级：换包 = 重写适配层，且存在「两套 Material 库」的主题风险（见 §三 U1）；
> 已查证 gen_ai 尚未迁移到 `material_ui`，组件层落后于现有 flow_ui，P0 spike 必须先证明可接再动其余。**
>
> 涉及仓库：Luminous（主）。不涉及 Lucent——**后端契约（SSE chunk/result/done、capabilities、
> proposal confirm）不变**，本计划只换客户端渲染层。
>
> 标注约定：
> - **V（已验证）** = 已读本仓代码/依赖/文档确认的事实，执行时可照做；
> - **U（未验证）** = 需在 spike 或执行中确认，附验证方式。

---

## 一、目标与范围

### 目标

1. 用 `flutter_gen_ai_chat_ui`（下称 gen_ai）替换 `flow_ui`，承载 assistant 的：
   对话框、流式 token 生成动画、工具调用（工具来源条）、思考/加载态。
2. 保持既有**生产链路语义不变**：Lucent SSE（`core/network/client/sse.dart`）→
   `assistantControllerProvider` → proposal confirm/dismiss/regenerate → DataChangeBus。
3. 保持 Forui 设计系统 + ARB 本地化 + Riverpod 架构不变量。

### 范围内

- pubspec 依赖增删 + 生成物重生成（oss_licenses / build_runner / gen-l10n）。
- assistant `presentation/` 渲染层：adapter、主题桥、composer、消息列表、空态、欢迎区。
- 相关测试同步。

### 范围外（明确不做）

- **不采用 gen_ai 的 `AiActionProvider` / `AiAction` / HITL 确认系统**——这是客户端工具执行框架，
  与「Lucent 拥有模型与工具」冲突。工具/来源渲染继续用 assistant 自有的
  `AssistantSourceStrip`（Forui 原生），proposal 继续走 Lucent 的 `confirmProposals`。
- 不改动 `domain/`、`data/`、`application/` 层（`AssistantMessage` 等领域模型不动，只加映射）。
- 不用 `flow_ui` 之外的任何 provider 集成（gen_ai 是纯 UI，后端无关，符合要求）。
- 不 import `lib/core/ai`（实验 seam 边界不变）。

---

## 二、现状基线（V）

### V1. flow_ui 的集成面（9 个源文件 + 4 个测试）

| 文件 | 用到的 flow_ui 符号 | 迁移目标 |
| --- | --- | --- |
| `presentation/widgets/flowui_adapter.dart`（493 行） | `FlowMessageData`/`FlowMessagePart`/`FlowCustomPart`/`FlowTextPart`/`FlowMessage`/`FlowMessageStatus`/`FlowMessageRole`/`FlowMessageAction`/`FlowStreamingText`/`_AssistantReplyPanel` | → gen_ai `ChatMessage` + `customBubbleBuilder`/rich |
| `presentation/widgets/flow_theme_bridge.dart`（93 行） | `FlowTheme`/`FlowColors`/`FlowTypography` + `material_ui` 的 `Theme`/`Material` | → gen_ai `CustomThemeExtension`（需 framework Material 桥，见 U1） |
| `presentation/widgets/sections/composer_host.dart`（86 行） | `FlowComposer` | → gen_ai `InputOptions`（或保留自研输入） |
| `presentation/widgets/sections/page_body.dart`（308 行） | `FlowChatView` | → `AiChatWidget` |
| `presentation/widgets/views/conversation_message_list.dart`（125 行） | `FlowThread` | → `AiChatWidget` 的 thread / `MessageList` |
| `presentation/widgets/sections/empty_support.dart`（205 行） | `FlowSuggestionGroup`/`FlowSuggestion`/`FlowSuggestionLayout` | → gen_ai `ExampleQuestion`/`WelcomeMessageConfig` 或保留自研 |
| `presentation/widgets/sections/assistant_greeting.dart`（61 行） | `context.flowColors`/`context.flowTypography`（`FlowGreeting` 的 SVG 替代） | → 改用 Forui 语义 token，解除对 flow token 依赖 |
| `presentation/widgets/views/empty_conversation.dart`（64 行） | 仅注释引用 flow_ui（自研滚动安全空态） | 保留，改注释 |
| `presentation/pages/page.dart`（469 行） | 经 `withLuminousFlowTheme` 包裹 | → gen_ai 主题包裹 |

测试：`test/assistant/flowui_adapter_test.dart`、`flow_theme_bridge_test.dart`、`page_test.dart`、
`scroll_behavior_test.dart`。

### V2. 依赖与生成物

- `pubspec.yaml:91` `flow_ui: ^0.3.0`；`material_ui: ^1.6.0`（`pubspec.yaml:96`）为 flow_ui 0.3.0 的运行依赖，
  且**应用根就是 `material_ui` 的 `MaterialApp.router`**（`lib/app/bootstrap.dart:27,134`）。
- gen_ai 传入依赖：`flutter_markdown_plus`（已有）、`url_launcher`（已有）、`clock`（已有）、
  `google_fonts`、`flutter_math_fork`、`flutter_streaming_text_markdown`、`markdown`（新增）。
- `lib/oss_licenses.dart` 由 `scripts/contract/bootstrap.dart:493` 的
  `dart_pubspec_licenses:generate` 生成 → 换依赖后必须重跑 bootstrap。

### V3. 生产链路（本计划不改，仅作对接锚点）

- SSE 事件：chunk / result / error / done（`features/assistant/domain/repositories/assistant.dart`）。
- 状态：`assistantControllerProvider`（`presentation/providers/conversation.dart`）持有
  `messages` / `streamingDraft` / `isSending` / `lastFailedInput` / capabilities / recent conversations。
- `streamingDraft` 与已落库 `messages` 分离；发送失败保留 `lastFailedInput`。

### V4. gen_ai 包 API（据 pub.dev 2.20.0 README，V=文档确认）

关键入口：`AiChatWidget(currentUser, aiUser, controller: ChatMessagesController, onSendMessage, …)`；
`ChatMessagesController.addMessage/updateMessage/stopStreamingMessage`；
`ChatMessage.text/.rich/.widget/.loading`（`customProperties: {'id','isStreaming','isStartOfResponse','responseId'}`）；
`MessageOptions(bubbleBuilder, customBubbleBuilder, enableSyntaxHighlighting, codeBlockTheme, showCodeBlockCopyButton)`；
`InputOptions(.minimal/.glassmorphic/.custom, autofocus, focusNode, sendOnEnter, cancelButtonBuilder, sendOrMicBuilder, inputLeadingBuilder)`；
`LoadingConfig(isLoading, showCenteredIndicator)`；`onCancelGenerating`；
`ScrollBehaviorConfig(autoScrollBehavior, scrollToFirstResponseMessage, pinDuringStreaming)`；
`CustomThemeExtension.chatgpt()/.claude()/.gemini()/.modern(colorScheme)/.minimal(colorScheme)`；
`WelcomeMessageConfig` / `ExampleQuestion`。

---

## 三、未验证风险（U）

### U1. 两套 Material 库的主题解析（最高风险，P0 必须先过）

**已查证（V，2026-10-18，pub.dev 2.20.0 元数据 + changelog）：gen_ai 未迁移到 `material_ui`。**
它的依赖是 `flutter` / `flutter_markdown_plus` / `flutter_streaming_text_markdown` / `google_fonts` /
`flutter_math_fork` / `markdown` / `url_launcher` / `clock`，**不含 `material_ui`**，即仍建在
`package:flutter/material.dart`（framework）上；其 changelog 2.13→2.20 无 design-widgets 迁移记录。

本仓应用根是 `material_ui` 的 `MaterialApp.router`（`bootstrap.dart:134`）；`flow_theme_bridge.dart:8-23`
的注释记录了一个已发生的事实：**framework（`package:flutter/material.dart`）的 `Theme.of` 与 material_ui 的
`Theme` 不是同一个对象**——framework `Theme.of(context).brightness` 在生产里恒为 light。

→ 由此：**flow_ui 比 gen_ai 更靠前**（flow_ui 0.2.0 已 `dart fix --code=migrate_design_widgets` 迁到
material_ui；本仓根切到 material_ui 正是为此）。换到 gen_ai 等于**在组件层倒退一个平台迁移**。

**已证（V，2026-10-18，P0 spike `test/assistant/genai_spike_test.dart`，headless widget test）：接得上，但主题不自动跟随。**

- **不会崩**：无论有无 wrapper，gen_ai 在 `material_ui` 根下都**未抛** `No Material widget found`
  （含空态、含 user/assistant 消息 + composer 输入框三种情形）。gen_ai 输入框用 framework `TextField`，
  不依赖 framework `Material` 墨迹祖先。
- **主题不跟随（核心发现）**：`material_ui` 根的 `MaterialApp` 内部**确实装了** framework `Theme`，但其值为
  **framework Material3 默认**——实测 `brightness=light`、`primary=#6750A4`、`useMaterial3=true`，**不是**
  App 的 Forui/material_ui 主题。即 gen_ai 直接放进去会渲染成默认 Material 配色，且 `brightness` 恒为 light
  （与 `flow_theme_bridge.dart:8-23` 既有注释一致）。
- **解法可行**：子树内装一层 framework `Theme(data: ThemeData(...))` 后，framework `Theme.of` 即取到注入的
  `ThemeData`（seed 派生的 `colorScheme` 实测可读到）。`Material` wrapper 未必需（未崩），保留以防御 ink 组件。

→ 命名结论：**U1 可解**。代价是 assistant 子树内**并存两套 Material**：根是 material_ui，assistant 内叠 framework
`Theme`/`Material`；主题桥从「FlowTheme→material_ui」改成「Forui→framework `ThemeData`」，且**必须显式设
`brightness`/`colorScheme`**（不能靠继承，继承恒为 M3 默认浅色）。`CustomThemeExtension` 应挂在这层
framework `ThemeData.extensions` 上。

### U2. 流式动画 vs SSE 分片

gen_ai 的 `enableMarkdownStreaming`+`streamingWordByWord` 是**本地二次逐字动画**（你推最终文本，它再逐字揭示），
而本仓是**真流式**（chunk 分片到达）。两者叠加可能造成"流式 + 再动画"的双重延迟/抖动。

- **已证（API 面，V）**：gen_ai 提供 `addStreamingMessage` → `updateMessage` → `stopStreamingMessage` 的流生命周期
  （`chat_messages_controller.dart`），与 SSE 的分片/收尾天然对齐；`AiChatWidget` 暴露
  `enableMarkdownStreaming` / `streamingWordByWord` / `enableAnimation` / `streamingDuration` 可关本地动画。
- **决策**：SSE 分片累积后 `updateMessage`，并**关掉**本地逐字动画（`streamingWordByWord: false`；必要时
  `enableAnimation: false`），只保留 markdown 渐进渲染——避免"流式 + 再动画"的双重延迟。当前 `flowui_adapter`
  做法相反（流式中关 markdown），需对照重定。净观感留 P1 demo 定夺（此项 P1 复验）。

### U3. 思考态渲染

flow_ui 有 `FlowThinkingIndicator` + `thinkingLabel`（本仓用 `assistantThinkingLabel`）；
gen_ai 的对应物是 typing indicator / `LoadingConfig`。

- **已证（API 面，V）**：`chrome/thinking_indicator.dart` 的 `ThinkingIndicator` **无文案参数**，但同文件
  `ChatLoadingBars({caption})` **带 caption**——即"带文案的思考指示器"用 `ChatLoadingBars(caption: <l10n>)` 即可，
  不必自研。现有 `assistantThinkingLabel` 文案可原样接上。
- **决策**：thinking 态用 `ChatLoadingBars(caption: assistantThinkingLabel)`（或经 `messageOptions`
  的 custom builder 挂到气泡上方），保持现有 l10n 文案不丢。

### U4. 输入框与停止生成

现 `composer_host.dart` 用 `FlowComposer`（`isStreaming:false`，非流式门控在 controller）。
gen_ai 的 `InputOptions` 有 send/stop 切换与 `onCancelGenerating`，但本仓**当前不支持中途停止**（`isSending` 期间禁用）。

- **已证（API 面，V）**：`chat_input.dart` 在 `widget.isGenerating && onCancelGenerating != null` 时把 send 按钮换成
  stop 按钮，并支持 Esc 取消；`isGenerating` 由 `LoadingConfig(isLoading: ...)` 驱动——本仓的 `isSending` 可直接喂入。
- **决策**：stop 按钮可零成本接上（`LoadingConfig(isLoading: isSending)` + `onCancelGenerating`）；但**真正取消
  in-flight SSE 需在 controller 增能力**，超出"只换渲染层"。→ **拆分为后续任务**：本计划 P1 先落 UI 骨架
  （按钮/门控），取消 SSE 作为独立 TODO，不在本计划阻塞。

### U5. 空态与滚动

- `empty_conversation.dart` 的注释指出 flow_ui 的 empty 分支在键盘弹起时会溢出（实测 224px），故本仓自研空态。
  gen_ai 的 `welcomeMessageConfig` 是否有同类溢出问题未知；倾向**保留自研空态**，仅把 starter 提示从
  `FlowSuggestionGroup` 换掉。
- `scroll_behavior_test.dart` 断言现有滚动行为；gen_ai 的 `ScrollBehaviorConfig`/`pinDuringStreaming` 语义不同，
  测试需重写。

### U6. gen_ai 自带依赖与设计冲突

- 新增 `google_fonts`（flow_ui 也用过，但已从 pubspec 移除？——**待核**：flow_ui 0.3.0 依赖含 google_fonts，
  但本仓 `flutter_theme_bridge` 用 `FlowTypography...withFontFamily`）与 `flutter_math_fork`；
  需确认不与应用字体策略冲突，且 `google_fonts` 运行时抓字体需网络权限（Android INTERNET / macOS network client）。
- gen_ai 主题基于 Material `ColorScheme`，与 Forui 视觉体系需逐 token 对齐，观感可能回退，需 golden 校验。

### U7. 包成熟度的真实成本

gen_ai 虽社区数据高，但仍有明确短板：单一发布者（dilacode.com）、v2.x、无团队背书，且**组件层尚未跟上
Flutter 的 material_ui 迁移**（U1 已查证）——即它比现有 flow_ui 落后一个平台迁移。**换包后如仍不满意，
再换回的成本同样高**（adapter 再重写一次）。→ 本计划要求 P0 spike 先验证"接得上、观感可接受"，否则**中止**（见回退预案）。

---

## 四、领域模型 → gen_ai 映射（设计锚点）

`AssistantMessage`（`domain/entities/models.dart:331`）→ gen_ai `ChatMessage`。gen_ai 的消息模型是
「字符串 + 可选 widget」结构扁平，本仓消息带富语义，故**富内容一律经 `customBubbleBuilder` / `ChatMessage.rich` 自渲染**，
不塞进 gen_ai 的文本管线：

| 领域字段 / 部件 | flow_ui 现做法 | gen_ai 目标做法 |
| --- | --- | --- |
| `content`（assistant 文本） | `FlowCustomPart('markdown')` + `MarkdownBody` | gen_ai 默认 markdown 渲染（内部用 `flutter_markdown_plus`） |
| `usedTools` + `toolDetails` | `AssistantSourceStrip` 塞进 `FlowMessage.footer` | 保留 `AssistantSourceStrip`，放进 `customBubbleBuilder` 的尾部槽 |
| `proposedActions` | `FlowCustomPart('proposal')` → `AssistantProposalCard` | `AssistantProposalCard` 保持 Forui，放进 `customBubbleBuilder` |
| `replaced`（旧回答灰态） | `Opacity(0.55)` + `_ReplacedBadge` | 同左，移入 `customBubbleBuilder` |
| 免责声明 `AssistantDisclaimerBar` | footer 内 | 保留，放进 `customBubbleBuilder` |
| 复制/重新生成/重发动作 | `FlowMessageAction` | gen_ai 内置 copy/regenerate 或自渲染动作行（保持 l10n key 不变） |
| `streamingDraft`（真流式） | `FlowStreamingText`（流式中关 markdown） | `addMessage(isStreaming:true)` → 逐 chunk `updateMessage` → `stopStreamingMessage`（U2） |
| `isSending && draft 空`（pending） | `FlowMessageStatus.pending` | `ChatMessage.loading()` 或 `LoadingConfig(isLoading:true)` |
| 思考文案 `assistantThinkingLabel` | `FlowThinkingIndicator.thinkingLabel` | 自研 thinking 行（U3） |

**不变量**：`messageIdFor`（`presentation/utils/message_id.dart`）继续是 canonical id；
gen_ai 的列表身份用 `customProperties['id']` = flow 身份（`$conversationId:$index:$canonical`），与领域 id 解耦，规则照旧。

---

## 五、执行步骤（分阶段，P0 可中止）

### P0. 前置 spike（去风险，**不落地 main**）

1. 新建临时分支，`flutter pub add flutter_gen_ai_chat_ui`（与 flow_ui 短期并存，便于对照）。【已做】
2. 做一个 `AiChatWidget` 最小页面，**逐条验证 §三**：U1（主题/Material 祖先）、U2（流式动画观感）、
   U3（思考态）、U4（停止生成）、U6（字体/主题观感）。
3. 用真实 `assistantControllerProvider` 的 SSE 流灌入 gen_ai controller（三条事件），确认端到端渲染。
4. **裁决门**：U1 不可解 / 观感明显差于现 flow_ui / 停止生成需要大改 controller → **中止本计划**，
   记录结论、删除本 spike、保留 flow_ui（见 §七 回退）。
5. 通过则继续 P1。

**P0 结果（V，2026-10-18）：裁决 = GO（继续 P1）。**
- U1（主题）：**可解**，headless widget test 已证不崩 + framework `Theme` 桥接生效；代价是子树内两套 Material 并存 +
  必须显式设 `brightness`/`colorScheme`（详见 §三 U1）。**未落地的纯观感项**（U6 字体/圆角度）、U2 净观感、以及
  步骤 3 的「真实 SSE 端到端灌流」顺延到 P1 demo 一并核。
- U2/U3/U4：**API 面均接得上**（流生命周期 / `ChatLoadingBars(caption:)` / `onCancelGenerating`）；U4 的
  「真正取消 SSE」单独拆为后续任务，不阻塞本计划。
- spike 产物：`test/assistant/genai_spike_test.dart`（临时，P1 落地后删除）。

### P1. 依赖与生成物

6. `pubspec.yaml`：移除 `flow_ui`；新增 `flutter_gen_ai_chat_ui: ^2.20.0`；`flutter pub get`。
   - 逐一核对传递依赖是否已存在（`flutter_markdown_plus`/`url_launcher`/`clock` 已有，避免重复声明）。
7. `dart run scripts/contract/bootstrap.dart`（重生成 `lib/oss_licenses.dart` + build_runner + gen-l10n）。

### P2. 主题桥

8. 新增 `presentation/widgets/` 下的 gen_ai 主题桥（替换 `flow_theme_bridge.dart`）：
   依 U1 结论决定目标 `ThemeData` 归属；用 `CustomThemeExtension`（`.modern(色板)` 或手写）把
   `SemanticColor` / Forui token 映射进去；保留「仅包裹 assistant 子树 + 透明 `Material` 祖先」的结构。
9. `page.dart` 把 `withLuminousFlowTheme` 换成新的主题包裹；删除 `flow_theme_bridge.dart`。

### P3. 消息渲染适配层

10. 以 `flowui_adapter.dart` 为蓝本写 gen_ai adapter（新文件名，遵循命名规则，如
    `presentation/widgets/chat_adapter.dart`）：`mapMessages` / `mapMessage` / 流式草稿映射 /
    `customBubbleBuilder`（富内容按 §四 表）。删除 `flowui_adapter.dart`。
11. `conversation_message_list.dart`：`FlowThread` → gen_ai 列表；`page_body.dart`：`FlowChatView` → `AiChatWidget`。

### P4. 流式 / 发送 / 思考

12. 发送：`handleSend` → gen_ai `onSendMessage`；把 `streamingDraft` 的每次变更（`ref.listen`）桥接到
    `ChatMessagesController.updateMessage`（稳定 id + `isStreaming`），done → `stopStreamingMessage`。
13. pending（`isSending && draft 空`）→ `ChatMessage.loading()` / `LoadingConfig`。
14. 思考态与停止生成按 U3/U4 结论落地（若纳入停止生成，需在 `conversation.dart` 增取消 SSE 能力——
    这是**唯一可能触及非渲染层**的点，需单独小节记录）。

### P5. 输入 / 空态 / 滚动

15. `composer_host.dart`：`FlowComposer` → gen_ai `InputOptions`（保留 `enabled` 门控、`assistant-input` key、
    l10n 占位符）。
16. `empty_support.dart`：`FlowSuggestionGroup` → gen_ai `ExampleQuestion`/自研列表（U5）；
    `empty_conversation.dart` 自研滚动安全结构**保留**。
17. `assistant_greeting.dart`：解除 `context.flowColors`/`flowTypography`，改 Forui 语义 token。
18. `scroll_behavior_test.dart` 按 gen_ai `ScrollBehaviorConfig`/`pinDuringStreaming` 语义重写。

### P6. 测试与校验

19. 删除 `flowui_adapter_test.dart`、`flow_theme_bridge_test.dart`，补 gen_ai adapter / 主题桥测试
    （镜像源文件命名）。
20. `page_test.dart` 断言同步（组件树/主题包裹变化）。
21. 宽检查：`flutter analyze`、`flutter test`、`dart run scripts/workflows/daily.dart`、
    `tool/luminous_lints` 扫描。

### P7. 文档与日志

22. `features/assistant/README.md` 重写 flow_ui 相关描述（渲染经 gen_ai、接缝在新 adapter、主题桥归属）。
23. `docs/explanation/iconmind-assistant-icons.md`、`docs/explanation/motion-hierarchy.md` 中引用 flow_ui 的段落同步。
24. `docs/reference/generated/features.md` 等由 `dart run scripts/docs/generate.dart` 重生成。
25. 若可见文案/l10n key 有增减：`lib/l10n/src/` 改分片 → `dart scripts/l10n/arb_tools.dart merge` →
    `flutter gen-l10n`，并同步 `docs/reference/localization.md`。
26. `docs/logs/migration-log/2026-10-18.md` **追加**（不覆盖）本次变更范围与验证结论。
27. 全部完成并验证后：删除本计划文件，更新 `plans/README.md` 的「Current Plans」索引。

---

## 六、验收标准

| 项 | 验收 |
| --- | --- |
| P0 裁决 | §三 U1~U7 各条有明确结论；不通过则已中止并记录 |
| 依赖 | `flow_ui` 从 pubspec 与 lock 移除；无重复传递依赖声明 |
| 生成物 | `bootstrap.dart` 后 `oss_licenses.dart` 反映新依赖（含 gen_ai），无手改生成文件 |
| 功能等价 | 流式问答 / 重新生成 / proposal 确认·拒绝·重生成 / 失败重发 / 会话抽屉 全链路与迁移前一致 |
| 富渲染 | 来源条 / proposal 卡 / 旧回答灰态 / 免责声明 均按 `customBubbleBuilder` 正常渲染 |
| 主题 | 深浅色下颜色正确（对照 U1）；无 Material 祖先缺失/主题串色 |
| l10n | 无硬编码文案；`assistant*` key 全部经 ARB |
| 测试 | `flutter test` 全绿；flow_ui 专属测试已替换 |
| 架构 | 不 import `lib/core/ai`；跨 feature 规则不破坏；`layered_import` 无新增违规 |
| 文档 | README / explanation / generated / approval 同步；迁移日志已追加 |

---

## 七、风险与回退预案

1. **P0 不通过（U1 主题不可解 / 观感明显退步）**：中止计划，回退到 spike 前（删除分支），
   保留 flow_ui，并在迁移日志与 `docs/TODO.md` 记录「flow_ui 暂留 + 触发条件」。
2. **换包后仍不满意**：承认「成熟 ≠ 适配」——gen_ai 重于 flow_ui、Material 原生，
   再次换包成本等同。届时优先**fork flow_ui（MIT）自维护**而非继续换第三方。
3. **净增依赖风险**（`google_fonts`/`flutter_math_fork`）：若与应用字体/体积策略冲突，
   评估 `dependency_overrides` 或裁剪（gen_ai 的 markdown/代码高亮是否可关）。
4. **停止生成需改 controller**（U4）：超出「只换渲染层」范围时，单独拆为后续任务，
   不阻塞主迁移。
5. **回退触发线**：任一硬阻塞（U1 不可解、端到端功能不等价）→ 保留 migration 分支为 WIP，
   `main` 不合并；flow_ui 版本始终可用。

---

## 备注

- 本计划与 `2026-08-14-flutter-3.47-upgrade-plan.md` 无耦合；但 3.47 升级计划备注提到
  「in-SDK `material_ui`/`cupertino_ui` 库 11 月起弃用」，可能影响 U1 的长期走向，执行时一并观察。
- `material_ui` 是否因移除 flow_ui 而有其他消费者需核查（`bootstrap.dart` / `theme_extension.dart` /
  `theme/family.dart` / `theme/preference.dart` / `reminder/form_body.dart` 直接 import 它，
  与应用根绑定，**不能随 flow_ui 一起删**）。
