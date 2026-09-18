import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/accessibility/motion.dart';
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

  /// Whether a retry is worth offering. A model rejection is deterministic,
  /// so "Continue generating" would replay the same request into the same
  /// refusal — the copy explains the situation instead.
  bool get _canRetry =>
      onRetry != null && sendErrorType != AssistantSendErrorType.modelRejected;

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
                const _OpeningSpinner(),
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
            actionLabel: _canRetry
                ? l10n.assistantContinueGeneratingAction
                : null,
            onAction: _canRetry ? onRetry : null,
            actionKey: const Key('assistant-retry-action'),
            padding: const EdgeInsets.all(Spacing.lg),
          ),
        ],
      ],
    );
  }
}

/// The "opening conversation" spinner.
///
/// Spins only when the user has not asked for reduced motion. `flutter_animate`
/// has no built-in support for the accessibility flags, so this has to opt in
/// itself — otherwise the 800ms repeating rotation kept the app scheduling
/// frames forever while a conversation was opening, regardless of the setting.
/// The reduced-motion rendering is the same spinner held still: it still reads
/// as "working", it just does not move.
class _OpeningSpinner extends StatelessWidget {
  const _OpeningSpinner();

  @override
  Widget build(BuildContext context) {
    const spinner = SizedBox(width: 16, height: 16, child: FCircularProgress());

    if (prefersReducedMotion(context)) {
      return spinner;
    }

    return spinner
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 800.ms);
  }
}
