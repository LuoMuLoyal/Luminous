import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/message_bubble.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The scrollable message list of the assistant conversation surface.
///
/// It watches `messages` and `streamingDraft` separately from the surrounding
/// input bar so the input bar does not rebuild on every streaming chunk.
class AssistantConversationMessageList extends ConsumerWidget {
  const AssistantConversationMessageList({
    super.key,
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

    final messages = ref.watch(
      assistantControllerProvider.select((s) => s.messages),
    );
    final streamingDraft = ref.watch(
      assistantControllerProvider.select((s) => s.streamingDraft),
    );

    if (!capabilities.canSendMessages &&
        messages.isEmpty &&
        streamingDraft.isEmpty) {
      return StateMessageView(
        title: l10n.assistantConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: SemanticIcons.statusPaused,
        tone: StateTone.warning,
      );
    }

    if (messages.isEmpty && streamingDraft.isEmpty) {
      return StateMessageView(
        title: l10n.assistantConversationEmptyTitle,
        description: l10n.assistantConversationEmptyDescription,
        icon: SemanticIcons.actionMessage,
      );
    }

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
