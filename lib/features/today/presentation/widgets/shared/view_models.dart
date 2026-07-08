import 'package:luminous/app/router.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/shared/card_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayOverviewItem {
  const TodayOverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppColors color;
}

class TodaySuggestionItem {
  const TodaySuggestionItem({
    required this.key,
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.reason,
    required this.evidence,
    required this.boundary,
    required this.action,
    this.progress,
  });

  final Key key;
  final TodayPriorityItemType type;
  final IconData icon;
  final AppColors color;
  final String title;
  final String reason;
  final String evidence;
  final String boundary;
  final String action;
  final double? progress;

  /// Resolve the [TodayCardTone] for this suggestion based on its type.
  TodayCardTone get cardTone => switch (type) {
    TodayPriorityItemType.medication => TodayCardTone.urgent,
    TodayPriorityItemType.water => TodayCardTone.emphasis,
  };
}

class TodayAiSummaryItem {
  const TodayAiSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final AppColors color;
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final bool usePush;
  final String? badge;
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
  final sleep = vitalValue(
    dashboard.vitals,
    TodayVitalType.sleep,
    fallback: l10n.todaySleepFallbackValue,
  );
  final medicationDone = dashboard.medication.medicineCount == 0
      ? 0
      : dashboard.medication.medicineCount - dashboard.medication.pendingCount;
  final safeMedicationDone = medicationDone < 0 ? 0 : medicationDone;

  return [
    TodayOverviewItem(
      icon: FLucideIcons.pill,
      label: l10n.todayMedicationOverviewLabel,
      value: '$safeMedicationDone/${dashboard.medication.medicineCount}',
      color: AppColors.primary,
    ),
    TodayOverviewItem(
      icon: FLucideIcons.droplets,
      label: l10n.todayHydrationOverviewLabel,
      value: l10n.todayWaterOverviewCount(
        dashboard.water.completedCount,
        dashboard.water.targetCount,
      ),
      color: AppColors.primary,
    ),
    TodayOverviewItem(
      icon: FLucideIcons.moonStar,
      label: l10n.todayVitalSleepLabel,
      value: '$sleep ${l10n.todayVitalSleepUnit}',
      color: AppColors.primary,
    ),
  ];
}

List<TodaySuggestionItem> buildSuggestionItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final nextMedicineName =
      dashboard.medication.nextMedicineName ??
      medicationName(l10n, dashboard.medication.nextMedicine);
  final sourceItems = dashboard.priorityItems.isEmpty
      ? _fallbackPriorityItems(dashboard)
      : dashboard.priorityItems;

  return [
    for (final item in sourceItems)
      switch (item.type) {
        TodayPriorityItemType.medication => TodaySuggestionItem(
          key: const Key('today-medication-suggestion'),
          type: TodayPriorityItemType.medication,
          icon: FLucideIcons.pill,
          color: AppColors.destructive,
          title: l10n.todayMedicationSuggestionTitle,
          reason: l10n.todayMedicationPrioritySubtitle(
            item.count ?? dashboard.medication.pendingCount,
          ),
          evidence: l10n.todayMedicationPriorityDetail(
            item.timeLabel ?? dashboard.medication.nextDoseTimeLabel,
            item.medicineName ?? nextMedicineName,
          ),
          boundary: l10n.todayMedicationSuggestionBoundary,
          action: l10n.todayMedicationTakeAction,
        ),
        TodayPriorityItemType.water => TodaySuggestionItem(
          key: const Key('today-water-suggestion'),
          type: TodayPriorityItemType.water,
          icon: FLucideIcons.droplets,
          color: AppColors.primary,
          title: l10n.todayWaterSuggestionTitle(dashboard.water.remainingCount),
          reason: l10n.todayWaterSuggestionReason(
            dashboard.water.completedCount,
            dashboard.water.targetCount,
          ),
          evidence: l10n.todayWaterCount(dashboard.water.completedCount),
          boundary: l10n.todayWaterSuggestionBoundary,
          action: l10n.todayDrinkWaterAction,
          progress: dashboard.water.progress,
        ),
      },
  ];
}

List<TodayPriorityItem> _fallbackPriorityItems(TodayDashboard dashboard) {
  return [
    TodayPriorityItem(
      id: 'medication',
      type: TodayPriorityItemType.medication,
      count: dashboard.medication.pendingCount,
      timeLabel: dashboard.medication.nextDoseTimeLabel,
      medicineName: dashboard.medication.nextMedicineName,
    ),
    TodayPriorityItem(
      id: 'water',
      type: TodayPriorityItemType.water,
      count: dashboard.water.completedCount,
      targetCount: dashboard.water.targetCount,
      progress: dashboard.water.progress,
    ),
  ];
}

List<TodayAiSummaryItem> buildAiSummaryBullets(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final waterRemaining = dashboard.water.remainingCount;
  final hasMedicationRisk = dashboard.medication.pendingCount > 0;

  return [
    TodayAiSummaryItem(
      icon: FLucideIcons.pill,
      color: AppColors.primary,
      text: hasMedicationRisk
          ? l10n.todayAiSummaryMedicationPending(
              dashboard.medication.pendingCount,
            )
          : l10n.todayAiSummaryMedicationDone,
    ),
    TodayAiSummaryItem(
      icon: FLucideIcons.cupSoda,
      color: AppColors.primary,
      text: waterRemaining == 0
          ? l10n.todayAiSummaryWaterDone
          : l10n.todayAiSummaryWaterRemaining(waterRemaining),
    ),
    TodayAiSummaryItem(
      icon: FLucideIcons.bed,
      color: AppColors.primary,
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
          icon: FLucideIcons.sparkles,
          color: AppColors.primary,
          text: l10n.todayAiSummaryPreviewHint,
        ),
      ],
    );
  }

  if (aiSummariesEnabled == false || aiState.isDisabled) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: FLucideIcons.brain,
          color: AppColors.primary,
          text: l10n.todayAiSummaryDisabledHint,
        ),
      ],
    );
  }

  final analysis = aiState.analysis;
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
          icon: FLucideIcons.badgeAlert,
          color: AppColors.primary,
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
          icon: FLucideIcons.refreshCw,
          color: AppColors.primary,
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
    TodayAiAnalysisBulletKind.medication => FLucideIcons.pill,
    TodayAiAnalysisBulletKind.hydration => FLucideIcons.droplets,
    TodayAiAnalysisBulletKind.sleep => FLucideIcons.moonStar,
    TodayAiAnalysisBulletKind.general => FLucideIcons.lightbulb,
  };

  return TodayAiSummaryItem(
    icon: icon,
    color: AppColors.primary,
    text: bullet.text,
  );
}

/// Build quick action items. The first two items (confirm + record) are
/// "primary" actions that show status-aware subtitles. The remaining items
/// are "secondary" and should be displayed under a "more" toggle.
List<TodayQuickActionItem> buildQuickActionItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
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
      icon: FLucideIcons.badgeCheck,
      title: l10n.todayQuickActionConfirmTitle,
      subtitle: confirmSubtitle,
      route: AppRoutes.medicine,
      badge: confirmBadge,
    ),
    TodayQuickActionItem(
      icon: FLucideIcons.filePenLine,
      title: l10n.todayQuickActionRecordTitle,
      subtitle: l10n.todayQuickActionRecordSubtitle,
      route: '${AppRoutes.recordCreate}?kind=water',
      usePush: true,
    ),
    TodayQuickActionItem(
      icon: FLucideIcons.shieldPlus,
      title: l10n.todayQuickActionExplainTitle,
      subtitle: l10n.todayQuickActionExplainSubtitle,
      route: AppRoutes.medicine,
    ),
    TodayQuickActionItem(
      icon: FLucideIcons.alarmClockCheck,
      title: l10n.todayQuickActionReminderTitle,
      subtitle: l10n.todayQuickActionReminderSubtitle,
      route: AppRoutes.medicine,
    ),
    TodayQuickActionItem(
      icon: FLucideIcons.userRound,
      title: l10n.todayQuickActionProfileTitle,
      subtitle: l10n.todayQuickActionProfileSubtitle,
      route: AppRoutes.mine,
    ),
  ];
}

/// Determine whether the "no records" hint should be shown.
bool shouldShowRecordHint(TodayDashboard dashboard) {
  final hasWater = dashboard.water.completedCount > 0;
  final hasMeds = dashboard.medication.medicineCount > 0;
  final hasVitals = dashboard.vitals.isNotEmpty;
  return !hasWater && !hasMeds && !hasVitals;
}
