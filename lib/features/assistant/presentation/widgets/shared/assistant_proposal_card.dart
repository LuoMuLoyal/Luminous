import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
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
                    style: assistantTypography(context).bodyMdStrong,
                  ),
                ),
                Text(
                  proposalStateText(l10n, proposal),
                  style: assistantTypography(
                    context,
                  ).bodySm.copyWith(color: proposalStateColor(theme, proposal)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(proposal.summary, style: assistantTypography(context).bodySm),
            if (proposal.reason case final reason?) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                reason,
                style: assistantTypography(
                  context,
                ).bodySm.copyWith(color: surface.body),
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
                style: assistantTypography(
                  context,
                ).bodySm.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacingTokens.sm),
            Row(
              children: [
                FilledButton(
                  key: Key('assistant-proposal-confirm-${proposal.id}'),
                  onPressed:
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
                TextButton(
                  key: Key('assistant-proposal-dismiss-${proposal.id}'),
                  onPressed:
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
    final surface = theme.extension<AppThemeSurface>()!;
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.65,
        ),
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
                  style: assistantTypography(
                    context,
                  ).bodySm.copyWith(color: surface.body),
                ),
              ),
            if (proposal.constraints.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.assistantProposalConstraintsLabel,
                style: assistantTypography(context).bodySmStrong,
              ),
              const SizedBox(height: 2),
              for (final constraint in proposal.constraints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $constraint',
                    style: assistantTypography(
                      context,
                    ).bodySm.copyWith(color: surface.body),
                  ),
                ),
            ],
            if (proposal.isExpired) ...[
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.assistantProposalExpiredHint,
                style: assistantTypography(
                  context,
                ).bodySm.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
