import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_dashboard.freezed.dart';

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
}

@freezed
abstract class RecordWeekDay with _$RecordWeekDay {
  const factory RecordWeekDay({
    required DateTime date,
    required int day,
    required RecordCopyKey weekdayKey,
    required bool selected,
    required List<Color> markers,
    @Default(false) bool hasAlert,
  }) = _RecordWeekDay;
}

@freezed
abstract class RecordCalendarDay with _$RecordCalendarDay {
  const factory RecordCalendarDay({
    required int day,
    required bool inMonth,
    required bool selected,
    required List<Color> markers,
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
    required Color accent,
    required Color softColor,
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
    required Color accent,
    required Color softColor,
  }) = _RecordSummaryItem;
}

@freezed
abstract class RecordFilter with _$RecordFilter {
  const factory RecordFilter({
    required RecordEntryType type,
    required RecordCopyKey titleKey,
    required IconData icon,
    required Color accent,
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
    required Color accent,
    required Color softColor,
    required RecordCopyKey titleKey,
    String? value,
    RecordCopyKey? valueKey,
    RecordCopyKey? unitKey,
    RecordCopyKey? detailKey,
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
    required Color color,
    required List<double> points,
    Color? secondaryColor,
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
