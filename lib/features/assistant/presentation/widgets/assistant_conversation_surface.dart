import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/providers/assistant_controller.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/assistant_message_bubble.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantConversationSurface extends StatelessWidget {
  const AssistantConversationSurface({
    super.key,
    required this.state,
    required this.capabilities,
    required this.scrollController,
    required this.controller,
    required this.onSend,
    this.onRetry,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantState state;
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SettingsSectionSurface(
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isOpeningConversation) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
              child: Text(
                l10n.assistantOpeningConversationLabel,
                style: assistantTypography(context).bodySm.copyWith(
                  color: surface.mute,
                ),
              ),
            ),
          ],
          Expanded(
            child: _ConversationView(
              state: state,
              capabilities: capabilities,
              scrollController: scrollController,
              onConfirmProposal: onConfirmProposal,
              onDismissProposal: onDismissProposal,
            ),
          ),
          if (state.sendError != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AppStateMessageView(
              title: l10n.assistantSendErrorTitle,
              description: sendErrorDescription(
                l10n,
                state.sendErrorType,
                state.sendError!,
              ),
              icon: sendErrorIcon(state.sendErrorType),
              tone: AppStateTone.warning,
              actionLabel:
                  onRetry != null ? l10n.assistantRetryAction : null,
              onAction: onRetry,
              actionKey: const Key('assistant-retry-action'),
              padding: const EdgeInsets.all(AppSpacingTokens.md),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.md),
          _InputComposer(
            controller: controller,
            canSend: capabilities.canSendMessages && !state.isSending,
            isSending: state.isSending,
            onSend: onSend,
          ),
        ],
      ),
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView({
    required this.state,
    required this.capabilities,
    required this.scrollController,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final AssistantState state;
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!capabilities.canSendMessages &&
        state.messages.isEmpty &&
        state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationDisabledTitle,
        description: _disabledDescription(l10n, capabilities),
        icon: Icons.pause_circle_outline_rounded,
        tone: AppStateTone.warning,
      );
    }

    if (state.messages.isEmpty && state.streamingDraft.isEmpty) {
      return AppStateMessageView(
        title: l10n.assistantConversationEmptyTitle,
        description: l10n.assistantConversationEmptyDescription,
        icon: Icons.chat_bubble_outline_rounded,
      );
    }

    final items = <_ConversationItem>[
      ...state.messages.map(_ConversationItem.message),
      if (state.streamingDraft.isNotEmpty)
        _ConversationItem.streaming(state.streamingDraft),
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
          onConfirmProposal: onConfirmProposal,
          onDismissProposal: onDismissProposal,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacingTokens.md),
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
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final bool isSending;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            key: const Key('assistant-input'),
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l10n.assistantInputHint,
              filled: true,
              fillColor: surface.canvasSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        FilledButton(
          key: const Key('assistant-send-action'),
          onPressed: canSend ? onSend : null,
          child: Text(
            isSending
                ? l10n.assistantSendingAction
                : l10n.assistantSendAction,
          ),
        ),
      ],
    );
  }
}
