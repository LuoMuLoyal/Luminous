import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:flutter/material.dart';
import 'package:luminous/features/today/domain/entities/today_ai_analysis.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Data model classes
// ---------------------------------------------------------------------------

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
  final Color color;
}

class TodayViewPriorityItem {
  const TodayViewPriorityItem({
    required this.key,
    required this.type,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.action,
    this.progress,
  });

  final Key key;
  final TodayPriorityItemType type;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String detail;
  final String action;
  final double? progress;
}

class TodayRecommendationItem {
  const TodayRecommendationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String action;
}

class TodayAiSummaryItem {
  const TodayAiSummaryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
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

enum TodayTodoType { medication, water, custom }

class TodayTodoItem {
  const TodayTodoItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.source,
    required this.action,
    required this.color,
    required this.completed,
    required this.statusIsDynamic,
    required this.subtitleIsDynamic,
  });

  final TodayTodoType type;
  final String title;
  final String subtitle;
  final String source;
  final String action;
  final Color color;
  final bool completed;
  final bool statusIsDynamic;
  final bool subtitleIsDynamic;
}

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------

String greetingSubtitle(AppLocalizations l10n, TodayDayMoment moment) {
  return switch (moment) {
    TodayDayMoment.morning => l10n.todayGreetingSubtitleMorning,
    TodayDayMoment.afternoon => l10n.todayGreetingSubtitleAfternoon,
    TodayDayMoment.evening => l10n.todayGreetingSubtitleEvening,
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
      if (value.isNotEmpty && value != '--') return value;
    }
  }
  return fallback;
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
      color: Color(0xFF0F766E),
    ),
    TodayOverviewItem(
      icon: FLucideIcons.droplets,
      label: l10n.todayHydrationOverviewLabel,
      value: l10n.todayWaterOverviewCount(
        dashboard.water.completedCount,
        dashboard.water.targetCount,
      ),
      color: Color(0xFF0F766E),
    ),
    TodayOverviewItem(
      icon: FLucideIcons.moonStar,
      label: l10n.todayVitalSleepLabel,
      value: '$sleep ${l10n.todayVitalSleepUnit}',
      color: Color(0xFF16A34A),
    ),
  ];
}

List<TodayViewPriorityItem> buildPriorityItems(
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
        TodayPriorityItemType.medication => TodayViewPriorityItem(
          key: const Key('today-medication-card'),
          type: TodayPriorityItemType.medication,
          icon: FLucideIcons.pill,
          color: Color(0xFF15803D),
          title: l10n.todayMedicationCardTitle,
          subtitle: l10n.todayMedicationPrioritySubtitle(
            item.count ?? dashboard.medication.pendingCount,
          ),
          detail: l10n.todayMedicationPriorityDetail(
            item.timeLabel ?? dashboard.medication.nextDoseTimeLabel,
            item.medicineName ?? nextMedicineName,
          ),
          action: l10n.todayMedicationTakeAction,
        ),
        TodayPriorityItemType.water => TodayViewPriorityItem(
          key: const Key('today-water-card'),
          type: TodayPriorityItemType.water,
          icon: FLucideIcons.droplets,
          color: Color(0xFF0F766E),
          title: l10n.todayWaterPriorityTitle,
          subtitle: l10n.todayWaterGoalCount(
            item.targetCount ?? dashboard.water.targetCount,
          ),
          detail: l10n.todayWaterCount(
            item.count ?? dashboard.water.completedCount,
          ),
          action: l10n.todayDrinkWaterAction,
          progress: item.progress ?? dashboard.water.progress,
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

List<TodayRecommendationItem> buildRecommendationItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  return [
    TodayRecommendationItem(
      icon: FLucideIcons.shieldPlus,
      color: Color(0xFF0F766E),
      title: l10n.todayRecommendationMedicineSafetyTitle,
      subtitle: l10n.todayRecommendationMedicineSafetyBody,
      action: l10n.todayLearnMoreAction,
    ),
    TodayRecommendationItem(
      icon: FLucideIcons.moonStar,
      color: Color(0xFF16A34A),
      title: l10n.todayRecommendationSleepTitle,
      subtitle: l10n.todayRecommendationSleepBody,
      action: l10n.todayLearnMoreAction,
    ),
    TodayRecommendationItem(
      icon: FLucideIcons.droplets,
      color: Color(0xFF0F766E),
      title: l10n.todayRecommendationWaterTitle,
      subtitle: l10n.todayRecommendationWaterBody,
      action: dashboard.water.progress >= 1
          ? l10n.todayStatusCompleted
          : l10n.todayCompleteAction,
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
      icon: Icons.medication_liquid_outlined,
      color: Color(0xFF15803D),
      text: hasMedicationRisk
          ? l10n.todayAiSummaryMedicationPending(
              dashboard.medication.pendingCount,
            )
          : l10n.todayAiSummaryMedicationDone,
    ),
    TodayAiSummaryItem(
      icon: Icons.local_drink_outlined,
      color: waterRemaining == 0 ? Color(0xFF0F766E) : Color(0xFFF59E0B),
      text: waterRemaining == 0
          ? l10n.todayAiSummaryWaterDone
          : l10n.todayAiSummaryWaterRemaining(waterRemaining),
    ),
    TodayAiSummaryItem(
      icon: Icons.bedtime_outlined,
      color: Color(0xFF7C3AED),
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
          icon: FLucideIcons.badgeAlert,
          color: Color(0xFFF59E0B),
          text: l10n.todayAiSummarySignedOutHint,
        ),
      ],
      footer: l10n.todayAiSummarySignedOutHint,
    );
  }

  if (aiSummariesEnabled == false || aiState.isDisabled) {
    return TodayAiSummaryCardContent(
      bullets: [
        TodayAiSummaryItem(
          icon: FLucideIcons.brain,
          color: Color(0xFF16A34A),
          text: l10n.todayAiSummaryDisabledHint,
        ),
      ],
      footer: l10n.todayAiSummaryDisabledHint,
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
          color: Color(0xFFF59E0B),
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
          color: Color(0xFF0F766E),
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

  final color = switch (bullet.kind) {
    TodayAiAnalysisBulletKind.medication => Color(0xFF15803D),
    TodayAiAnalysisBulletKind.hydration => Color(0xFF0F766E),
    TodayAiAnalysisBulletKind.sleep => Color(0xFF7C3AED),
    TodayAiAnalysisBulletKind.general => Color(0xFF16A34A),
  };

  return TodayAiSummaryItem(icon: icon, color: color, text: bullet.text);
}

List<TodayTodoItem> buildTodoItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final nextMedicineName =
      dashboard.medication.nextMedicineName ??
      medicationName(l10n, dashboard.medication.nextMedicine);
  final waterProgressPercent = (dashboard.water.progress * 100).round();

  return [
    TodayTodoItem(
      type: TodayTodoType.medication,
      title: l10n.todayTodoMedicationTitle,
      subtitle: l10n.todayTodoMedicationSubtitle(
        dashboard.medication.nextDoseTimeLabel,
        nextMedicineName,
      ),
      source: l10n.todayTodoSourceSystem,
      action: dashboard.medication.pendingCount == 0
          ? l10n.todayStatusCompleted
          : l10n.todayMedicationTakeAction,
      color: Color(0xFF15803D),
      completed: dashboard.medication.pendingCount == 0,
      statusIsDynamic: true,
      subtitleIsDynamic: true,
    ),
    TodayTodoItem(
      type: TodayTodoType.water,
      title: l10n.todayTodoWaterTitle,
      subtitle: l10n.todayTodoWaterSubtitle(waterProgressPercent),
      source: l10n.todayTodoSourceSystem,
      action: dashboard.water.progress >= 1
          ? l10n.todayStatusCompleted
          : l10n.todayDrinkWaterAction,
      color: Color(0xFF0F766E),
      completed: dashboard.water.progress >= 1,
      statusIsDynamic: true,
      subtitleIsDynamic: true,
    ),
    TodayTodoItem(
      type: TodayTodoType.custom,
      title: l10n.todayTodoCustomTitle,
      subtitle: l10n.todayTodoCustomSubtitle,
      source: l10n.todayTodoSourceUser,
      action: l10n.todayTodoAddAction,
      color: Color(0xFFF59E0B),
      completed: false,
      statusIsDynamic: false,
      subtitleIsDynamic: false,
    ),
  ];
}
