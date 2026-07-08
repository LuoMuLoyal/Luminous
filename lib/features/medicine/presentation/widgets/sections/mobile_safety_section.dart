part of '../views/mobile_dashboard_view.dart';

class _SafetyEngineSection extends StatelessWidget {
  const _SafetyEngineSection({
    required this.result,
    required this.alerts,
    required this.l10n,
  });

  final MedicineRiskCheckResult? result;
  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final visibleAlerts = alerts.take(3).toList(growable: false);
    final summary = _SafetySummary.fromResult(l10n, result);

    return Column(
      key: const Key('medicine-safety-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineSafetyPanelTitle,
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
        ),
        const SizedBox(height: AppSpacingTokens.level1),
        Text(
          l10n.medicineSafetyPanelSubtitle,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: context.theme.colors.mutedForeground),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SafetySummaryBanner(summary: summary),
                const SizedBox(height: AppSpacingTokens.level4),
                Wrap(
                  spacing: AppSpacingTokens.level2,
                  runSpacing: AppSpacingTokens.level2,
                  children: [
                    _SafetyMetricBadge(
                      label: l10n.medicineRiskCheckCurrentMedicinesLabel,
                      value: '${result?.currentMedicineCount ?? 0}',
                    ),
                    _SafetyMetricBadge(
                      label: l10n.medicineRiskCheckFindingsLabel,
                      value: '${result?.findingCount ?? 0}',
                    ),
                    _SafetyMetricBadge(
                      label: l10n.medicineRiskCheckCoverageLabel,
                      value: '${result?.coverageCount ?? 0}',
                    ),
                  ],
                ),
                if (visibleAlerts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.level4),
                  const AppDivider(),
                  const SizedBox(height: AppSpacingTokens.level3),
                  Column(
                    children: [
                      for (
                        var index = 0;
                        index < visibleAlerts.length;
                        index += 1
                      ) ...[
                        _SafetyAlertRow(
                          alert: visibleAlerts[index],
                          l10n: l10n,
                        ),
                        if (index < visibleAlerts.length - 1)
                          const AppDivider(),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetySummaryBanner extends StatelessWidget {
  const _SafetySummaryBanner({required this.summary});

  final _SafetySummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final accent = summary.color.resolve(colors);
    final iconColor = switch (summary.color) {
      AppColors.secondary => colors.mutedForeground,
      _ => accent,
    };
    final iconBackgroundColor = switch (summary.color) {
      AppColors.secondary => colors.secondary.withValues(alpha: 0.08),
      _ => accent.withValues(alpha: 0.12),
    };
    final titleColor = switch (summary.color) {
      AppColors.destructive => accent,
      _ => colors.foreground,
    };
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: accent.withValues(alpha: 0.08),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
          side: BorderSide(color: accent.withValues(alpha: 0.18)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FAvatar.raw(
              size: AppSpacingTokens.level8,
              style: .delta(backgroundColor: iconBackgroundColor),
              child: Icon(
                summary.icon,
                key: const Key('medicine-safety-summary-icon'),
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.title,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    summary.body,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push(AppRoutes.medicineRiskCheck),
              child: Text(l10n.medicineRiskCheckViewAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyMetricBadge extends StatelessWidget {
  const _SafetyMetricBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FBadge(
      variant: FBadgeVariant.secondary,
      style: .delta(
        decoration: .shapeDelta(
          color: colors.secondary.withValues(alpha: 0.08),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
            side: BorderSide(color: colors.border),
          ),
        ),
      ),
      child: Text(
        '$label  $value',
        style: AppTypographyToken.level3
            .body(context)
            .copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SafetyAlertRow extends StatelessWidget {
  const _SafetyAlertRow({required this.alert, required this.l10n});

  final MedicineAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: () => context.push(AppRoutes.medicineRiskCheck),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FAvatar.raw(
              size: AppSpacingTokens.level8,
              style: .delta(
                backgroundColor: alert.color
                    .resolve(colors)
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                alert.icon,
                color: alert.color.resolve(colors),
                size: AppSpacingTokens.level5,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineAlertTitle(l10n, alert),
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    medicineAlertBody(l10n, alert),
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.level5,
            ),
          ],
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
    required this.color,
  });

  final String title;
  final String body;
  final IconData icon;
  final AppColors color;

  static _SafetySummary fromResult(
    AppLocalizations l10n,
    MedicineRiskCheckResult? result,
  ) {
    if (result == null) {
      return _SafetySummary(
        title: l10n.medicineRiskCheckTierUncovered,
        body: l10n.medicineRiskCheckTierUncoveredDisclaimer,
        icon: FLucideIcons.circleAlert,
        color: AppColors.secondary,
      );
    }

    if (result.hasFindings) {
      return _SafetySummary(
        title: l10n.medicineRiskCheckTierConfirmedRisk,
        body: l10n.medicineRiskCheckFindingsTitle,
        icon: FLucideIcons.triangleAlert,
        color: AppColors.destructive,
      );
    }

    if (result.hasCoverageGaps) {
      return _SafetySummary(
        title: l10n.medicineRiskCheckTierUncovered,
        body: result.coverageSummary.isNotEmpty
            ? result.coverageSummary
            : l10n.medicineRiskCheckTierUncoveredDisclaimer,
        icon: FLucideIcons.circleAlert,
        color: AppColors.secondary,
      );
    }

    return _SafetySummary(
      title: l10n.medicineRiskCheckTierConfirmedSafe,
      body: l10n.medicineRiskCheckTierSafeDisclaimer,
      icon: FLucideIcons.badgeCheck,
      color: AppColors.primary,
    );
  }
}
