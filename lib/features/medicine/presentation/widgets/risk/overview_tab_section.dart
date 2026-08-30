import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/metric_chip.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/score_ring.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Tab header showing last-updated time and run/re-run button.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.l10n,
    required this.record,
    required this.isLlm,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckRecord record;
  final bool isLlm;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final timeStr = medicineRiskCheckFormatTime(record.updatedAt);

    return Row(
      children: [
        Icon(
          SemanticIcons.doseSlot,
          size: IconSizeTokens.level2,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(width: Spacing.level1),
        Expanded(
          child: Text(
            l10n.medicineRiskCheckLastUpdated(timeStr),
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
        if (isRunning)
          const SizedBox.square(
            dimension: IconSizeTokens.level3,
            child: FCircularProgress.loader(size: .sm),
          )
        else
          FButton(
            variant: FButtonVariant.ghost,
            size: .sm,
            onPress: onRun,
            child: Text(
              isLlm
                  ? l10n.medicineRiskCheckRunLlm
                  : l10n.medicineRiskCheckRunStatic,
            ),
          ),
      ],
    );
  }
}

/// Risk score hero — large score ring + level label + description.
class RiskScoreHero extends StatelessWidget {
  const RiskScoreHero({
    super.key,
    required this.l10n,
    required this.score,
    required this.riskLevel,
    required this.findingCount,
  });

  final AppLocalizations l10n;
  final int score;
  final MedicineRiskLevel riskLevel;
  final int findingCount;

  @override
  Widget build(BuildContext context) {
    final palette = medicineRiskLevelColor(riskLevel).palette(context);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return DecoratedBox(
      decoration: ShapeDecoration(
        gradient: GradientTokens.tintFade(palette.muted, colors.background),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.lg,
          side: BorderSide(color: palette.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: Row(
          children: [
            RiskScoreRing(score: score, riskLevel: riskLevel),
            const SizedBox(width: Spacing.level6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineRiskScoreTitle,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskLevelLabel(l10n, riskLevel),
                    style: typography.display.xl.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      color: palette.solid,
                    ),
                  ),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    medicineRiskLevelDescription(l10n, riskLevel, findingCount),
                    style: typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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

/// Metric grid — 4 metric cells in a row.
class MetricGrid extends StatelessWidget {
  const MetricGrid({
    super.key,
    required this.l10n,
    required this.result,
    this.onFindingsTap,
    this.onCoverageTap,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final VoidCallback? onFindingsTap;
  final VoidCallback? onCoverageTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.neutral.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            RiskMetricCell(
              label: l10n.medicineRiskCheckCurrentMedicinesLabel,
              value: '${result.currentMedicineCount}',
              color: SemanticColor.neutral,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckCheckedMedicinesLabel,
              value: '${result.checkedMedicineCount}',
              color: SemanticColor.neutral,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckFindingsLabel,
              value: '${result.findingCount}',
              color: result.findingCount > 0
                  ? SemanticColor.destructive
                  : SemanticColor.success,
              onTap: onFindingsTap,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckCoverageLabel,
              value: '${result.coverageCount}',
              color: result.coverageCount > 0
                  ? SemanticColor.warning
                  : SemanticColor.success,
              onTap: onCoverageTap,
              showRightDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Safe state card shown when no findings AND no coverage gaps.
class SafeStateCard extends StatelessWidget {
  const SafeStateCard({super.key, required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.success.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Row(
          children: [
            Container(
              width: Spacing.level8,
              height: Spacing.level8,
              decoration: ShapeDecoration(
                color: SemanticColor.success.muted(context),
                shape: const CircleBorder(),
              ),
              child: Icon(
                SemanticIcons.reportAdherence,
                color: SemanticColor.success.solid(context),
                size: IconSizeTokens.level4,
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineRiskCheckTierConfirmedSafe,
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.medicineRiskCheckTierSafeBody(
                      result.checkedMedicineCount,
                    ),
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.medicineRiskCheckTierSafeDisclaimer,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
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

/// Overall recommendation card (LLM only).
class OverallRecommendationCard extends StatelessWidget {
  const OverallRecommendationCard({
    super.key,
    required this.l10n,
    required this.text,
  });

  final AppLocalizations l10n;
  final String text;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.primary.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
          side: BorderSide(color: SemanticColor.primary.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  SemanticIcons.aiTip,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.level3,
                ),
                const SizedBox(width: Spacing.level2),
                Text(
                  l10n.medicineRiskOverallRecommendation,
                  style: typography.body.md.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              text,
              style: typography.body.xs.copyWith(
                color: context.theme.colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stale banner (LLM only, when data is stale).
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.warning.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
          side: BorderSide(color: SemanticColor.warning.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            Icon(
              SemanticIcons.statusError,
              color: SemanticColor.warning.solid(context),
              size: IconSizeTokens.level3,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                l10n.medicineRiskCheckStaleBanner,
                style: context.theme.typography.body.xs.copyWith(
                  color: context.theme.colors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// LLM empty state — shown when LLM check has not been run yet.
class LlmEmptyState extends StatelessWidget {
  const LlmEmptyState({
    super.key,
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.aiEntry,
              size: IconSizeTokens.level6,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmEmptyTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.medicineRiskCheckLlmEmptyBody,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.level2,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunLlm),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunLlm),
            ),
          ],
        ),
      ),
    );
  }
}

/// Never checked state (static tab) — shown when static check has not been run.
class NeverCheckedState extends StatelessWidget {
  const NeverCheckedState({
    super.key,
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.safetySafe,
              size: IconSizeTokens.level6,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckNeverChecked,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.level2,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunStatic),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunStatic),
            ),
          ],
        ),
      ),
    );
  }
}

/// LLM unavailable state — shown when LLM service is not configured.
class LlmUnavailableState extends StatelessWidget {
  const LlmUnavailableState({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              SemanticIcons.statusSkipped,
              size: IconSizeTokens.level6,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmUnavailable,
              style: context.theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
