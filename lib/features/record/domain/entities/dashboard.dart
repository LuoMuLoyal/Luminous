import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/design/design.dart';

part 'dashboard.freezed.dart';

@freezed
abstract class RecordDashboard with _$RecordDashboard {
  const factory RecordDashboard({
    required DateTime selectedDate,
    required int selectedDay,
    required List<RecordWeekDay> weekDays,
    required List<RecordCalendarDay> monthDays,
    required List<RecordQuickAction> quickActions,
    required RecordDaySummary summary,
    required List<RecordFilter> filters,
    required List<RecordTimelineEntry> timeline,
    required List<RecordTrend> trends,
  }) = _RecordDashboard;

  /// A minimal dashboard for signed-out users with no real or mock data.
  /// Includes standard quick-actions and filters (UI structure only).
  static RecordDashboard signedOut(DateTime selectedDate) {
    return RecordDashboard(
      selectedDate: selectedDate,
      selectedDay: selectedDate.day,
      weekDays: _emptyWeekDays(selectedDate),
      monthDays: const <RecordCalendarDay>[],
      quickActions: _defaultQuickActions,
      summary: const RecordDaySummary(items: <RecordSummaryItem>[]),
      filters: _defaultFilters,
      timeline: const <RecordTimelineEntry>[],
      trends: const <RecordTrend>[],
    );
  }

  static List<RecordWeekDay> _emptyWeekDays(DateTime selectedDate) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final monday = date.subtract(Duration(days: date.weekday - 1));
    const weekdayKeys = <RecordCopyKey>[
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
      RecordCopyKey.weekdaySun,
    ];
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return RecordWeekDay(
        date: day,
        day: day.day,
        weekdayKey: weekdayKeys[i],
        selected:
            day.day == date.day &&
            day.month == date.month &&
            day.year == date.year,
        markers: const <SemanticColor>[],
      );
    });
  }

  static final _defaultQuickActions = <RecordQuickAction>[
    const RecordQuickAction(
      type: RecordEntryType.symptom,
      icon: SemanticIcons.medicineKit,
      titleKey: RecordCopyKey.typeSymptom,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.medication,
      icon: SemanticIcons.recordMedicine,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.water,
      icon: SemanticIcons.recordWater,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.summaryCupsUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.meal,
      icon: SemanticIcons.recordMeal,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.summaryTimesUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: SemanticIcons.recordMoon,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.mood,
      icon: SemanticIcons.recordMood,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.note,
      icon: SemanticIcons.tabRecord,
      titleKey: RecordCopyKey.typeNote,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static final _defaultFilters = <RecordFilter>[
    const RecordFilter(
      type: RecordEntryType.symptom,
      titleKey: RecordCopyKey.typeSymptom,
      icon: SemanticIcons.medicineKit,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: SemanticIcons.recordWater,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: SemanticIcons.recordMeal,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: SemanticIcons.recordMoon,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: SemanticIcons.recordMood,
      accent: SemanticColor.primary,
      selected: false,
    ),
    const RecordFilter(
      type: RecordEntryType.note,
      titleKey: RecordCopyKey.typeNote,
      icon: SemanticIcons.tabRecord,
      accent: SemanticColor.primary,
      selected: false,
    ),
  ];
}

@freezed
abstract class RecordWeekDay with _$RecordWeekDay {
  const factory RecordWeekDay({
    required DateTime date,
    required int day,
    required RecordCopyKey weekdayKey,
    required bool selected,
    required List<SemanticColor> markers,
    @Default(false) bool hasAlert,
  }) = _RecordWeekDay;
}

@freezed
abstract class RecordCalendarDay with _$RecordCalendarDay {
  const factory RecordCalendarDay({
    required int day,
    required bool inMonth,
    required bool selected,
    required List<SemanticColor> markers,
    @Default(false) bool hasAlert,
  }) = _RecordCalendarDay;
}

@freezed
abstract class RecordQuickAction with _$RecordQuickAction {
  const factory RecordQuickAction({
    required RecordEntryType type,
    required IconData icon,
    required RecordCopyKey titleKey,
    required RecordCopyKey subtitleKey,
    required SemanticColor accent,
    required SemanticColor softColor,
    @Default(false) bool locked,
  }) = _RecordQuickAction;
}

@freezed
abstract class RecordDaySummary with _$RecordDaySummary {
  const factory RecordDaySummary({required List<RecordSummaryItem> items}) =
      _RecordDaySummary;
}

@freezed
abstract class RecordSummaryItem with _$RecordSummaryItem {
  const factory RecordSummaryItem({
    required RecordEntryType type,
    required IconData icon,
    required RecordCopyKey titleKey,
    required String value,
    RecordCopyKey? unitKey,
    RecordCopyKey? detailKey,
    required SemanticColor accent,
    required SemanticColor softColor,
  }) = _RecordSummaryItem;
}

@freezed
abstract class RecordFilter with _$RecordFilter {
  const factory RecordFilter({
    required RecordEntryType type,
    required RecordCopyKey titleKey,
    required IconData icon,
    required SemanticColor accent,
    required bool selected,
    @Default(false) bool locked,
  }) = _RecordFilter;
}

@freezed
abstract class RecordTimelineEntry with _$RecordTimelineEntry {
  const factory RecordTimelineEntry({
    required String time,
    required RecordEntryType type,
    required IconData icon,
    required SemanticColor accent,
    required SemanticColor softColor,
    required RecordCopyKey titleKey,
    String? value,
    RecordCopyKey? valueKey,
    RecordCopyKey? unitKey,
    RecordCopyKey? detailKey,
    String? rawDetail,
    RecordCopyKey? badgeKey,
    RecordCopyKey? imagePlaceholderKey,
    String? imageUrl,
    IconData? trailingIcon,

    /// When non-null, the view should use this raw string instead of resolving
    /// [titleKey] through [recordCopy].
    String? rawTitle,

    /// When non-null, this timeline entry represents a real daily record
    /// that can be edited or deleted via the daily-record API.
    String? recordId,
  }) = _RecordTimelineEntry;
}

@freezed
abstract class RecordTrend with _$RecordTrend {
  const factory RecordTrend({
    required RecordTrendKind kind,
    required RecordCopyKey titleKey,
    required RecordCopyKey rangeKey,
    required SemanticColor color,
    required List<double> points,
    SemanticColor? secondaryColor,
    @Default([]) List<double> secondaryPoints,
    @Default([]) List<double> bars,
    RecordCopyKey? legendKey,
    RecordCopyKey? secondaryLegendKey,
  }) = _RecordTrend;
}

enum RecordEntryType {
  meal,
  vitals,
  water,
  mood,
  symptom,
  activity,
  medication,
  sleep,
  heartRate,
  weight,
  note,
}

enum RecordTrendKind { bloodSugar, hydration }

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
  typeSleep,
  typeHeartRate,
  typeWeight,
  typeNote,
  summaryMealTitle,
  summaryWaterTitle,
  summaryLatestVitalTitle,
  summaryMoodTitle,
  summaryTimesUnit,
  summaryCupsUnit,
  summaryRecorded,
  summaryNormal,
  timelineMealLunch,
  timelineMealName,
  timelineMealNutrition,
  timelineMealEstimateBadge,
  timelineMealAnalyzingBadge,
  timelineMealConfirmedBadge,
  timelineMealFailedBadge,
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
  timelineMoodGreat,
  timelineMoodGood,
  timelineMoodOkay,
  timelineMoodBad,
  timelineMoodTerrible,
  timelineSymptomRecord,
  timelineSymptomDetail,
  timelineSleepRecord,
  timelineSleepDetail,
  timelineHeartRateDetail,
  timelineWeightDetail,
  trendBloodSugarTitle,
  trendBloodSugarLegend,
  trendHydrationTitle,
  range7Days,
  range30Days,
  foodImagePlaceholder,
}
