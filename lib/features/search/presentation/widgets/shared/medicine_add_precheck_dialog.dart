import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineAddPrecheckDialog(
  BuildContext context, {
  required MedicineRiskCheckResult result,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return _MedicineAddPrecheckDialog(l10n: l10n, result: result);
    },
  );
}

class _MedicineAddPrecheckDialog extends StatelessWidget {
  const _MedicineAddPrecheckDialog({required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return AppDialog(
      maxWidth: 480,
      maxHeight: 640,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      scrollable: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.medicineSearchPrecheckTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            l10n.medicineSearchPrecheckDescription,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (result.coverageSummary.isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: AppColorTokens.warningSoft.withValues(
                          alpha: 0.42,
                        ),
                        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            FLucideIcons.circleAlert,
                            color: AppColorTokens.warningDeep,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              result.coverageSummary,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (result.findings.isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.lg),
                    Text(
                      l10n.medicineRiskCheckFindingsTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacingTokens.sm),
                    ...result.findings
                        .take(3)
                        .map(
                          (finding) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacingTokens.sm,
                            ),
                            child: _PrecheckFindingRow(finding: finding),
                          ),
                        ),
                  ],
                  if (result.coverageIssues.isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.md),
                    Text(
                      l10n.medicineRiskCheckCoverageTitle,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacingTokens.sm),
                    ...result.coverageIssues
                        .take(3)
                        .map(
                          (issue) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacingTokens.sm,
                            ),
                            child: _PrecheckCoverageRow(issue: issue),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          FButton(
            key: const Key('medicine-search-precheck-confirm'),
            onPress: () => Navigator.of(context).pop(true),
            child: Text(l10n.medicineSearchPrecheckConfirmAction),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
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
    final textTheme = Theme.of(context).textTheme;
    final colors = context.theme.colors;
    final color = medicineRiskSeverityColor(finding.severity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(medicineRiskFindingIcon(finding), color: color, size: 18),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineRiskFindingTitle(l10n, finding),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskFindingBody(l10n, finding),
                    style: textTheme.bodySmall?.copyWith(
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

class _PrecheckCoverageRow extends StatelessWidget {
  const _PrecheckCoverageRow({required this.issue});

  final MedicineRiskCoverageIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorTokens.warningSoft.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(
          color: AppColorTokens.warningDeep.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              FLucideIcons.circleAlert,
              color: AppColorTokens.warningDeep,
              size: 18,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.medicineName,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskCoverageReasonLabel(l10n, issue.reason),
                    style: textTheme.bodySmall?.copyWith(
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
