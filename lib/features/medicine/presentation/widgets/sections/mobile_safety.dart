part of '../views/mobile_dashboard_view.dart';

class _SafetyEngineSection extends StatelessWidget {
  const _SafetyEngineSection({
    required this.records,
    required this.alerts,
    required this.l10n,
  });

  final MedicineRiskCheckRecords? records;
  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final bestRecord = records?.bestRecord;
    final result = bestRecord?.result ?? const MedicineRiskCheckResult();
    final hasData = bestRecord != null;
    final visibleAlerts = alerts.take(2).toList(growable: false);

    return Column(
      key: const Key('medicine-safety-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SafetyHeader(
          l10n: l10n,
          riskLevel: result.overallRiskLevel,
          hasData: hasData,
          isStale: records?.isStale ?? false,
          lastChecked: bestRecord?.updatedAt,
        ),
        const SizedBox(height: Spacing.level3),
        _SafetyCard(
          l10n: l10n,
          result: result,
          riskLevel: result.overallRiskLevel,
          hasData: hasData,
          isStale: records?.isStale ?? false,
          visibleAlerts: visibleAlerts,
          alertCount: alerts.length,
        ),
      ],
    );
  }
}

class _SafetyHeader extends StatelessWidget {
  const _SafetyHeader({
    required this.l10n,
    required this.riskLevel,
    required this.hasData,
    required this.isStale,
    required this.lastChecked,
  });

  final AppLocalizations l10n;
  final MedicineRiskLevel riskLevel;
  final bool hasData;
  final bool isStale;
  final DateTime? lastChecked;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.medicineSafetyPanelTitle,
            style: typography.display.xl.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.level2),
        if (hasData)
          _LastCheckedLabel(
            l10n: l10n,
            isStale: isStale,
            lastChecked: lastChecked,
          )
        else
          Flexible(
            child: Text(
              l10n.medicineSafetyPanelEmptyBody,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _LastCheckedLabel extends StatelessWidget {
  const _LastCheckedLabel({
    required this.l10n,
    required this.isStale,
    required this.lastChecked,
  });

  final AppLocalizations l10n;
  final bool isStale;
  final DateTime? lastChecked;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    if (isStale) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.doseSlot,
            size: IconSizeTokens.level2,
            color: SemanticColor.warning.solid(context),
          ),
          const SizedBox(width: Spacing.level1),
          Text(
            l10n.medicineRiskCheckStale,
            style: typography.body.xs.copyWith(
              color: SemanticColor.warning.solid(context),
            ),
          ),
        ],
      );
    }

    final time = medicineRiskCheckFormatTime(lastChecked);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          SemanticIcons.doseSlot,
          size: IconSizeTokens.level2,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(width: Spacing.level1),
        Text(
          l10n.medicineRiskCheckLastUpdated(time),
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({
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
      return _SafetyEmptyCard(l10n: l10n);
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
              _RiskSummary(l10n: l10n, result: result, riskLevel: riskLevel),
              const SizedBox(height: Spacing.level4),
              _MetricRow(l10n: l10n, result: result),
              if (visibleAlerts.isNotEmpty) ...[
                const SizedBox(height: Spacing.level4),
                Column(
                  children: [
                    for (final alert in visibleAlerts) ...[
                      _AlertChip(alert: alert, l10n: l10n),
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

class _RiskSummary extends StatelessWidget {
  const _RiskSummary({
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
    final summary = _SafetySummary.fromResult(l10n, result, riskLevel);
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
            size: IconSizeTokens.level4,
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
          size: IconSizeTokens.level3,
        ),
      ],
    );
  }

  SemanticColor _riskLevelPalette(MedicineRiskLevel level) {
    return medicineRiskLevelColor(level);
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricItem(
          label: l10n.medicineRiskCheckCurrentMedicinesLabel,
          value: '${result.currentMedicineCount}',
          color: SemanticColor.neutral,
        ),
        _MetricDividerWidget(),
        _MetricItem(
          label: l10n.medicineRiskCheckFindingsLabel,
          value: '${result.findingCount}',
          color: result.findingCount > 0
              ? SemanticColor.destructive
              : SemanticColor.success,
        ),
        _MetricDividerWidget(),
        _MetricItem(
          label: l10n.medicineRiskCheckCoverageLabel,
          value: '${result.coverageCount}',
          color: result.coverageCount > 0
              ? SemanticColor.warning
              : SemanticColor.success,
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final SemanticColor color;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: typography.display.xl.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: Spacing.level1),
          Text(
            label,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MetricDividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: Spacing.level6,
      color: SemanticColor.neutral.border(context),
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({required this.alert, required this.l10n});

  final MedicineAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      children: [
        Icon(
          alert.icon,
          color: alert.color.solid(context),
          size: IconSizeTokens.level3,
        ),
        const SizedBox(width: Spacing.level2),
        Expanded(
          child: Text(
            medicineAlertTitle(l10n, alert),
            style: typography.body.xs.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.level2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level2,
            vertical: Spacing.level1,
          ),
          decoration: ShapeDecoration(
            color: alert.color.muted(context),
            shape: RoundedSuperellipseBorder(
              borderRadius: context.theme.style.borderRadius.pill,
            ),
          ),
          child: Text(
            alert.color == SemanticColor.destructive
                ? l10n.medicineRiskCheckSeverityHigh
                : l10n.medicineRiskCheckSeverityMedium,
            style: typography.body.xs3.copyWith(
              color: alert.color.solid(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetyEmptyCard extends StatelessWidget {
  const _SafetyEmptyCard({required this.l10n});

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
                  size: IconSizeTokens.level4,
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
                size: IconSizeTokens.level3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetySummary {
  const _SafetySummary({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  static _SafetySummary fromResult(
    AppLocalizations l10n,
    MedicineRiskCheckResult result,
    MedicineRiskLevel riskLevel,
  ) {
    if (result.hasFindings) {
      return _SafetySummary(
        title: l10n.medicineRiskCheckTierConfirmedRisk,
        body: l10n.medicineRiskCheckFindingsTitle,
        icon: SemanticIcons.statusWarning,
      );
    }

    if (result.hasCoverageGaps) {
      return _SafetySummary(
        title: l10n.medicineRiskCheckTierUncovered,
        body: l10n.medicineRiskCheckTierUncoveredDisclaimer,
        icon: SemanticIcons.statusError,
      );
    }

    return _SafetySummary(
      title: l10n.medicineRiskCheckTierConfirmedSafe,
      body: l10n.medicineRiskCheckTierSafeDisclaimer,
      icon: SemanticIcons.reportAdherence,
    );
  }
}
