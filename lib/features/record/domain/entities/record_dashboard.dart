import 'package:flutter/material.dart';

class RecordDashboard {
  const RecordDashboard({
    required this.selectedDay,
    required this.weekDays,
    required this.monthDays,
    required this.quickActions,
    required this.summary,
    required this.filters,
    required this.timeline,
    required this.trends,
    required this.healthBag,
  });

  final int selectedDay;
  final List<RecordWeekDay> weekDays;
  final List<RecordCalendarDay> monthDays;
  final List<RecordQuickAction> quickActions;
  final RecordDaySummary summary;
  final List<RecordFilter> filters;
  final List<RecordTimelineEntry> timeline;
  final List<RecordTrend> trends;
  final RecordHealthBag healthBag;
}

class RecordWeekDay {
  const RecordWeekDay({
    required this.day,
    required this.weekdayKey,
    required this.selected,
    required this.markers,
    this.hasAlert = false,
  });

  final int day;
  final RecordCopyKey weekdayKey;
  final bool selected;
  final List<Color> markers;
  final bool hasAlert;
}

class RecordCalendarDay {
  const RecordCalendarDay({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.markers,
    this.hasAlert = false,
  });

  final int day;
  final bool inMonth;
  final bool selected;
  final List<Color> markers;
  final bool hasAlert;
}

class RecordQuickAction {
  const RecordQuickAction({
    required this.type,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.accent,
    required this.softColor,
  });

  final RecordEntryType type;
  final IconData icon;
  final RecordCopyKey titleKey;
  final RecordCopyKey subtitleKey;
  final Color accent;
  final Color softColor;
}

class RecordDaySummary {
  const RecordDaySummary({required this.items});

  final List<RecordSummaryItem> items;
}

class RecordSummaryItem {
  const RecordSummaryItem({
    required this.type,
    required this.icon,
    required this.titleKey,
    required this.value,
    this.unitKey,
    this.detailKey,
    required this.accent,
    required this.softColor,
  });

  final RecordEntryType type;
  final IconData icon;
  final RecordCopyKey titleKey;
  final String value;
  final RecordCopyKey? unitKey;
  final RecordCopyKey? detailKey;
  final Color accent;
  final Color softColor;
}

class RecordFilter {
  const RecordFilter({
    required this.type,
    required this.titleKey,
    required this.icon,
    required this.accent,
    required this.selected,
    this.locked = false,
  });

  final RecordEntryType type;
  final RecordCopyKey titleKey;
  final IconData icon;
  final Color accent;
  final bool selected;
  final bool locked;
}

class RecordTimelineEntry {
  const RecordTimelineEntry({
    required this.time,
    required this.type,
    required this.icon,
    required this.accent,
    required this.softColor,
    required this.titleKey,
    this.value,
    this.valueKey,
    this.unitKey,
    this.detailKey,
    this.badgeKey,
    this.imagePlaceholderKey,
    this.trailingIcon,
    this.rawTitle,
    this.recordId,
    this.recordDate,
  });

  final String time;
  final RecordEntryType type;
  final IconData icon;
  final Color accent;
  final Color softColor;
  final RecordCopyKey titleKey;
  final String? value;
  final RecordCopyKey? valueKey;
  final RecordCopyKey? unitKey;
  final RecordCopyKey? detailKey;
  final RecordCopyKey? badgeKey;
  final RecordCopyKey? imagePlaceholderKey;
  final IconData? trailingIcon;

  /// When non-null, the view should use this raw string instead of resolving
  /// [titleKey] through [recordCopy].
  final String? rawTitle;

  /// When non-null, this timeline entry represents a real daily record
  /// that can be edited or deleted via the daily-record API.
  final String? recordId;

  /// Date used by the list API to retrieve [recordId] for editing.
  final String? recordDate;
}

class RecordTrend {
  const RecordTrend({
    required this.kind,
    required this.titleKey,
    required this.rangeKey,
    required this.color,
    required this.points,
    this.secondaryColor,
    this.secondaryPoints = const <double>[],
    this.bars = const <double>[],
    this.legendKey,
    this.secondaryLegendKey,
  });

  final RecordTrendKind kind;
  final RecordCopyKey titleKey;
  final RecordCopyKey rangeKey;
  final Color color;
  final List<double> points;
  final Color? secondaryColor;
  final List<double> secondaryPoints;
  final List<double> bars;
  final RecordCopyKey? legendKey;
  final RecordCopyKey? secondaryLegendKey;
}

class RecordHealthBag {
  const RecordHealthBag({
    required this.titleKey,
    required this.bodyKey,
    required this.latestKey,
    required this.nextKey,
  });

  final RecordCopyKey titleKey;
  final RecordCopyKey bodyKey;
  final RecordCopyKey latestKey;
  final RecordCopyKey nextKey;
}

enum RecordEntryType {
  meal,
  vitals,
  water,
  mood,
  symptom,
  activity,
  medication,
  womenHealth,
  heartRate,
  weight,
}

enum RecordTrendKind { bloodSugar, sleepMood, hydration }

enum RecordCopyKey {
  weekdaySun,
  weekdayMon,
  weekdayTue,
  weekdayWed,
  weekdayThu,
  weekdayFri,
  weekdaySat,
  typeMeal,
  typeVitals,
  typeWater,
  typeMood,
  typeSymptom,
  typeActivity,
  typeMedication,
  typeWomenHealth,
  typeHeartRate,
  typeWeight,
  quickWomenSubtitle,
  summaryMealTitle,
  summaryWaterTitle,
  summaryLatestVitalTitle,
  summaryMoodTitle,
  summaryActivityTitle,
  summaryTimesUnit,
  summaryCupsUnit,
  summaryRecorded,
  summaryNormal,
  timelineMealLunch,
  timelineMealName,
  timelineMealNutrition,
  timelineAiBadge,
  timelineBloodPressure,
  timelineBloodPressureDetail,
  timelineManualBadge,
  timelineWaterAmount,
  timelineWaterProgress,
  timelineMedicationName,
  timelineMedicationDetail,
  timelineMoodCalm,
  timelineMoodDetail,
  timelineHeartRateDetail,
  timelineActivityWalk,
  timelineActivityDetail,
  timelineWeightDetail,
  trendBloodSugarTitle,
  trendBloodSugarLegend,
  trendSleepMoodTitle,
  trendSleepLegend,
  trendMoodLegend,
  trendHydrationTitle,
  range7Days,
  range30Days,
  healthBagTitle,
  healthBagBody,
  healthBagLatest,
  healthBagNext,
  foodImagePlaceholder,
}
