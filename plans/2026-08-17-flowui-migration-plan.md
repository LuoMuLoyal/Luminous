# Assistant 页面 FlowUI 迁移计划

Created: 2026-08-17

> 评估结论：**条件通过**。用 [flow_ui](https://github.com/StacDev/flow_ui) (v0.1.0, MIT)
> 替换移动端 assistant 页面约 80% 的手写聊天 UI。无 Lucent 后端改动；Android/iOS 是唯一
> 验收目标，桌面端不做视觉、键盘或布局验收。

## 一、目标与范围

### 目标

将 `Luminous/lib/features/assistant/presentation/` 下手写的聊天 UI 组件替换为
flow_ui 组件，减少维护面并获取专业级聊天交互（streaming 动画、thinking 指示器、
jump-to-latest、suggestion chips 等）。

### 范围

- **改**：`presentation/pages/page.dart`、`presentation/widgets/sections/page_body.dart`、
  `presentation/widgets/views/`（conversation_stack / conversation_surface / conversation_message_list）、
  `presentation/widgets/sections/input_bar.dart`、`input_bar_shortcut_hint.dart`、
  `input_bar_starter_prompts.dart`、`presentation/widgets/sections/welcome_panel.dart`、
  `presentation/widgets/shared/message_bubble.dart`、`presentation/widgets/shared/loading_view.dart`。
- **保留为 adapter/custom part**：`proposal_card.dart`（HITL 提案卡，通过 `FlowCustomPart` 注入）、
  `chips.dart`（`AssistantToolChip`，复用于提案卡内）。
- **保留手写**：`conversation_drawer.dart` 及子组件（FlowUI Side Panel 在 Roadmap 中为 Planned，
  暂无替代品）、`status_bar.dart`/`controls_panel.dart`/`controls_sheet*.dart`（已归档/实验性，不在迁移面）。
- **新增**：`FlowTheme` 桥接层（`lib/features/assistant/presentation/widgets/flow_theme_bridge.dart`）
  及仅负责 view-model 映射与 message builder 的 adapter；其不改变 domain entity、repository
  或 Lucent SSE 协议。
- **保留状态机**：`AssistantController` 不新增取消能力。由于现有流式请求不可取消，迁移后
  不将 `isSending` 映射为 `FlowComposer.isStreaming`，而是在发送期间禁用 composer。
- **平台资源**：FlowUI 内部使用 Material Icons；在 `pubspec.yaml` 启用
  `uses-material-design: true` 以打包图标字体。此为 Flutter 资源配置变更，不恢复 Material
  widget 体系，也不扩展桌面端范围。

### 范围外

- 不在本次迁移中引入 `FlowModelSelector` / `FlowAttachmentGroup` / `FlowAttachmentPreview`
  / `FlowMenu` / `FlowShimmerText`——当前 assistant 无多模型选择和附件功能，保留为未来扩展。
- 不替换 `ConversationDrawer`——等 FlowUI Side Panel 发货后再评估。
- 不改 Forui-first 方向——FlowUI 作为 assistant 域内局部组件库引入，不推广到其他 feature。
- 不为桌面端保留 Ctrl/Cmd+Enter 提示或增加键盘行为验收；移动端沿用软键盘换行和发送按钮。

## 二、兼容性分析

### 通过理由

| 维度 | 分析 |
|------|------|
| **架构兼容** | `FlowChatScreen` 是 body-only（不建 Scaffold、不建 AppBar），与 Luminous 的 `PageScaffold` + `ResponsiveContentFrame` 完全共存 |
| **状态模型兼容** | FlowUI 的消息是纯 view model（`FlowMessageData`），与 `AssistantMessage` 分离干净，映射为 adapter 函数 |
| **流式兼容** | `streamingDraft` 映射为唯一的 pending/streaming `FlowMessageData`；完成后以 Markdown custom part 重建为静态消息 |
| **扩展点兼容** | `FlowCustomPart` + `customPartBuilder` 是注入 `AssistantProposalCard` 的自然 seam，无需 fork 消息渲染器 |
| **l10n 兼容** | FlowUI 的可见 strings 由 host 传入；placeholder、thinking、jump-to-latest 和消息操作 tooltip 全部复用或新增 Luminous ARB |
| **Forui 共存** | FlowUI 不依赖 Forui，也不与之冲突；Forui 组件（`FButton` 等）在 `FlowMessage` 内部仍正常渲染，因为 Forui 组件不要求 `FTheme` 祖先链 |
| **M3 独立** | FlowUI 的 `FlowTheme` 是独立 `ThemeExtension`，虽角色名跟随 M3 命名，但不依赖 M3 `ColorScheme`。与 `docs/02-reference/Design_System.md` 的 Forui-first 方向不冲突 |

### 风险与缓解

| 风险 | 等级 | 缓解措施 |
|------|------|---------|
| **pre-1.0 API 不稳定** | 中 | pin minor version (`flow_ui: ^0.1.0`)，读 changelog 升级，写 1-2 个 widget 测试覆盖核心 adapter |
| **Figtree 字体冲突** | 低 | 用 `FlowTypography.standard.withFontFamily(...)` 覆盖为 Luminous 现有字体 |
| **双 theme 系统** | 中 | 新建 `flow_theme_bridge.dart`，在 assistant 页面入口注入 `FlowTheme`，从 `SemanticColor` / `TypographyToken` 派生 `FlowColors` / `FlowTypography` |
| **jump-to-latest 替换** | 低 | `FlowChatScreen` 的 `threadController` + `jumpToLatestTooltip` 直接替换当前手写的 `FButton` 滚动底部按钮 |
| **FlowUI 无 drawer** | 低 | 保留手写 `ConversationDrawer` + `TweenAnimationBuilder` push drawer 动画，不改 |
| **提案卡作为 custom part** | 中 | `AssistantProposalCard` 内部使用 `FButton`/`FTile` 等 Forui 组件，需验证在 `FlowMessage` 渲染树内正常工作（Forui 组件不要求 `FTheme` 祖先，预期 OK） |
| **Material Icons 字体** | 中 | FlowUI 的 composer、jump-to-latest 与 action row 使用硬编码 `Icons.*`；将根 `pubspec.yaml` 改为 `uses-material-design: true`，并在 Android/iOS 真机确认 glyph 正常显示 |

## 三、组件映射表

### 直接替换

| 当前手写组件 | FlowUI 替代 | 说明 |
|-------------|------------|------|
| `page.dart` + `page_body.dart` 的编排层 | `FlowChatScreen` | body-only，保留 `PageScaffold` 外壳 |
| `conversation_message_list.dart` | `FlowThread` | 传入 `ScrollController`，`FlowChatScreen` 提供 jump-to-latest |
| `message_bubble.dart`（用户/助手气泡 + Markdown + streaming） | `FlowMessage` + adapter | 用户与流式草稿使用 `FlowTextPart`；已完成助手消息用 Markdown custom part，避免丢失 Markdown |
| `_AnimatedDots`（typing 指示器） | `FlowThinkingIndicator` | 呼吸星号 + shimmer label，比 dots 更专业 |
| `input_bar.dart`（多行输入 + send 按钮 + 发送中 spinner） | `FlowComposer` | 内置 multiline + send/stop + attachment slot |
| `input_bar_shortcut_hint.dart`（Ctrl+Enter 提示） | 删除 | 桌面端不在范围内；移动端由 send button 发送 |
| `input_bar_starter_prompts.dart`（起跑线 chips） | `FlowSuggestion` / `FlowSuggestionGroup` | column/wrap/scroll 布局可选 |
| `welcome_panel.dart`（空态欢迎） | `FlowGreeting` + `FlowSuggestionGroup` | `FlowChatScreen` 的 `empty` + `greeting` + `suggestions` 参数 |
| `message_bubble.dart` 的 `FContextMenu`（复制/重新生成/重发） | `FlowMessageActions` | 通过 `FlowThread.messageBuilder` 注入；复制仍写 Clipboard + Toast，重试/重发保持禁用 |
| `loading_view.dart`（骨架屏） | 保留 | FlowUI 无骨架屏替代品（`FlowShimmerText` 是文本 shimmer，不是全屏骨架） |

### 保留为 adapter

| 组件 | 保留方式 |
|------|---------|
| `proposal_card.dart` | 作为 `FlowCustomPart(type: 'proposal', data: proposal)` 注入，`customPartBuilder` switch 到 `AssistantProposalCard` |
| `chips.dart`（`AssistantToolChip`） | 复用于 `AssistantProposalCard` 内部，不单独迁移 |

### 保留不动

| 组件 | 原因 |
|------|------|
| `conversation_drawer.dart` + 3 子文件 | FlowUI Side Panel = Planned，无替代 |
| `status_bar.dart` | 已归档/实验性（见 assistant-remediation-plan F-17） |
| `controls_panel.dart` / `controls_sheet*.dart` | 已归档/实验性（F-17） |

## 四、数据模型映射

```dart
// AssistantMessage → FlowMessageData
// FlowThread 的 key 只需在当前 conversation 的生命周期内稳定；不修改 domain entity。
FlowMessageData _mapMessage(
  AssistantMessage msg, {
  required String conversationKey,
  required int index,
  required String canonicalMessageId,
}) {
  return FlowMessageData(
    id: '$conversationKey:$index:$canonicalMessageId',
    role: switch (msg.role) {
      AssistantMessageRole.user => FlowMessageRole.user,
      AssistantMessageRole.assistant => FlowMessageRole.assistant,
    },
    parts: [
      if (msg.role == AssistantMessageRole.assistant)
        FlowCustomPart(
          type: 'markdown',
          data: AssistantMarkdownPart(content: msg.content),
        )
      else
        FlowTextPart(msg.content),
      if (msg.proposedActions.any((p) => p.isVisible))
        for (final p in msg.proposedActions.where((p) => p.isVisible))
          FlowCustomPart(
            type: 'proposal',
            data: AssistantProposalPart(
              messageId: canonicalMessageId,
              proposal: p,
            ),
          ),
    ],
    status: FlowMessageStatus.complete,
    timestamp: msg.createdAt,
  );
}

// streamingDraft → FlowMessageData(pending/streaming)
FlowMessageData _mapStreamingDraft(String draft) {
  return FlowMessageData(
    id: 'streaming',
    role: FlowMessageRole.assistant,
    parts: [FlowTextPart(draft)], // 空字符串时 status=pending → thinking indicator
    status: draft.isEmpty
        ? FlowMessageStatus.pending
        : FlowMessageStatus.streaming,
  );
}
```

### 消息身份与 Markdown 决策

- 不向 `AssistantMessage` 添加 `id`。当前 controller 的 `messageIdOf()` 继续作为 proposal
  操作的 canonical id；adapter 以 `conversationId + index + canonical id` 生成仅供 FlowThread
  使用的唯一 key。这样不会触及 Freezed、SSE mapper、历史会话 mapper 或 domain contract。
- 完成态 assistant 回复用 `FlowCustomPart(type: 'markdown')` 渲染现有 `MarkdownBody`，保留
  可选择文本、链接和代码块样式；proposal part 携带 canonical message id，确保确认/拒绝仍能
  找到 controller 目标。
- 仅临时的 `streamingDraft` 使用 `FlowTextPart` + `FlowMessageStatus.streaming`，因此保留
  FlowUI 的逐字动画；服务端完成事件到达后，它被静态 Markdown 消息替换。

## 五、Theme 桥接

```dart
// lib/features/assistant/presentation/widgets/flow_theme_bridge.dart

/// 从 Luminous 设计 token 派生 FlowTheme，保持视觉一致性。
FlowTheme luminousFlowTheme(BuildContext context) {
  final colors = context.theme.colors; // Forui FTheme colors
  final baseColors = Theme.of(context).brightness == Brightness.dark
      ? FlowColors.dark
      : FlowColors.light;

  return FlowTheme(
    // copyWith 保留 FlowColors 其余 15 个必填角色，而非手写不完整构造器。
    colors: baseColors.copyWith(
      primary: SemanticColor.primary.solid(context),
      onPrimary: colors.primaryForeground,
      surface: colors.background,
      onSurface: colors.foreground,
      onSurfaceVariant: colors.mutedForeground,
      onSurfaceMuted: colors.mutedForeground.withOpacity(0.5),
      onSurfaceDisabled: colors.mutedForeground.withOpacity(0.3),
      outline: colors.border,
      outlineVariant: colors.border.withOpacity(0.5),
      surfaceBright: colors.card,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.secondary,
      surfaceContainer: colors.secondary,
      surfaceContainerHigh: colors.secondary,
      surfaceContainerHighest: colors.secondary,
      error: SemanticColor.danger.solid(context),
      onError: Colors.white,
    ),
    typography: FlowTypography.standard.withFontFamily(
      // 使用 Luminous 现有字体族
      TypographyToken.level4.body(context).fontFamily ?? 'Figtree',
    ),
  );
}
```

在 `page.dart` 通过 `ThemeData.copyWith` 注入，且保留所有现有扩展：

```dart
Widget withLuminousFlowTheme(BuildContext context, Widget child) {
  final parentTheme = Theme.of(context);
  return Theme(
    data: parentTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        ...parentTheme.extensions.values.whereType<ThemeExtension<dynamic>>(),
        luminousFlowTheme(context),
      ],
    ),
    child: child,
  );
}
```

## 六、执行阶段

### 阶段 0：准备（0.5d）

- [ ] `pubspec.yaml` 添加 `flow_ui: ^0.1.0`
- [ ] `pubspec.yaml` 将 `flutter.uses-material-design` 设为 `true`；这是 FlowUI 的硬依赖，
      不添加新的 Material widget 或桌面端验收目标。
- [ ] `flutter pub get`
- [ ] 在 `test/assistant/flowui_adapter_test.dart` 写 adapter 测试：
  - 相同 conversation/index/message 产生稳定且彼此不同的 Flow id；不修改 `AssistantMessage`。
  - 完成态 assistant 回复产生 `markdown` custom part，streaming draft 使用 `FlowTextPart`。
  - proposal custom part 保留 canonical message id，并可渲染为 `AssistantProposalCard`。
- [ ] 在 `test/assistant/page_test.dart` 增加手机宽度 harness，覆盖空态、发送中 composer 禁用、
      完成态 Markdown 与 proposal 确认/拒绝；不新增桌面键盘断言。

### 阶段 1：Theme 桥接（0.5d）

- [ ] 新建 `lib/features/assistant/presentation/widgets/flow_theme_bridge.dart`
- [ ] 在 `page.dart` 以 `ThemeData.copyWith(extensions: ...)` 注入 `FlowTheme`，保留父主题已有
      extensions；`FlowColors.light/dark.copyWith` 补全所有必填角色。
- [ ] 验证：FlowUI 预设主题在 assistant 页面外不泄露（作用域仅限 assistant）

### 阶段 2：核心组件替换（2d）

按依赖顺序执行，每步都跑 `flutter analyze` + 已有 widget 测试：

- [ ] 2a. `FlowThread` + `FlowMessage` 替换 `conversation_message_list.dart` + `message_bubble.dart`
  - 在 adapter 中以 `conversationId + index + messageIdOf(message)` 生成 Flow key；不修改
    `AssistantMessage`、SSE mapper 或 repository。
  - `streamingDraft` → pending/streaming `FlowMessageData`
  - `FlowCustomPart` 注入 `AssistantProposalCard`，并携带 canonical message id。
  - 已完成 assistant 消息以 `markdown` custom part 渲染原有 `MarkdownBody`；仅 streaming draft
    使用 `FlowTextPart` / `FlowStreamingText`。
  - 使用 `FlowThread.messageBuilder` 创建带 footer 的 `FlowMessage`：复制动作继续调用 Clipboard
    与 `Toast.show`；重新生成/重发继续以 null callback 禁用，不新增尚不存在的 controller 功能。
- [ ] 2b. `FlowComposer` 替换 `input_bar.dart`
  - `onSend` 回调映射
  - `canSendMessages` 与 `isSending` 映射为 `enabled`；发送期间保持 `isStreaming: false`，不展示
    没有取消实现的 stop button。
  - 删除 `input_bar_shortcut_hint.dart`；不保留桌面端 Ctrl/Cmd+Enter 行为。
- [ ] 2c. `FlowChatScreen` 组装 `FlowThread` + `FlowComposer` + `FlowGreeting` + `FlowSuggestionGroup`
  - 替换 `page_body.dart` 的编排层
  - `empty` + `greeting` + `suggestions` 映射到 `welcome_panel.dart` 的内容
  - `threadController` + `jumpToLatestTooltip` 替换手写滚动底部按钮
  - 删除 `conversation_stack.dart`（`FlowChatScreen` 内置 jump-to-latest）
- [ ] 2d. `FlowSuggestion` / `FlowSuggestionGroup` 替换 `input_bar_starter_prompts.dart`
  - column 布局映射
  - `onTap` 回调映射
- [ ] 2e. `FlowThinkingIndicator` 替换 `_AnimatedDots`
  - thinkingLabel 走 l10n（`assistantThinkingLabel`，需新增 ARB fragment）

### 阶段 3：清理与验证（1d）

- [ ] 删除被替换的手写组件文件（`message_bubble.dart`、`input_bar.dart`、
      `conversation_stack.dart`、`conversation_surface.dart`、
      `conversation_message_list.dart`、`welcome_panel.dart`、
      `input_bar_shortcut_hint.dart`、`input_bar_starter_prompts.dart`）
- [ ] `AssistantMessageBubble` 的上下文菜单（复制/重新生成/重发）迁移到 `FlowMessageActions`
  - 注意：重新生成/重发当前为 `onPress: null`（禁用），见 assistant-remediation-plan F-5b
  - 迁移后保持禁用状态不变
- [ ] `loading_view.dart` 保留（FlowUI 无全屏骨架替代）
- [ ] `flutter analyze` 零 warning
- [ ] `flutter test` 全量通过
- [ ] 手动验证：空态 → 发消息 → 流式回复 → 提案卡 → 确认/拒绝 → 历史会话切换
- [ ] Android 与 iOS 真机各验证一次：FlowUI Material icon glyph、软键盘、发送中禁用、
      流式动画、Markdown 链接/代码块、proposal 确认/拒绝、历史会话切换和抽屉。

### 阶段 4：l10n 同步（0.5d）

- [ ] 新增 ARB fragment（`lib/l10n/src/assistant_zh.arb`、`assistant_en.arb`）：
  - `assistantThinkingLabel`: "思考中…" / "Thinking…"
  - `assistantJumpToLatestTooltip`: "跳转到最新" / "Jump to latest"
  - `assistantComposerPlaceholder`: 复用现有 `assistantInputHint`
- [ ] `dart scripts/arb_tools.dart merge`
- [ ] `flutter gen-l10n`
- [ ] 更新 `docs/02-reference/Localization.md` 的 assistant fragment 归属说明，并在
      `docs/03-logs/migration-log/2026-08-17.md` 追加迁移与验证结论。

## 七、不做的事

- **不引入 Lucent 后端改动**。FlowUI 是纯 UI 层替换，`AssistantController` 的状态机、
  `AssistantRepository` 的接口、SSE 流式协议全部不变。
- **不改 Forui-first 方向**。FlowUI 作为 assistant 域内局部组件库，不推广到其他 feature。
- **不扩展桌面端**。不为桌面布局、快捷键或鼠标交互保留额外适配；本计划的手动验收只覆盖
  Android/iOS。
- **不引入 `FlowModelSelector` / `FlowMenu` / 附件组件**。当前 assistant 无多模型选择和
  附件功能，保留为未来扩展。
- **不替换 `ConversationDrawer`**。FlowUI Side Panel 在 Roadmap 中为 Planned。
- **不碰 `status_bar.dart` / `controls_panel.dart` / `controls_sheet*.dart`**。已归档/实验性。

## 八、验收标准

| 项 | 标准 | 验证方式 |
|----|------|---------|
| 功能等价 | Android/iOS：空态欢迎 → 发消息 → 流式回复 → Markdown → 提案卡确认/拒绝 → 历史会话切换 → 抽屉搜索/分组 全部正常 | 手机真机手动测试 |
| 图标资源 | FlowUI 内部的 stop/send/jump/action glyph 可显示，无 tofu | Android 与 iOS 真机 |
| 视觉一致 | Android/iOS 上 FlowUI 组件颜色/字体与 Forui 主题一致（通过 theme bridge） | 手机手动对比 |
| 代码量净减 | 被删除的手写组件 > 新增的 adapter + theme bridge | `git diff --stat` |
| 静态检查 | `flutter analyze` 零 warning | CI |
| 测试 | 已有 assistant 测试全过；覆盖 adapter identity、Markdown、proposal callback 与发送中禁用 | `flutter test test/assistant`，再运行 `flutter test` |
| l10n | 新增 ARB fragment 走 merge → gen-l10n 流程 | `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` |

## 九、风险与回退

- **回退策略**：如 FlowUI 与移动端主题、Material icon font 或 Forui 组件存在不可修复冲突，
  回退 presentation、`pubspec.yaml` 和新增 l10n/test/doc 提交；domain/data 层不在本计划修改面。
- **渐进式回退**：如某个组件替换后发现移动端体验退化（例如输入框软键盘行为），可单独保留
  该手写组件，其余替换照常。

## 十、与现有计划的关系

- 本计划与 [`2026-08-16-assistant-remediation-plan.md`](2026-08-16-assistant-remediation-plan.md)
  正交——后者关注信任缺口和功能补齐（P0/P1/P2），本计划关注 UI 组件层替换。
- 建议执行顺序：**先完成 assistant-remediation-plan 的 P0（来源条、免责条）再执行本计划**。
  原因：来源条和免责条需注入到 `message_bubble.dart`，如果先迁移到 FlowUI 的
  `FlowMessage`，这些组件需作为 `FlowCustomPart` 注入，增加耦合。先在现有手写组件上
  实现信任缺口修复，验证后再迁移 UI 层，风险更低。
- 如果时间紧迫，两者可并行：remediation P0 在 `message_bubble.dart` 上实现，
  本计划在 `FlowMessage` 上迁移时，把 remediation 的组件一并作为 custom part 注入。
  但建议串行以减少 rework。

## 十一、依赖

- `flow_ui: ^0.1.0` (pub.dev, MIT license)
- 现有 Forui `^0.25.0` 不变
- 无 Lucent 后端依赖
