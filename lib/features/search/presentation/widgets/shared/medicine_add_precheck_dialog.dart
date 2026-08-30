import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineAddPrecheckDialog(
  BuildContext context, {
  required MedicineRiskCheckResult result,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showFDialog<bool>(
    context: context,
    builder: (dialogContext, style, animation) =>
        _MedicineAddPrecheckDialog(l10n: l10n, result: result),
  );
}

class _MedicineAddPrecheckDialog extends StatelessWidget {
  const _MedicineAddPrecheckDialog({required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DialogShell(
      maxWidth: 480,
      maxHeight: 640,
      padding: const EdgeInsets.all(Spacing.level4),
      scrollable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.medicineSearchPrecheckTitle,
            textAlign: TextAlign.center,
            style: context.theme.typography.display.xl.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l10n.medicineSearchPrecheckDescription,
            textAlign: TextAlign.center,
            style: context.theme.typography.body.sm.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Spacing.level4),
                  // Coverage scope section
                  Text(
                    l10n.medicineSearchPrecheckScopeTitle,
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.level3),
                  _ScopeRow(
                    icon: SemanticIcons.safetyCaution,
                    label: l10n.medicineSearchPrecheckScopeAllergy,
                  ),
                  _ScopeRow(
                    icon: SemanticIcons.safetyInteraction,
                    label: l10n.medicineSearchPrecheckScopeInteraction,
                  ),
                  _ScopeRow(
                    icon: SemanticIcons.recordNote,
                    label: l10n.medicineSearchPrecheckScopeContraindication,
                  ),
                  if (result.coverageIssues.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level4),
                    Container(
                      padding: const EdgeInsets.all(Spacing.level3),
                      decoration: BoxDecoration(
                        color: SemanticColor.neutral.muted(context),
                        borderRadius: context.theme.style.borderRadius.sm,
                        border: Border.all(
                          color: SemanticColor.neutral.border(context),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            SemanticIcons.statusError,
                            color: colors.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Text(
                              medicineRiskCheckCoverageSummary(
                                l10n,
                                result.coverageIssues,
                              ),
                              style: context.theme.typography.body.xs.copyWith(
                                color: colors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.findings.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level5),
                    Text(
                      l10n.medicineRiskCheckFindingsTitle,
                      style: context.theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.level3),
                    ...result.findings
                        .take(3)
                        .map(
                          (finding) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: Spacing.level3,
                            ),
                            child: _PrecheckFindingRow(finding: finding),
                          ),
                        ),
                  ],
                  if (result.coverageIssues.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level4),
                    Text(
                      l10n.medicineRiskCheckCoverageTitle,
                      style: context.theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Spacing.level3),
                    ...result.coverageIssues
                        .take(3)
                        .map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: Spacing.level3,
                            ),
                            child: _PrecheckCoverageRow(issue: issue),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.level5),
          FButton(
            key: const Key('medicine-search-precheck-confirm'),
            onPress: () => Navigator.of(context).pop(true),
            child: Text(l10n.medicineSearchPrecheckConfirmAction),
          ),
          const SizedBox(height: Spacing.level3),
          FButton(
            key: const Key('medicine-search-precheck-cancel'),
            variant: FButtonVariant.secondary,
            onPress: () => Navigator.of(context).pop(false),
            child: Text(l10n.medicineReminderCancelAction),
          ),
        ],
      ),
    );
  }
}

class _PrecheckFindingRow extends StatelessWidget {
  const _PrecheckFindingRow({required this.finding});

  final MedicineRiskFinding finding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final colors = context.theme.colors;
    final color = medicineRiskSeverityColor(finding.severity);
    final typography = context.theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.muted(context),
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: color.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              medicineRiskFindingIcon(finding),
              color: color.solid(context),
              size: 18,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineRiskFindingTitle(l10n, finding),
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskFindingBody(l10n, finding),
                    style: typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level2),
      child: Row(
        children: [
          Icon(
            icon,
            color: SemanticColor.neutral.solid(context),
            size: IconSizeTokens.level2,
          ),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              label,
              style: context.theme.typography.body.xs.copyWith(
                color: colors.foreground,
              ),
            ),
          ),
          Icon(
            SemanticIcons.statusDone,
            color: SemanticColor.primary.solid(context),
            size: IconSizeTokens.level2,
          ),
        ],
      ),
    );
  }
}

class _PrecheckCoverageRow extends StatelessWidget {
  const _PrecheckCoverageRow({required this.issue});

  final MedicineRiskCoverageIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.muted(context),
        borderRadius: context.theme.style.borderRadius.sm,
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              SemanticIcons.statusError,
              color: colors.secondary,
              size: IconSizeTokens.level3,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.medicineName,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskCoverageReasonLabel(l10n, issue.reason),
                    style: typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
