import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/message_bubble.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantConversationSurface extends ConsumerWidget {
  const AssistantConversationSurface({
    super.key,
    required this.capabilities,
    required this.scrollController,
    required this.controller,
    required this.onSend,
    this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantCapabilities capabilities;
  final ScrollController scrollController;
  final TextEditingController controller;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    // Slice the state this widget actually needs. We deliberately avoid
    // watching `streamingDraft` here so the surface itself does not rebuild on
    // every chunk — the streaming bubble below subscribes to the draft
    // directly via `_ConversationView`.
    final isOpeningConversation = ref.watch(
      assistantControllerProvider.select((s) => s.isOpeningConversation),
    );
    final sendError = ref.watch(
      assistantControllerProvider.select((s) => s.sendError),
    );
    final sendErrorType = ref.watch(
      assistantControllerProvider.select((s) => s.sendErrorType),
    );
    final isSending = ref.watch(
      assistantControllerProvider.select((s) => s.isSending),
    );

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOpeningConversation) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.level3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: FCircularProgress(),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .rotate(duration: 800.ms),
                    const SizedBox(width: Spacing.level2),
                    Text(
                      l10n.assistantOpeningConversationLabel,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: _ConversationView(
                capabilities: capabilities,
                scrollController: scrollController,
                onConfirmProposal: onConfirmProposal,
                onDismissProposal: onDismissProposal,
              ),
            ),
            if (sendError != null) ...[
              const SizedBox(height: Spacing.level4),
              AppStateMessageView(
                title: l10n.assistantSendErrorTitle,
                description: sendErrorDescription(
                  l10n,
                  sendErrorType,
                  sendError,
                ),
                icon: sendErrorIcon(sendErrorType),
                tone: AppStateTone.warning,
                actionLabel: onRetry != null ? l10n.assistantRetryAction : null,
                onAction: onRetry,
                actionKey: const Key('assistant-retry-action'),
                padding: const EdgeInsets.all(Spacing.level4),
              ),
            ],
            const SizedBox(height: Spacing.level4),
            _InputComposer(
              controller: controller,
              canSend: capabilities.canSendMessages && !isSending,
              isSending: isSending,
              canSendMessages: capabilities.canSendMessages,
              onSend: onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationView extends ConsumerWidget {
  const _ConversationView({
    required this.capabilities,
    required this.scrollController,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantCapabilities capabilities;
  final ScrollController scrollController;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})
  onDismissProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Watch messages and streamingDraft independently. Riverpod will only
    // rebuild this widget when one of these slices changes — message list
    // mutations (a new assistant message lands) trigger one rebuild, while
    // streamingDraft chunk updates trigger a separate one. Either way, the
    // bubbles themselves are const where possible and the parent stays stable.
    final messages = ref.watch(
      assistantControllerProvider.select((s) => s.messages),
    );
    final streamingDraft = ref.watch(
      assistantControllerProvider.select((s) => s.streamingDraft),
    );

    if (!capabilities.canSendMessages &&
        messages.isEmpty &&
        streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: FLucideIcons.circlePause,
        tone: AppStateTone.warning,
      );
    }

    if (messages.isEmpty && streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationEmptyTitle,
        description: l10n.assistantConversationEmptyDescription,
        icon: FLucideIcons.messageSquareMore,
      );
    }

    // The list of items is recomputed on each rebuild, but the bubbles
    // themselves remain cheap because AssistantMessageBubble now renders a
    // plain Text while streaming and MarkdownBody only once settled.
    final items = <_ConversationItem>[
      ...messages.map(_ConversationItem.message),
      if (streamingDraft.isNotEmpty)
        _ConversationItem.streaming(streamingDraft),
    ];

    return ListView.separated(
      key: const Key('assistant-message-list'),
      controller: scrollController,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.streamingDraft != null) {
          return AssistantMessageBubble(
            messageId: 'streaming-draft',
            role: AssistantMessageRole.assistant,
            content: item.streamingDraft!,
            isStreaming: true,
            usedTools: const <String>[],
          );
        }

        final message = item.message!;
        return AssistantMessageBubble(
          messageId: messageIdFor(message),
          role: message.role,
          content: message.content,
          usedTools: message.usedTools,
          proposedActions: message.proposedActions,
          createdAt: message.createdAt,
          onConfirmProposal: onConfirmProposal,
          onDismissProposal: onDismissProposal,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.level4),
      itemCount: items.length,
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

class _ConversationItem {
  const _ConversationItem._({this.message, this.streamingDraft});

  const _ConversationItem.message(AssistantMessage message)
    : this._(message: message);

  const _ConversationItem.streaming(String draft)
    : this._(streamingDraft: draft);

  final AssistantMessage? message;
  final String? streamingDraft;
}

class _InputComposer extends StatelessWidget {
  const _InputComposer({
    required this.controller,
    required this.canSend,
    required this.isSending,
    required this.canSendMessages,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final bool isSending;
  final bool canSendMessages;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

    final textField = FTextField(
      key: const Key('assistant-input'),
      control: FTextFieldControl.managed(controller: controller),
      minLines: 2,
      maxLines: 6,
      hint: l10n.assistantInputHint,
      enabled: canSendMessages,
    );

    // Wire Ctrl/Cmd+Enter to send on desktop where the hardware keyboard is
    // the primary input. Plain Enter remains a newline so multi-line prompts
    // still work without modifier keys. We wrap with `Focus` instead of
    // `Shortcuts` so the shortcut fires whenever the field (or any of its
    // internal focus nodes) is focused, regardless of the underlying widget.
    final fieldWithShortcut = isDesktop
        ? Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) {
                return KeyEventResult.ignored;
              }
              final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
              final withModifier =
                  HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isMetaPressed;
              if (isEnter && withModifier) {
                if (canSend) {
                  onSend();
                }
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: textField,
          )
        : textField;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canSendMessages) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level3),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.circlePause,
                  size: 14,
                  color: colors.mutedForeground,
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    l10n.assistantInputDisabledHint,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: fieldWithShortcut),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('assistant-send-action'),
              onPress: canSend ? onSend : null,
              child: Text(
                isSending
                    ? l10n.assistantSendingAction
                    : l10n.assistantSendAction,
              ),
            ),
          ],
        ),
        if (isDesktop && canSendMessages) ...[
          const SizedBox(height: Spacing.level2),
          Padding(
            padding: const EdgeInsets.only(left: Spacing.level1),
            child: Text(
              l10n.assistantSendShortcutHint,
              style: TypographyToken.level2
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
          ),
        ],
      ],
    );
  }
}
