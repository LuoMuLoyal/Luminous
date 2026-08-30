import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/shared/chips.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantProposalCard extends StatelessWidget {
  const AssistantProposalCard({
    super.key,
    required this.messageId,
    required this.proposal,
    required this.onConfirmProposal,
    required this.onDismissProposal,
    this.onRegenerateProposal,
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

  /// Re-triggers generation of the user message that produced this proposal,
  /// used when the proposal has expired.
  final void Function({required String messageId, required String proposalId})?
  onRegenerateProposal;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: context.theme.style.borderRadius.md,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  proposalIcon(proposal.type),
                  size: 18,
                  color: SemanticColor.primary.solid(context),
                ),
                const SizedBox(width: Spacing.level2),
                Expanded(
                  child: Text(
                    proposal.title,
                    style: typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  proposalStateText(l10n, proposal),
                  style: typography.body.sm.copyWith(
                    color: proposalStateColor(colors, proposal),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(proposal.summary, style: typography.body.md),
            if (proposal.reason case final reason?) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                reason,
                style: typography.body.sm.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (proposal.previewFields.isNotEmpty) ...[
              const SizedBox(height: Spacing.level3),
              Wrap(
                spacing: Spacing.level2,
                runSpacing: Spacing.level2,
                children: [
                  for (final field in proposal.previewFields)
                    AssistantToolChip(label: '${field.label}: ${field.value}'),
                ],
              ),
            ],
            const SizedBox(height: Spacing.level3),
            _ProposalMetaSection(proposal: proposal),
            if (proposal.executionError case final error?) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                error,
                style: typography.body.sm.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
            ],
            const SizedBox(height: Spacing.level3),
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
                const SizedBox(width: Spacing.level3),
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
                if (proposal.isExpired) ...[
                  const SizedBox(width: Spacing.level3),
                  FButton(
                    key: Key('assistant-proposal-regenerate-${proposal.id}'),
                    variant: FButtonVariant.ghost,
                    onPress: onRegenerateProposal == null
                        ? null
                        : () => onRegenerateProposal!(
                            messageId: messageId,
                            proposalId: proposal.id,
                          ),
                    child: Text(l10n.assistantProposalRegenerateAction),
                  ),
                ],
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final l10n = AppLocalizations.of(context)!;
    final metaRows = <String>[
      '${l10n.assistantProposalTargetLabel}: ${proposal.target.label}',
      if (proposal.target.matchedBy.isNotEmpty)
        '${l10n.assistantProposalMatchedByLabel}: ${proposal.target.matchedBy.join(', ')}',
      if (proposal.target.settingKeys.isNotEmpty)
        '${l10n.assistantProposalSettingKeysLabel}: ${proposal.target.settingKeys.join(', ')}',
      if (proposal.expiresAt case final expiresAt?)
        '${l10n.assistantProposalExpiresAtLabel}: ${formatAssistantDateTimeShort(Localizations.localeOf(context), expiresAt)}',
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in metaRows)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.level1),
                child: Text(
                  row,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
            if (proposal.constraints.isNotEmpty) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.assistantProposalConstraintsLabel,
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.level1),
              for (final constraint in proposal.constraints)
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.level1),
                  child: Text(
                    '• $constraint',
                    style: typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ),
            ],
            if (proposal.isExpired) ...[
              const SizedBox(height: Spacing.level2),
              Text(
                l10n.assistantProposalExpiredHint,
                style: typography.body.sm.copyWith(
                  color: SemanticColor.destructive.solid(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
