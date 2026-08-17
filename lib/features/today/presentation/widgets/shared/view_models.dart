import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayOverviewItem {
  const TodayOverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isFallback = false,
    this.isDegraded = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final SemanticColor color;

  /// True when [value] is a placeholder (e.g. "未记录") rather than real data.
  /// Used to de-emphasize the text visually.
  final bool isFallback;

  /// True when the upstream data source for this metric failed and [value]
  /// should be rendered as "Temporarily unavailable".
  final bool isDegraded;
}

class TodayAiSummaryItem {
  const TodayAiSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final SemanticColor color;
  final String text;
}

class TodayAiSummaryCardContent {
  const TodayAiSummaryCardContent({
    required this.bullets,
    this.summary,
    this.footer,
  });

  final String? summary;
  final List<TodayAiSummaryItem> bullets;
  final String? footer;
}

class TodayQuickActionItem {
  const TodayQuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.usePush = false,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final bool usePush;
  final String? badge;

  /// Optional custom tap handler. When non-null it is invoked instead of
  /// navigating to [route]; this is used by the one-tap water quick-entry.
  final VoidCallback? onTap;
}

String greetingSubtitle(AppLocalizations l10n, TodayDashboard dashboard) {
  final moment = dashboard.user.moment;
  final hasPendingMeds = dashboard.medication.pendingCount > 0;
  final hasWaterRemaining = dashboard.water.remainingCount > 0;

  return switch (moment) {
    TodayDayMoment.morning =>
      hasPendingMeds
          ? l10n.todayGreetingMorningPending(dashboard.medication.pendingCount)
          : l10n.todayGreetingMorningClear,
    TodayDayMoment.afternoon =>
      hasWaterRemaining
          ? l10n.todayGreetingAfternoonWaterShort(
              dashboard.water.remainingCount,
            )
          : l10n.todayGreetingAfternoonWaterDone,
    TodayDayMoment.evening =>
      hasPendingMeds
          ? l10n.todayGreetingEveningPending(dashboard.medication.pendingCount)
          : l10n.todayGreetingEveningAllDone,
  };
}

String medicationName(AppLocalizations l10n, TodayMedicationKind kind) {
  return switch (kind) {
    TodayMedicationKind.atorvastatin => l10n.todayMedicationNameAtorvastatin,
    TodayMedicationKind.vitaminBComplex =>
      l10n.todayMedicationNameVitaminBComplex,
  };
}

String vitalValue(
  List<TodayVitalSummary> vitals,
  TodayVitalType type, {
  required String fallback,
}) {
  for (final vital in vitals) {
    if (vital.type == type) {
      final value = vital.valueLabel.trim();
      if (value.isNotEmpty && value != '--') {
        return value;
      }
    }
  }
  return fallback;
}

bool hasMeaningfulVitalValue(
  List<TodayVitalSummary> vitals,
  TodayVitalType type,
) {
  for (final vital in vitals) {
    if (vital.type != type) {
      continue;
    }
    final value = vital.valueLabel.trim();
    return value.isNotEmpty && value != '--';
  }
  return false;
}

List<TodayOverviewItem> buildOverviewItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final sleepVital = dashboard.vitals.firstWhereOrNull(
    (v) => v.type == TodayVitalType.sleep,
  );
  final sleepDegraded =
      sleepVital?.observedMetric?.state == TodayObservedMetricState.degraded;
  final sleepIsFallback =
      !sleepDegraded &&
      !hasMeaningfulVitalValue(dashboard.vitals, TodayVitalType.sleep);
  final sleep = sleepDegraded
      ? l10n.todayMetricDegraded
      : vitalValue(
          dashboard.vitals,
          TodayVitalType.sleep,
          fallback: l10n.todaySleepFallbackValue,
        );

  final medicationDegraded =
      dashboard.medication.observedMetric?.state ==
      TodayObservedMetricState.degraded;
  final medicationDone = dashboard.medication.medicineCount == 0
      ? 0
      : dashboard.medication.medicineCount - dashboard.medication.pendingCount;
  final safeMedicationDone = medicationDone < 0 ? 0 : medicationDone;

  final waterDegraded =
      dashboard.water.observedMetric?.state ==
      TodayObservedMetricState.degraded;

  return [
    TodayOverviewItem(
      icon: SemanticIcons.recordMedicine,
      label: l10n.todayMedicationOverviewLabel,
      value: medicationDegraded
          ? l10n.todayMetricDegraded
          : l10n.todayMedicationOverviewCount(
              safeMedicationDone,
              dashboard.medication.medicineCount,
            ),
      color: SemanticColor.primary,
      isDegraded: medicationDegraded,
    ),
    TodayOverviewItem(
      icon: SemanticIcons.recordWater,
      label: l10n.todayHydrationOverviewLabel,
      value: waterDegraded
          ? l10n.todayMetricDegraded
          : _waterOverviewValue(l10n, dashboard.water),
      color: SemanticColor.primary,
      isDegraded: waterDegraded,
    ),
    TodayOverviewItem(
      icon: SemanticIcons.recordSleep,
      label: l10n.todayVitalSleepLabel,
      value: sleep,
      color: SemanticColor.primary,
      isFallback: sleepIsFallback,
      isDegraded: sleepDegraded,
    ),
  ];
}

String _waterOverviewValue(AppLocalizations l10n, TodayWaterSummary water) {
  final observedMl = water.observedMl;
  if (observedMl != null) {
    return l10n.todayWaterOverviewMl(observedMl.round(), water.targetMl);
  }
  if (water.observedMetric != null) {
    return l10n.todayWaterOverviewUnknown(water.targetMl);
  }
  return l10n.todayWaterOverviewCount(water.completedCount, water.targetCount);
}

List<TodayAiSummaryItem> buildAiSummaryBullets(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final waterRemaining = dashboard.water.remainingCount;
  final hasMedicationRisk = dashboard.medication.pendingCount > 0;

  return [
    TodayAiSummaryItem(
      icon: SemanticIcons.recordMedicine,
      color: SemanticColor.primary,
      text: hasMedicationRisk
          ? l10n.todayAiSummaryMedicationPending(
              dashboard.medication.pendingCount,
            )
          : l10n.todayAiSummaryMedicationDone,
    ),
    TodayAiSummaryItem(
      icon: SemanticIcons.recordWater,
      color: SemanticColor.primary,
      text: waterRemaining == 0
          ? l10n.todayAiSummaryWaterDone
          : l10n.todayAiSummaryWaterRemaining(waterRemaining),
    ),
    TodayAiSummaryItem(
      icon: SemanticIcons.recordSleep,
      color: SemanticColor.primary,
      text: l10n.todayAiSummarySleepPlaceholder,
    ),
  ];
}

TodayAiSummaryCardContent buildAiCardContent({
  required AppLocalizations l10n,
  required TodayDashboard dashboard,
  required bool canAccessProtectedData,
  required bool? aiSummariesEnabled,
  required TodayAiAnalysisCardState aiState,
}) {
  if (!canAccessProtectedData) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: SemanticIcons.aiEntry,
          color: SemanticColor.primary,
          text: l10n.todayAiSummaryPreviewHint,
        ),
      ],
    );
  }

  if (aiSummariesEnabled == false || aiState.isDisabled) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: SemanticIcons.aiSuggestion,
          color: SemanticColor.primary,
          text: l10n.todayAiSummaryDisabledHint,
        ),
      ],
    );
  }

  final analysis = aiState.analysis;
  final materializationStatus = aiState.materializationStatus;

  if (materializationStatus == TodayAiAnalysisMaterializationStatus.empty) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: SemanticIcons.aiEntry,
          color: SemanticColor.primary,
          text: l10n.todayAnalysisEmptyTitle,
        ),
      ],
      footer: l10n.todayAnalysisEmptyBody,
    );
  }

  if (analysis != null) {
    return TodayAiSummaryCardContent(
      summary: analysis.summary,
      bullets: analysis.bullets.map(mapAiBullet).toList(growable: false),
      footer: analysis.confidenceNote,
    );
  }

  if (aiState.status == TodayAiAnalysisCardStatus.error) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: SemanticIcons.statusError,
          color: SemanticColor.primary,
          text: l10n.todayAiSummaryErrorHint,
        ),
        ...buildAiSummaryBullets(l10n, dashboard),
      ],
      footer: aiState.errorMessage ?? l10n.todayAiSummaryErrorHint,
    );
  }

  if (aiState.status == TodayAiAnalysisCardStatus.loading) {
    return TodayAiSummaryCardContent(
      summary: aiState.streamingSummary,
      bullets: [
        TodayAiSummaryItem(
          icon: SemanticIcons.aiAnalyzing,
          color: SemanticColor.primary,
          text: l10n.todayAiSummaryGeneratingHint,
        ),
        ...buildAiSummaryBullets(l10n, dashboard),
      ],
      footer: l10n.todayAiSummaryGeneratingHint,
    );
  }

  return TodayAiSummaryCardContent(
    bullets: buildAiSummaryBullets(l10n, dashboard),
    footer: l10n.todayAiSummaryDefaultHint,
  );
}

TodayAiSummaryItem mapAiBullet(TodayAiAnalysisBullet bullet) {
  final icon = switch (bullet.kind) {
    TodayAiAnalysisBulletKind.medication => SemanticIcons.recordMedicine,
    TodayAiAnalysisBulletKind.hydration => SemanticIcons.recordWater,
    TodayAiAnalysisBulletKind.sleep => SemanticIcons.recordSleep,
    TodayAiAnalysisBulletKind.general => SemanticIcons.aiTip,
  };

  return TodayAiSummaryItem(
    icon: icon,
    color: SemanticColor.primary,
    text: bullet.text,
  );
}

/// Build quick action items. The first two items (confirm + water) are
/// "primary" actions that show status-aware subtitles. The remaining items
/// are "secondary" and should be displayed under a "more" toggle.
///
/// Navigation semantics:
/// - Actions targeting a tab root (e.g. [Routes.medicine]) use
///   `usePush: false` → `context.go`, which replaces the current route so
///   the user lands on the tab's home screen.
/// - Actions targeting a sub-page (e.g. record create) use `usePush: true`
///   → `context.push`, preserving the back stack so the user can return.
///
/// [onWaterQuickEntry] is invoked by the one-tap water action instead of
/// navigating to the record create route.
List<TodayQuickActionItem> buildQuickActionItems(
  AppLocalizations l10n,
  TodayDashboard dashboard, {
  VoidCallback? onWaterQuickEntry,
}) {
  final hasPending = dashboard.medication.pendingCount > 0;
  final confirmSubtitle = hasPending
      ? l10n.todayQuickActionConfirmPendingSubtitle(
          dashboard.medication.pendingCount,
        )
      : l10n.todayQuickActionConfirmDoneSubtitle;
  final confirmBadge = hasPending
      ? '${dashboard.medication.pendingCount}'
      : null;

  return [
    TodayQuickActionItem(
      icon: SemanticIcons.doseTaken,
      title: l10n.todayQuickActionConfirmTitle,
      subtitle: confirmSubtitle,
      route: Routes.medicine,
      badge: confirmBadge,
    ),
    TodayQuickActionItem(
      icon: SemanticIcons.recordWater,
      title: l10n.todayDrinkWaterAction,
      subtitle: l10n.todayQuickActionWaterSubtitle,
      route: '${Routes.recordCreate}?kind=water',
      usePush: true,
      onTap: onWaterQuickEntry,
    ),
    TodayQuickActionItem(
      icon: SemanticIcons.safetyCaution,
      title: l10n.todayQuickActionExplainTitle,
      subtitle: l10n.todayQuickActionExplainSubtitle,
      route: Routes.medicineRiskCheck,
    ),
    TodayQuickActionItem(
      icon: SemanticIcons.doseSchedule,
      title: l10n.todayQuickActionReminderTitle,
      subtitle: l10n.todayQuickActionReminderSubtitle,
      route: Routes.medicineRemindersNew,
      usePush: true,
    ),
    TodayQuickActionItem(
      icon: SemanticIcons.profileUser,
      title: l10n.todayQuickActionProfileTitle,
      subtitle: l10n.todayQuickActionProfileSubtitle,
      route: Routes.mine,
    ),
  ];
}

/// Pushes [route] onto the navigation stack.
///
/// Always uses [context.push] so the user can navigate back from the
/// destination — [context.go] would replace the current route and leave
/// no back path, which is inconsistent with the rest of the app.
void openRoute(BuildContext context, String route) {
  unawaited(context.push(route));
}
