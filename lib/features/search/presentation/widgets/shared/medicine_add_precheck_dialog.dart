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

    return AppDialogShell(
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
            style: TypographyToken.level7
                .display(context)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            l10n.medicineSearchPrecheckDescription,
            textAlign: TextAlign.center,
            style: TypographyToken.level4
                .body(context)
                .copyWith(color: colors.mutedForeground),
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
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Spacing.level3),
                  _ScopeRow(
                    icon: FLucideIcons.shieldAlert,
                    label: l10n.medicineSearchPrecheckScopeAllergy,
                  ),
                  _ScopeRow(
                    icon: FLucideIcons.gitCompare,
                    label: l10n.medicineSearchPrecheckScopeInteraction,
                  ),
                  _ScopeRow(
                    icon: FLucideIcons.fileText,
                    label: l10n.medicineSearchPrecheckScopeContraindication,
                  ),
                  if (result.coverageSummary.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level4),
                    Container(
                      padding: const EdgeInsets.all(Spacing.level3),
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          RadiusTokens.level3,
                        ),
                        border: Border.all(
                          color: colors.secondary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FLucideIcons.circleAlert,
                            color: colors.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Text(
                              result.coverageSummary,
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.foreground),
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
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w800),
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
                      style: TypographyToken.level5
                          .body(context)
                          .copyWith(fontWeight: FontWeight.w800),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
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
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskFindingBody(l10n, finding),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.foreground),
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
          Icon(icon, color: colors.mutedForeground, size: 16),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Text(
              label,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.foreground),
            ),
          ),
          Icon(FLucideIcons.check, color: colors.primary, size: 16),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(FLucideIcons.circleAlert, color: colors.secondary, size: 18),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.medicineName,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskCoverageReasonLabel(l10n, issue.reason),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.foreground),
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
