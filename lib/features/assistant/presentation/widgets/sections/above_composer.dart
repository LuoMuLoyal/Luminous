import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Loading/error messages above the FlowComposer.
class AssistantAboveComposer extends StatelessWidget {
  const AssistantAboveComposer({
    super.key,
    required this.isOpeningConversation,
    required this.sendError,
    required this.sendErrorType,
    required this.onRetry,
  });

  final bool isOpeningConversation;
  final String? sendError;
  final AssistantSendErrorType? sendErrorType;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOpeningConversation)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                      width: 16,
                      height: 16,
                      child: FCircularProgress(),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 800.ms),
                const SizedBox(width: Spacing.sm),
                Text(
                  l10n.assistantOpeningConversationLabel,
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
        if (sendError != null) ...[
          if (isOpeningConversation) const SizedBox(height: Spacing.lg),
          StateMessageView(
            title: l10n.assistantSendErrorTitle,
            description: sendErrorDescription(l10n, sendErrorType, sendError!),
            icon: sendErrorIcon(sendErrorType),
            tone: StateTone.warning,
            actionLabel: onRetry != null
                ? l10n.assistantContinueGeneratingAction
                : null,
            onAction: onRetry,
            actionKey: const Key('assistant-retry-action'),
            padding: const EdgeInsets.all(Spacing.lg),
          ),
        ],
      ],
    );
  }
}
