import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/chat_adapter.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/above_composer.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/empty_conversation.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The assistant conversation surface, rendered by `flutter_gen_ai_chat_ui`.
///
/// It watches the assistant controller state, maps it through
/// [AssistantChatAdapter], and drives one owned [ChatMessagesController] so
/// gen_ai can show the streaming caret while the SSE reply arrives. The
/// surrounding page keeps owning the input and scroll controllers.
class AssistantChatSurface extends ConsumerStatefulWidget {
  const AssistantChatSurface({
    super.key,
    required this.capabilities,
    required this.inputController,
    required this.scrollController,
    required this.onSend,
    required this.onConfirmProposal,
    required this.onDismissProposal,
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
    this.onRetry,
    required this.onStarterPrompt,
    required this.showMemoryHint,
    required this.showDisclaimerExpanded,
  });

  final AssistantCapabilities capabilities;
  final TextEditingController inputController;
  final ScrollController scrollController;
  final Future<void> Function(String text) onSend;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  /// Regenerates the last assistant message (F-5b).
  final VoidCallback? onRegenerate;

  /// Re-sends an existing user message (「重新发送」).
  final void Function(String content)? onResend;
  final VoidCallback? onRetry;

  final ValueChanged<String> onStarterPrompt;
  final bool showMemoryHint;
  final bool showDisclaimerExpanded;

  @override
  ConsumerState<AssistantChatSurface> createState() =>
      _AssistantChatSurfaceState();
}

class _AssistantChatSurfaceState extends ConsumerState<AssistantChatSurface> {
  late final ChatMessagesController _chat;
  DateTime? _streamingStartedAt;

  @override
  void initState() {
    super.initState();
    _chat = ChatMessagesController();
    final state = ref.read(assistantControllerProvider);
    _syncStreaming(
      streaming: state.isSending && state.streamingDraft.isNotEmpty,
    );
  }

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  void _syncStreaming({required bool streaming}) {
    if (streaming) {
      _streamingStartedAt ??= DateTime.now();
      _chat.setStreamingMessage(assistantStreamingMessageId);
    } else {
      _streamingStartedAt = null;
      _chat.stopStreamingMessage(assistantStreamingMessageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final capabilities = widget.capabilities;

    final messages = ref.watch(
      assistantControllerProvider.select((s) => s.messages),
    );
    final streamingDraft = ref.watch(
      assistantControllerProvider.select((s) => s.streamingDraft),
    );
    final isSending = ref.watch(
      assistantControllerProvider.select((s) => s.isSending),
    );
    final isOpeningConversation = ref.watch(
      assistantControllerProvider.select((s) => s.isOpeningConversation),
    );
    final conversationId = ref.watch(
      assistantControllerProvider.select((s) => s.conversationId),
    );
    final sendError = ref.watch(
      assistantControllerProvider.select((s) => s.sendError),
    );
    final sendErrorType = ref.watch(
      assistantControllerProvider.select((s) => s.sendErrorType),
    );
    final lastFailedInput = ref.watch(
      assistantControllerProvider.select((s) => s.lastFailedInput),
    );

    // Mirror the SSE lifecycle onto gen_ai's open-stream bookkeeping, which is
    // what drives the streaming caret and hides the turn's action row. The
    // listener runs outside build; the initial sync is done in [initState].
    ref.listen(
      assistantControllerProvider.select(
        (s) =>
            (isStreaming: s.isSending, hasDraft: s.streamingDraft.isNotEmpty),
      ),
      (previous, next) =>
          _syncStreaming(streaming: next.isStreaming && next.hasDraft),
    );

    // F-4 链接契约:气泡先弹确认对话框,确认后经统一外部链接打开工具跳转。
    final openLink = ref.read(externalUrlLauncherProvider).open;

    final pending = isSending && streamingDraft.isEmpty;

    if (!capabilities.canSendMessages &&
        messages.isEmpty &&
        streamingDraft.isEmpty &&
        !pending &&
        !isOpeningConversation) {
      return StateMessageView(
        title: l10n.assistantConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: SemanticIcons.statusPaused,
        tone: StateTone.warning,
      );
    }

    final adapter = AssistantChatAdapter(
      onConfirmProposal: widget.onConfirmProposal,
      onDismissProposal: widget.onDismissProposal,
      onRegenerateProposal: widget.onRegenerateProposal,
      onRegenerate: widget.onRegenerate,
      onResend: widget.onResend,
      onOpenLink: openLink,
    );

    final mapped = adapter.mapMessages(
      conversationId: conversationId ?? 'unscoped',
      messages: messages,
      thinkingLabel: l10n.assistantThinkingLabel,
      streamingDraft: streamingDraft,
      streamingDraftCreatedAt: _streamingStartedAt,
      isSending: isSending,
      pending: pending,
    );
    if (isOpeningConversation) {
      mapped.insert(
        0,
        adapter.mapLoading(
          l10n.assistantOpeningConversationLabel,
          id: assistantOpeningMessageId,
        ),
      );
    }
    if (sendError != null) {
      mapped.insert(
        0,
        ChatMessage.widget(
          user: chatAssistantUser,
          builder: (context) => AssistantAboveComposer(
            isOpeningConversation: false,
            sendError: sendError,
            sendErrorType: sendErrorType,
            onRetry: lastFailedInput != null
                ? () => ref
                      .read(assistantControllerProvider.notifier)
                      .retryLastMessage()
                : widget.onRetry,
          ),
        ),
      );
    }

    final chat = AiChatWidget(
      key: const Key('assistant-chat-surface'),
      currentUser: chatCurrentUser,
      aiUser: chatAssistantUser,
      controller: _chat,
      messages: mapped,
      readOnly: !capabilities.canSendMessages,
      scrollController: widget.scrollController,
      onSendMessage: (message) {
        // While a reply is generating the controller ignores new sends; keep
        // the user's text so it is not silently dropped by gen_ai's composer
        // (which clears itself before calling back).
        if (isSending) {
          widget.inputController.value = TextEditingValue(
            text: message.text,
            selection: TextSelection.collapsed(offset: message.text.length),
          );
          return;
        }
        unawaited(widget.onSend(message.text));
      },
      inputOptions: InputOptions(
        textController: widget.inputController,
        decoration: InputDecoration(
          hintText: l10n.assistantComposerPlaceholder,
        ),
        maxLines: 5,
      ),
      messageOptions: MessageOptions(
        showUserName: false,
        aiNameIcon: const SizedBox.shrink(),
        showCopyButton: false,
        showTime: false,
        markdownStyleSheet: MarkdownStyle.ai(
          context,
          background: context.theme.colors.secondary,
        ),
        onTapLink: (text, href, title) => adapter.handleLinkTap(context, href),
        bubbleBuilder: adapter.buildBubble,
      ),
      welcomeMessageConfig: WelcomeMessageConfig(
        centerVertically: true,
        builder: () => AssistantEmptyConversation(
          onStarterPrompt: widget.onStarterPrompt,
          showMemoryHint: widget.showMemoryHint,
          showDisclaimerExpanded: widget.showDisclaimerExpanded,
        ),
      ),
    );

    if (capabilities.canSendMessages) {
      return chat;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: chat),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.md),
          child: Row(
            children: [
              Icon(
                SemanticIcons.statusPaused,
                size: 14,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  l10n.assistantInputDisabledHint,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _disabledDescription(
    AppLocalizations l10n,
    AssistantCapabilities capabilities,
  ) {
    if (!capabilities.assistantEnabled) {
      return l10n.assistantConversationDisabledByUserHint;
    }
    if (!capabilities.chatModelConfigured) {
      return l10n.assistantConversationModelMissing;
    }
    return l10n.assistantConversationNotReady;
  }
}
