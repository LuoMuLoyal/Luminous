import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final isUser = role == AssistantMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = isUser
        ? theme.colorScheme.primary.withValues(alpha: 0.14)
        : surface.canvasSoft2;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUser)
                  Text(content, style: assistantTypography(context).bodyMd)
                else
                  MarkdownBody(
                    data: content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: assistantTypography(context).bodyMd,
                      blockquote: assistantTypography(
                        context,
                      ).bodySm.copyWith(color: surface.body),
                    ),
                  ),
                if (isStreaming) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    AppLocalizations.of(context)!.assistantStreamingLabel,
                    style: assistantTypography(
                      context,
                    ).bodySm.copyWith(color: surface.mute),
                  ),
                ],
                if (!isStreaming && usedTools.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Wrap(
                    spacing: AppSpacingTokens.xs,
                    runSpacing: AppSpacingTokens.xs,
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
                  const SizedBox(height: AppSpacingTokens.md),
                  for (final proposal in proposedActions.where(
                    (proposal) => proposal.isVisible,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.sm,
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
