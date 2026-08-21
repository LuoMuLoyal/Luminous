import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/widgets/flowui_adapter.dart';
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
    this.onRegenerateProposal,
    this.onRegenerate,
    this.onResend,
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
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  /// Regenerates the last assistant message (F-5b).
  final VoidCallback? onRegenerate;

  /// Re-sends an existing user message (「重新发送」).
  final void Function(String content)? onResend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final messages = ref.watch(
      assistantControllerProvider.select((s) => s.messages),
    );
    final streamingDraft = ref.watch(
      assistantControllerProvider.select((s) => s.streamingDraft),
    );
    final isSending = ref.watch(
      assistantControllerProvider.select((s) => s.isSending),
    );
    final conversationId = ref.watch(
      assistantControllerProvider.select((s) => s.conversationId),
    );

    // F-4 链接契约：气泡先弹确认对话框，确认后经统一外部链接打开工具跳转。
    final openLink = ref.read(externalUrlLauncherProvider).open;

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

    final pending = isSending && streamingDraft.isEmpty;

    if (messages.isEmpty && streamingDraft.isEmpty && !pending) {
      return StateMessageView(
        title: l10n.assistantConversationEmptyTitle,
        description: l10n.assistantConversationEmptyDescription,
        icon: SemanticIcons.actionMessage,
      );
    }

    final adapter = AssistantFlowUiAdapter(
      onConfirmProposal: onConfirmProposal,
      onDismissProposal: onDismissProposal,
      onRegenerateProposal: onRegenerateProposal,
      onRegenerate: onRegenerate,
      onResend: onResend,
      onOpenLink: openLink,
      thinkingLabel: l10n.assistantStreamingLabel,
    );

    return FlowThread(
      key: const Key('assistant-message-list'),
      messages: adapter.mapMessages(
        conversationId: conversationId ?? 'unscoped',
        messages: messages,
        streamingDraft: streamingDraft,
        isSending: isSending,
        pending: pending,
      ),
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemSpacing: Spacing.level4,
      messageBuilder: adapter.buildMessage,
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
