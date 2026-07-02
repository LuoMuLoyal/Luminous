import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/assistant_chips.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/assistant_proposal_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.messageId,
    required this.role,
    required this.content,
    required this.usedTools,
    this.proposedActions = const <AssistantProposedAction>[],
    this.isStreaming = false,
    this.onConfirmProposal,
    this.onDismissProposal,
  });

  final String messageId;
  final AssistantMessageRole role;
  final String content;
  final List<String> usedTools;
  final List<AssistantProposedAction> proposedActions;
  final bool isStreaming;
  final Future<void> Function({
    required String messageId,
    required String proposalId,
  })?
  onConfirmProposal;
  final void Function({required String messageId, required String proposalId})?
  onDismissProposal;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final isUser = role == AssistantMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? colors.primary.withValues(alpha: 0.12)
        : colors.secondary;
    final foreground = isUser ? colors.primaryForeground : colors.foreground;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUser)
                  Text(
                    content,
                    style: textTheme.bodyMedium?.copyWith(color: foreground),
                  )
                else
                  MarkdownBody(
                    data: content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          p: textTheme.bodyMedium?.copyWith(color: foreground),
                          blockquote: textTheme.bodySmall?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                  ),
                if (isStreaming) ...[
                  const SizedBox(height: AppSpacingTokens.level3),
                  Text(
                    AppLocalizations.of(context)!.assistantStreamingLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
                if (!isStreaming && usedTools.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.level3),
                  Wrap(
                    spacing: AppSpacingTokens.level2,
                    runSpacing: AppSpacingTokens.level2,
                    children: [
                      for (final tool in usedTools)
                        AssistantToolChip(
                          label: localizeToolName(tool, context),
                        ),
                    ],
                  ),
                ],
                if (!isStreaming &&
                    !isUser &&
                    proposedActions.any((proposal) => proposal.isVisible)) ...[
                  const SizedBox(height: AppSpacingTokens.level4),
                  for (final proposal in proposedActions.where(
                    (proposal) => proposal.isVisible,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.level3,
                      ),
                      child: AssistantProposalCard(
                        messageId: messageId,
                        proposal: proposal,
                        onConfirmProposal: onConfirmProposal,
                        onDismissProposal: onDismissProposal,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
