import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/safety_metrics.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SafetyCard extends StatelessWidget {
  const SafetyCard({
    super.key,
    required this.l10n,
    required this.result,
    required this.riskLevel,
    required this.hasData,
    required this.isStale,
    required this.visibleAlerts,
    required this.alertCount,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final MedicineRiskLevel riskLevel;
  final bool hasData;
  final bool isStale;
  final List<MedicineAlert> visibleAlerts;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return SafetyEmptyCard(l10n: l10n);
    }

    final palette = _riskLevelPalette(riskLevel);

    return FTappable(
      onPress: () => context.push(Routes.medicineRiskCheck),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: palette.subtle(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.md,
            side: BorderSide(color: palette.border(context)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiskSummary(l10n: l10n, result: result, riskLevel: riskLevel),
              const SizedBox(height: Spacing.level4),
              MetricRow(l10n: l10n, result: result),
              if (visibleAlerts.isNotEmpty) ...[
                const SizedBox(height: Spacing.level4),
                Column(
                  children: [
                    for (final alert in visibleAlerts) ...[
                      AlertChip(alert: alert, l10n: l10n),
                      if (alert != visibleAlerts.last)
                        const SizedBox(height: Spacing.level2),
                    ],
                    if (alertCount > visibleAlerts.length)
                      Text(
                        '+${alertCount - visibleAlerts.length}',
                        style: context.theme.typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  SemanticColor _riskLevelPalette(MedicineRiskLevel level) {
    return medicineRiskLevelColor(level);
  }
}

class RiskSummary extends StatelessWidget {
  const RiskSummary({
    super.key,
    required this.l10n,
    required this.result,
    required this.riskLevel,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final MedicineRiskLevel riskLevel;

  @override
  Widget build(BuildContext context) {
    final palette = _riskLevelPalette(riskLevel);
    final summary = SafetySummary.fromResult(l10n, result, riskLevel);
    final typography = context.theme.typography;

    return Row(
      children: [
        Container(
          width: Spacing.level8,
          height: Spacing.level8,
          decoration: ShapeDecoration(
            color: palette.muted(context),
            shape: const CircleBorder(),
          ),
          child: Icon(
            key: const Key('medicine-safety-summary-icon'),
            summary.icon,
            color: palette.solid(context),
            size: IconSizeTokens.lg,
          ),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.title,
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                summary.body,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          SemanticIcons.actionNext,
          color: SemanticColor.neutral.solid(context),
          size: IconSizeTokens.md,
        ),
      ],
    );
  }

  SemanticColor _riskLevelPalette(MedicineRiskLevel level) {
    return medicineRiskLevelColor(level);
  }
}

class SafetyEmptyCard extends StatelessWidget {
  const SafetyEmptyCard({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FTappable(
      onPress: () => context.push(Routes.medicineRiskCheck),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: SemanticColor.neutral.subtle(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.md,
            side: BorderSide(color: SemanticColor.neutral.border(context)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Row(
            children: [
              Container(
                width: Spacing.level8,
                height: Spacing.level8,
                decoration: ShapeDecoration(
                  color: SemanticColor.neutral.muted(context),
                  shape: const CircleBorder(),
                ),
                child: Icon(
                  SemanticIcons.safetySafe,
                  color: SemanticColor.neutral.solid(context),
                  size: IconSizeTokens.lg,
                ),
              ),
              const SizedBox(width: Spacing.level3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.medicineSafetyPanelEmptyTitle,
                      style: typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.level1),
                    Text(
                      l10n.medicineSafetyPanelEmptyBody,
                      style: typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                SemanticIcons.actionNext,
                color: SemanticColor.neutral.solid(context),
                size: IconSizeTokens.md,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SafetySummary {
  const SafetySummary({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  static SafetySummary fromResult(
    AppLocalizations l10n,
    MedicineRiskCheckResult result,
    MedicineRiskLevel riskLevel,
  ) {
    if (result.hasFindings) {
      return SafetySummary(
        title: l10n.medicineRiskCheckTierConfirmedRisk,
        body: l10n.medicineRiskCheckFindingsTitle,
        icon: SemanticIcons.statusWarning,
      );
    }

    if (result.hasCoverageGaps) {
      return SafetySummary(
        title: l10n.medicineRiskCheckTierUncovered,
        body: l10n.medicineRiskCheckTierUncoveredDisclaimer,
        icon: SemanticIcons.statusError,
      );
    }

    return SafetySummary(
      title: l10n.medicineRiskCheckTierConfirmedSafe,
      body: l10n.medicineRiskCheckTierSafeDisclaimer,
      icon: SemanticIcons.reportAdherence,
    );
  }
}
