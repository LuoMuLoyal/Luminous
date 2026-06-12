import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/data/repositories/lucent_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';

class MockRecordRepository implements RecordRepository {
  const MockRecordRepository();

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    return dashboardFor(selectedDate, filterType: filterType);
  }

  static RecordDashboard loadingDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) {
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
      summary: const RecordDaySummary(items: _summaryItems),
      filters: filters,
      timeline: timeline,
      trends: _trends,
    );
  }

  static const _meal = Color(0xFF149B5A);
  static const _mealSoft = Color(0xFFEAF8EF);
  static const _vitals = Color(0xFFFF4D57);
  static const _vitalsSoft = Color(0xFFFFEEEE);
  static const _water = Color(0xFF428BFF);
  static const _waterSoft = Color(0xFFEFF5FF);
  static const _mood = Color(0xFF7D67E8);
  static const _moodSoft = Color(0xFFF0ECFF);
  static const _symptom = Color(0xFFFF8A00);
  static const _symptomSoft = Color(0xFFFFF2E0);
  static const _medication = Color(0xFFFF7A1A);
  static const _medicationSoft = Color(0xFFFFF0E6);
  static const _sleep = Color(0xFF7B61FF);
  static const _sleepSoft = Color(0xFFF0ECFF);

  static List<RecordWeekDay> _weekDaysFor(DateTime selectedDate) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final monday = date.subtract(Duration(days: date.weekday - 1));
    const markerPattern = <List<Color>>[
      <Color>[_meal],
      <Color>[_meal],
      <Color>[_symptom],
      <Color>[_meal, _water],
      <Color>[_mood],
      <Color>[_vitals],
      <Color>[_water],
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

  static const _monthDays = <RecordCalendarDay>[
    RecordCalendarDay(day: 28, inMonth: false, selected: false, markers: []),
    RecordCalendarDay(day: 29, inMonth: false, selected: false, markers: []),
    RecordCalendarDay(day: 30, inMonth: false, selected: false, markers: []),
    RecordCalendarDay(day: 1, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 2, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 3, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 4, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 5, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 6, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 7, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 8, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 9, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 10, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(day: 11, inMonth: true, selected: false, markers: []),
    RecordCalendarDay(
      day: 12,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 13,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 14,
      inMonth: true,
      selected: false,
      markers: <Color>[_symptom],
    ),
    RecordCalendarDay(
      day: 15,
      inMonth: true,
      selected: true,
      markers: <Color>[_meal, _water],
    ),
    RecordCalendarDay(
      day: 16,
      inMonth: true,
      selected: false,
      markers: <Color>[_mood],
    ),
    RecordCalendarDay(
      day: 17,
      inMonth: true,
      selected: false,
      markers: <Color>[_vitals],
      hasAlert: true,
    ),
    RecordCalendarDay(
      day: 18,
      inMonth: true,
      selected: false,
      markers: <Color>[_water],
    ),
    RecordCalendarDay(
      day: 19,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 20,
      inMonth: true,
      selected: false,
      markers: <Color>[_medication],
    ),
    RecordCalendarDay(
      day: 21,
      inMonth: true,
      selected: false,
      markers: <Color>[_water],
    ),
    RecordCalendarDay(
      day: 22,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 23,
      inMonth: true,
      selected: false,
      markers: <Color>[_mood],
    ),
    RecordCalendarDay(
      day: 24,
      inMonth: true,
      selected: false,
      markers: <Color>[_medication],
    ),
    RecordCalendarDay(
      day: 25,
      inMonth: true,
      selected: false,
      markers: <Color>[_water],
    ),
    RecordCalendarDay(
      day: 26,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 27,
      inMonth: true,
      selected: false,
      markers: <Color>[_symptom],
    ),
    RecordCalendarDay(
      day: 28,
      inMonth: true,
      selected: false,
      markers: <Color>[_meal],
    ),
    RecordCalendarDay(
      day: 29,
      inMonth: true,
      selected: false,
      markers: <Color>[_water],
    ),
    RecordCalendarDay(
      day: 30,
      inMonth: true,
      selected: false,
      markers: <Color>[_water],
    ),
    RecordCalendarDay(
      day: 31,
      inMonth: true,
      selected: false,
      markers: <Color>[_mood],
    ),
    RecordCalendarDay(day: 1, inMonth: false, selected: false, markers: []),
  ];

  static const _quickActions = <RecordQuickAction>[
    RecordQuickAction(
      type: RecordEntryType.meal,
      icon: Icons.restaurant_menu_rounded,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.summaryTimesUnit,
      accent: _meal,
      softColor: _mealSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.vitals,
      icon: Icons.favorite_rounded,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.summaryNormal,
      accent: _vitals,
      softColor: _vitalsSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.water,
      icon: Icons.local_drink_rounded,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.summaryCupsUnit,
      accent: _water,
      softColor: _waterSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.symptom,
      icon: Icons.sick_outlined,
      titleKey: RecordCopyKey.typeSymptom,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _symptom,
      softColor: _symptomSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.medication,
      icon: Icons.medication_rounded,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _medication,
      softColor: _medicationSoft,
    ),
    // Deferred by Product_Vision MVP: keep the lightweight mood entry shape
    // because it may support future self-check-ins, but do not surface it as a
    // formal mental-health module in the active Record quick actions.
    RecordQuickAction(
      type: RecordEntryType.mood,
      icon: Icons.mood_rounded,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _mood,
      softColor: _moodSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: Icons.dark_mode_rounded,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _sleep,
      softColor: _sleepSoft,
      locked: true,
    ),
    RecordQuickAction(
      type: RecordEntryType.note,
      icon: Icons.notes_rounded,
      titleKey: RecordCopyKey.typeNote,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _medication,
      softColor: _medicationSoft,
    ),
  ];

  static List<RecordQuickAction> _quickActionsFor() {
    return _quickActions
        .where(
          (action) =>
              action.type != RecordEntryType.mood &&
              action.type != RecordEntryType.vitals,
        )
        .toList(growable: false);
  }

  static const _summaryItems = <RecordSummaryItem>[
    RecordSummaryItem(
      type: RecordEntryType.meal,
      icon: Icons.restaurant_menu_rounded,
      titleKey: RecordCopyKey.summaryMealTitle,
      value: '2',
      unitKey: RecordCopyKey.summaryTimesUnit,
      accent: _meal,
      softColor: _mealSoft,
    ),
    RecordSummaryItem(
      type: RecordEntryType.water,
      icon: Icons.local_drink_rounded,
      titleKey: RecordCopyKey.summaryWaterTitle,
      value: '5 / 8',
      unitKey: RecordCopyKey.summaryCupsUnit,
      accent: _water,
      softColor: _waterSoft,
    ),
    RecordSummaryItem(
      type: RecordEntryType.vitals,
      icon: Icons.favorite_rounded,
      titleKey: RecordCopyKey.summaryLatestVitalTitle,
      value: '118/76',
      detailKey: RecordCopyKey.summaryNormal,
      accent: _vitals,
      softColor: _vitalsSoft,
    ),
  ];

  static const _filters = <RecordFilter>[
    RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: Icons.restaurant_menu_rounded,
      accent: _meal,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.vitals,
      titleKey: RecordCopyKey.typeVitals,
      icon: Icons.favorite_rounded,
      accent: _vitals,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: Icons.local_drink_rounded,
      accent: _water,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.symptom,
      titleKey: RecordCopyKey.typeSymptom,
      icon: Icons.sick_outlined,
      accent: _symptom,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: Icons.medication_rounded,
      accent: _medication,
      selected: true,
    ),
    // Deferred by Product_Vision MVP: keep mood filters available for future
    // self-check-in contracts, but filter them out of the active Record surface.
    RecordFilter(
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: Icons.mood_rounded,
      accent: _mood,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: Icons.dark_mode_rounded,
      accent: _sleep,
      selected: true,
      locked: true,
    ),
    RecordFilter(
      type: RecordEntryType.note,
      titleKey: RecordCopyKey.typeNote,
      icon: Icons.notes_rounded,
      accent: _medication,
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

  static const _timeline = <RecordTimelineEntry>[
    RecordTimelineEntry(
      time: '08:30',
      type: RecordEntryType.medication,
      icon: Icons.medication_rounded,
      accent: _medication,
      softColor: _medicationSoft,
      titleKey: RecordCopyKey.typeMedication,
      valueKey: RecordCopyKey.timelineMedicationName,
      detailKey: RecordCopyKey.timelineMedicationDetail,
      trailingIcon: Icons.check_circle_outline_rounded,
    ),
    RecordTimelineEntry(
      time: '09:15',
      type: RecordEntryType.water,
      icon: Icons.local_drink_rounded,
      accent: _water,
      softColor: _waterSoft,
      titleKey: RecordCopyKey.typeWater,
      valueKey: RecordCopyKey.timelineWaterAmount,
      detailKey: RecordCopyKey.timelineWaterProgress,
      trailingIcon: Icons.chevron_right_rounded,
    ),
    RecordTimelineEntry(
      time: '12:45',
      type: RecordEntryType.meal,
      icon: Icons.restaurant_menu_rounded,
      accent: _meal,
      softColor: _mealSoft,
      titleKey: RecordCopyKey.timelineMealLunch,
      valueKey: RecordCopyKey.timelineMealName,
      detailKey: RecordCopyKey.timelineMealNutrition,
      badgeKey: RecordCopyKey.timelineAiBadge,
      imagePlaceholderKey: RecordCopyKey.foodImagePlaceholder,
      trailingIcon: Icons.more_horiz_rounded,
    ),
    RecordTimelineEntry(
      time: '15:20',
      type: RecordEntryType.symptom,
      icon: Icons.sick_outlined,
      accent: _symptom,
      softColor: _symptomSoft,
      titleKey: RecordCopyKey.timelineSymptomRecord,
      detailKey: RecordCopyKey.timelineSymptomDetail,
      badgeKey: RecordCopyKey.timelineManualBadge,
      trailingIcon: Icons.chevron_right_rounded,
    ),
    // Deferred by Product_Vision MVP: keep lightweight mood timeline data
    // because it is useful for future self-check-ins, but do not surface it in
    // the active Record timeline until the product job is ready.
    RecordTimelineEntry(
      time: '10:30',
      type: RecordEntryType.mood,
      icon: Icons.mood_rounded,
      accent: _mood,
      softColor: _moodSoft,
      titleKey: RecordCopyKey.timelineMoodCalm,
      detailKey: RecordCopyKey.timelineMoodDetail,
      trailingIcon: Icons.chevron_right_rounded,
    ),
    RecordTimelineEntry(
      time: '23:30',
      type: RecordEntryType.sleep,
      icon: Icons.dark_mode_rounded,
      accent: _sleep,
      softColor: _sleepSoft,
      titleKey: RecordCopyKey.timelineSleepRecord,
      detailKey: RecordCopyKey.timelineSleepDetail,
      badgeKey: RecordCopyKey.summaryNormal,
      trailingIcon: Icons.chevron_right_rounded,
    ),
    RecordTimelineEntry(
      time: '16:00',
      type: RecordEntryType.note,
      icon: Icons.notes_rounded,
      accent: _medication,
      softColor: _medicationSoft,
      titleKey: RecordCopyKey.typeNote,
      trailingIcon: Icons.chevron_right_rounded,
    ),
    RecordTimelineEntry(
      time: '06:10',
      type: RecordEntryType.weight,
      icon: Icons.water_drop_outlined,
      accent: _water,
      softColor: _waterSoft,
      titleKey: RecordCopyKey.typeWeight,
      value: '66.2 kg',
      detailKey: RecordCopyKey.timelineWeightDetail,
      trailingIcon: Icons.chevron_right_rounded,
    ),
  ];

  static const _trends = <RecordTrend>[
    RecordTrend(
      kind: RecordTrendKind.bloodSugar,
      titleKey: RecordCopyKey.trendBloodSugarTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: _meal,
      points: <double>[6.4, 7.9, 7.1, 8.6, 6.3, 8.1, 6.7],
      legendKey: RecordCopyKey.trendBloodSugarLegend,
    ),
    RecordTrend(
      kind: RecordTrendKind.hydration,
      titleKey: RecordCopyKey.trendHydrationTitle,
      rangeKey: RecordCopyKey.range30Days,
      color: _water,
      points: <double>[],
      bars: <double>[
        0.78,
        0.64,
        0.69,
        0.66,
        0.71,
        0.83,
        0.75,
        0.86,
        0.70,
        0.79,
        0.88,
        0.65,
        0.56,
        0.68,
        0.73,
        0.84,
        0.69,
        0.72,
        0.91,
        0.97,
        0.68,
      ],
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
