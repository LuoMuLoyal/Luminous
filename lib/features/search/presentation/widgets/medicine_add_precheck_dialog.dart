import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.md,
              AppSpacingTokens.md,
              AppSpacingTokens.md,
              AppSpacingTokens.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.medicineSearchPrecheckTitle,
                  textAlign: TextAlign.center,
                  style: typography.displaySm.copyWith(letterSpacing: 0),
                ),
                Text(
                  l10n.medicineSearchPrecheckDescription,
                  textAlign: TextAlign.center,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
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
                              borderRadius: BorderRadius.circular(
                                AppRadiusTokens.md,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColorTokens.warningDeep,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacingTokens.sm),
                                Expanded(
                                  child: Text(
                                    result.coverageSummary,
                                    style: typography.bodySm.copyWith(
                                      color: surface.body,
                                      letterSpacing: 0,
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
                            style: typography.bodySmStrong.copyWith(
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
                            style: typography.bodySmStrong.copyWith(
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
                FilledButton(
                  key: const Key('medicine-search-precheck-confirm'),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.medicineSearchPrecheckConfirmAction),
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                OutlinedButton(
                  key: const Key('medicine-search-precheck-cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.medicineReminderCancelAction),
                ),
              ],
            ),
          ),
        ),
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
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
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskFindingBody(l10n, finding),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

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
              Icons.info_outline_rounded,
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
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskCoverageReasonLabel(l10n, issue.reason),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
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
