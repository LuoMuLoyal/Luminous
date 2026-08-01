import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/sections/input_bar.dart';
import 'package:luminous/features/assistant/presentation/widgets/views/conversation_message_list.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The main conversation surface: message list + loading/error overlays + input bar.
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
    this.showStarterPrompts = false,
  });

  final AssistantCapabilities capabilities;
  final ScrollController scrollController;
  final TextEditingController controller;
  final Future<void> Function() onSend;
  final VoidCallback? onRetry;
  final bool showStarterPrompts;
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

    return Column(
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
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 800.ms),
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
          child: AssistantConversationMessageList(
            capabilities: capabilities,
            scrollController: scrollController,
            onConfirmProposal: onConfirmProposal,
            onDismissProposal: onDismissProposal,
          ),
        ),
        if (sendError != null) ...[
          const SizedBox(height: Spacing.level4),
          StateMessageView(
            title: l10n.assistantSendErrorTitle,
            description: sendErrorDescription(l10n, sendErrorType, sendError),
            icon: sendErrorIcon(sendErrorType),
            tone: StateTone.warning,
            actionLabel: onRetry != null ? l10n.assistantRetryAction : null,
            onAction: onRetry,
            actionKey: const Key('assistant-retry-action'),
            padding: const EdgeInsets.all(Spacing.level4),
          ),
        ],
        const SizedBox(height: Spacing.level3),
        AssistantInputBar(
          controller: controller,
          canSend: capabilities.canSendMessages && !isSending,
          isSending: isSending,
          canSendMessages: capabilities.canSendMessages,
          showStarterPrompts: showStarterPrompts,
          onSend: onSend,
        ),
      ],
    );
  }
}
