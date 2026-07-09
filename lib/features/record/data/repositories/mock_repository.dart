import 'package:luminous/core/design/semantic_color.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/data/providers/providers.dart';
import 'package:luminous/features/record/data/repositories/lucent_repository.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/repositories/repository.dart';

/// Demo-only mock implementation of [RecordRepository] used for tests.
///
/// Vital/record values are intentionally placeholder so they cannot be
/// mistaken for real health data.
class MockRecordRepository implements RecordRepository {
  const MockRecordRepository();

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => fetchDashboard(selectedDate, filterType: filterType);

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    return dashboardFor(selectedDate, filterType: filterType);
  }

  static RecordDashboard dashboardFor(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) {
    final filters = _filtersFor(filterType);
    final timeline = _timelineFor(filterType);

    return RecordDashboard(
      selectedDate: selectedDate,
      selectedDay: selectedDate.day,
      weekDays: _weekDaysFor(selectedDate),
      monthDays: _monthDays,
      quickActions: _quickActionsFor(),
      summary: RecordDaySummary(items: _summaryItems),
      filters: filters,
      timeline: timeline,
      trends: _trends,
    );
  }

  static List<RecordWeekDay> _weekDaysFor(DateTime selectedDate) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final markerPattern = <List<SemanticColor>>[
      <SemanticColor>[SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary, SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary],
      <SemanticColor>[SemanticColor.primary],
    ];

    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return RecordWeekDay(
        date: day,
        day: day.day,
        weekdayKey: _weekdayKey(day.weekday),
        selected: _isSameDay(day, date),
        markers: markerPattern[index],
        hasAlert: index == 5,
      );
    });
  }

  static final _monthDays = <RecordCalendarDay>[
    const RecordCalendarDay(
      day: 28,
      inMonth: false,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 29,
      inMonth: false,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 30,
      inMonth: false,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 1,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 2,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 3,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 4,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 5,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 6,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 7,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 8,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 9,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 10,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 11,
      inMonth: true,
      selected: false,
      markers: [],
    ),
    const RecordCalendarDay(
      day: 12,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 13,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 14,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 15,
      inMonth: true,
      selected: true,
      markers: <SemanticColor>[SemanticColor.primary, SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 16,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 17,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
      hasAlert: true,
    ),
    const RecordCalendarDay(
      day: 18,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 19,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 20,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 21,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 22,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 23,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 24,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 25,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 26,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 27,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 28,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 29,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 30,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 31,
      inMonth: true,
      selected: false,
      markers: <SemanticColor>[SemanticColor.primary],
    ),
    const RecordCalendarDay(
      day: 1,
      inMonth: false,
      selected: false,
      markers: [],
    ),
  ];

  static final _quickActions = <RecordQuickAction>[
    const RecordQuickAction(
      type: RecordEntryType.meal,
      icon: FLucideIcons.utensils,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.summaryTimesUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.vitals,
      icon: FLucideIcons.heart,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.summaryNormal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.water,
      icon: FLucideIcons.cupSoda,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.summaryCupsUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.symptom,
      icon: FLucideIcons.thermometer,
      titleKey: RecordCopyKey.typeSymptom,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.medication,
      icon: FLucideIcons.pill,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    // Lightweight mood self-check-in quick action.
    const RecordQuickAction(
      type: RecordEntryType.mood,
      icon: FLucideIcons.smile,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: FLucideIcons.moon,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.note,
      icon: FLucideIcons.notebookPen,
      titleKey: RecordCopyKey.typeNote,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static List<RecordQuickAction> _quickActionsFor() {
    return _quickActions
        .where((action) => action.type != RecordEntryType.vitals)
        .toList(growable: false);
  }

  static final _summaryItems = <RecordSummaryItem>[
    const RecordSummaryItem(
      type: RecordEntryType.meal,
      icon: FLucideIcons.utensils,
      titleKey: RecordCopyKey.summaryMealTitle,
      value: '2',
      unitKey: RecordCopyKey.summaryTimesUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordSummaryItem(
      type: RecordEntryType.water,
      icon: FLucideIcons.cupSoda,
      titleKey: RecordCopyKey.summaryWaterTitle,
      value: '5 / 8',
      unitKey: RecordCopyKey.summaryCupsUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordSummaryItem(
      type: RecordEntryType.vitals,
      icon: FLucideIcons.heart,
      titleKey: RecordCopyKey.summaryLatestVitalTitle,
      value: '118/76',
      detailKey: RecordCopyKey.summaryNormal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static final _filters = <RecordFilter>[
    const RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: FLucideIcons.utensils,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.vitals,
      titleKey: RecordCopyKey.typeVitals,
      icon: FLucideIcons.heart,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: FLucideIcons.cupSoda,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.symptom,
      titleKey: RecordCopyKey.typeSymptom,
      icon: FLucideIcons.thermometer,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: FLucideIcons.pill,
      accent: SemanticColor.primary,
      selected: true,
    ),
    // Deferred by Product_Vision MVP: keep mood filters available for future
    // self-check-in contracts, but filter them out of the active Record surface.
    const RecordFilter(
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: FLucideIcons.smile,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: FLucideIcons.moon,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.note,
      titleKey: RecordCopyKey.typeNote,
      icon: FLucideIcons.notebookPen,
      accent: SemanticColor.primary,
      selected: true,
    ),
  ];

  static List<RecordFilter> _filtersFor(RecordEntryType? filterType) {
    final filters = _filters.where(_isActiveRecordType);

    return filters
        .map(
          (filter) => RecordFilter(
            type: filter.type,
            titleKey: filter.titleKey,
            icon: filter.icon,
            accent: filter.accent,
            selected: filterType == null || filter.type == filterType,
            locked: filter.locked,
          ),
        )
        .toList(growable: false);
  }

  static List<RecordTimelineEntry> _timelineFor(RecordEntryType? filterType) {
    if (filterType != null && !_isActiveRecordEntryType(filterType)) {
      return const <RecordTimelineEntry>[];
    }
    final timeline = _timeline.where(
      (entry) => _isActiveRecordEntryType(entry.type),
    );
    if (filterType == null) {
      return timeline.toList(growable: false);
    }
    return timeline
        .where((entry) => entry.type == filterType)
        .toList(growable: false);
  }

  static final _timeline = <RecordTimelineEntry>[
    const RecordTimelineEntry(
      time: '08:30',
      type: RecordEntryType.medication,
      icon: FLucideIcons.pill,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeMedication,
      valueKey: RecordCopyKey.timelineMedicationName,
      detailKey: RecordCopyKey.timelineMedicationDetail,
      trailingIcon: FLucideIcons.checkCircle2,
    ),
    const RecordTimelineEntry(
      time: '09:15',
      type: RecordEntryType.water,
      icon: FLucideIcons.cupSoda,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeWater,
      valueKey: RecordCopyKey.timelineWaterAmount,
      detailKey: RecordCopyKey.timelineWaterProgress,
      trailingIcon: FLucideIcons.chevronRight,
    ),
    const RecordTimelineEntry(
      time: '12:45',
      type: RecordEntryType.meal,
      icon: FLucideIcons.utensils,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineMealLunch,
      valueKey: RecordCopyKey.timelineMealName,
      detailKey: RecordCopyKey.timelineMealNutrition,
      badgeKey: RecordCopyKey.timelineAiBadge,
      imagePlaceholderKey: RecordCopyKey.foodImagePlaceholder,
      trailingIcon: FLucideIcons.ellipsis,
    ),
    const RecordTimelineEntry(
      time: '15:20',
      type: RecordEntryType.symptom,
      icon: FLucideIcons.thermometer,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineSymptomRecord,
      detailKey: RecordCopyKey.timelineSymptomDetail,
      badgeKey: RecordCopyKey.timelineManualBadge,
      trailingIcon: FLucideIcons.chevronRight,
    ),
    // Deferred by Product_Vision MVP: keep lightweight mood timeline data
    // because it is useful for future self-check-ins, but do not surface it in
    // the active Record timeline until the product job is ready.
    const RecordTimelineEntry(
      time: '10:30',
      type: RecordEntryType.mood,
      icon: FLucideIcons.smile,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineMoodCalm,
      detailKey: RecordCopyKey.timelineMoodDetail,
      trailingIcon: FLucideIcons.chevronRight,
    ),
    const RecordTimelineEntry(
      time: '23:30',
      type: RecordEntryType.sleep,
      icon: FLucideIcons.moon,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineSleepRecord,
      detailKey: RecordCopyKey.timelineSleepDetail,
      badgeKey: RecordCopyKey.summaryNormal,
      trailingIcon: FLucideIcons.chevronRight,
    ),
    const RecordTimelineEntry(
      time: '16:00',
      type: RecordEntryType.note,
      icon: FLucideIcons.notebookPen,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeNote,
      trailingIcon: FLucideIcons.chevronRight,
    ),
    const RecordTimelineEntry(
      time: '06:10',
      type: RecordEntryType.weight,
      icon: FLucideIcons.droplets,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeWeight,
      value: '--',
      detailKey: RecordCopyKey.timelineWeightDetail,
      trailingIcon: FLucideIcons.chevronRight,
    ),
  ];

  static final _trends = <RecordTrend>[
    const RecordTrend(
      kind: RecordTrendKind.bloodSugar,
      titleKey: RecordCopyKey.trendBloodSugarTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: SemanticColor.primary,
      points: <double>[],
      legendKey: RecordCopyKey.trendBloodSugarLegend,
    ),
    const RecordTrend(
      kind: RecordTrendKind.hydration,
      titleKey: RecordCopyKey.trendHydrationTitle,
      rangeKey: RecordCopyKey.range30Days,
      color: SemanticColor.primary,
      points: <double>[],
      bars: <double>[],
    ),
  ];

  static RecordCopyKey _weekdayKey(int weekday) {
    return switch (weekday) {
      1 => RecordCopyKey.weekdayMon,
      2 => RecordCopyKey.weekdayTue,
      3 => RecordCopyKey.weekdayWed,
      4 => RecordCopyKey.weekdayThu,
      5 => RecordCopyKey.weekdayFri,
      6 => RecordCopyKey.weekdaySat,
      _ => RecordCopyKey.weekdaySun,
    };
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isActiveRecordType(RecordFilter filter) {
    return _isActiveRecordEntryType(filter.type);
  }

  static bool _isActiveRecordEntryType(RecordEntryType type) {
    return switch (type) {
      RecordEntryType.symptom ||
      RecordEntryType.water ||
      RecordEntryType.meal ||
      RecordEntryType.sleep ||
      RecordEntryType.medication ||
      RecordEntryType.note => true,
      _ => false,
    };
  }
}

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final dailyRecordRepo = ref.watch(dailyRecordRepositoryProvider);
  return LucentRecordRepository(dailyRecordRepo: dailyRecordRepo);
});
