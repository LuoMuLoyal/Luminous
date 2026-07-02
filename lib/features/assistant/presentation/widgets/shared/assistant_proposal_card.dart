import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/features/assistant/presentation/utils/assistant_ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/assistant_chips.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantProposalCard extends StatelessWidget {
  const AssistantProposalCard({
    super.key,
    required this.messageId,
    required this.proposal,
    required this.onConfirmProposal,
    required this.onDismissProposal,
  });

  final String messageId;
  final AssistantProposedAction proposal;
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
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  proposalIcon(proposal.type),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacingTokens.xs),
                Expanded(
                  child: Text(
                    proposal.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  proposalStateText(l10n, proposal),
                  style: textTheme.labelMedium?.copyWith(
                    color: proposalStateColor(theme, proposal),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(proposal.summary, style: textTheme.bodyMedium),
            if (proposal.reason case final reason?) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                reason,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
            if (proposal.previewFields.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Wrap(
                spacing: AppSpacingTokens.xs,
                runSpacing: AppSpacingTokens.xs,
                children: [
                  for (final field in proposal.previewFields)
                    AssistantToolChip(label: '${field.label}: ${field.value}'),
                ],
              ),
            ],
            const SizedBox(height: AppSpacingTokens.sm),
            _ProposalMetaSection(proposal: proposal),
            if (proposal.executionError case final error?) ...[
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                error,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                FButton(
                  key: Key('assistant-proposal-confirm-${proposal.id}'),
                  onPress:
                      proposal.executionState ==
                              AssistantProposalExecutionState.executing ||
                          proposal.isExpired ||
                          onConfirmProposal == null
                      ? null
                      : () => onConfirmProposal!(
                          messageId: messageId,
                          proposalId: proposal.id,
                        ),
                  child: Text(proposalConfirmLabel(l10n, proposal.type)),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                FButton(
                  key: Key('assistant-proposal-dismiss-${proposal.id}'),
                  variant: FButtonVariant.ghost,
                  onPress:
                      proposal.executionState ==
                          AssistantProposalExecutionState.executing
                      ? null
                      : () => onDismissProposal?.call(
                          messageId: messageId,
                          proposalId: proposal.id,
                        ),
                  child: Text(l10n.assistantProposalDismissAction),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProposalMetaSection extends StatelessWidget {
  const _ProposalMetaSection({required this.proposal});

  final AssistantProposedAction proposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final metaRows = <String>[
      '${l10n.assistantProposalTargetLabel}: ${proposal.target.label}',
      if (proposal.target.matchedBy.isNotEmpty)
        '${l10n.assistantProposalMatchedByLabel}: ${proposal.target.matchedBy.join(', ')}',
      if (proposal.target.settingKeys.isNotEmpty)
        '${l10n.assistantProposalSettingKeysLabel}: ${proposal.target.settingKeys.join(', ')}',
      if (proposal.expiresAt case final expiresAt?)
        '${l10n.assistantProposalExpiresAtLabel}: ${intl.DateFormat(locale.startsWith('zh') ? 'M月d日 HH:mm' : 'MMM d, HH:mm', locale).format(expiresAt.toLocal())}',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in metaRows)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  row,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            if (proposal.constraints.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.assistantProposalConstraintsLabel,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              for (final constraint in proposal.constraints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $constraint',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
            ],
            if (proposal.isExpired) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.assistantProposalExpiredHint,
                style: textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
