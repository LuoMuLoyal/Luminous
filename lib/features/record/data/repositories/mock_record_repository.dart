import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/data/repositories/lucent_record_repository.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';

class MockRecordRepository implements RecordRepository {
  const MockRecordRepository();

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    bool showWomenHealth = false,
    RecordEntryType? filterType,
  }) async {
    return dashboardFor(
      selectedDate,
      showWomenHealth: showWomenHealth,
      filterType: filterType,
    );
  }

  static RecordDashboard loadingDashboard(
    DateTime selectedDate, {
    bool showWomenHealth = false,
    RecordEntryType? filterType,
  }) {
    return dashboardFor(
      selectedDate,
      showWomenHealth: showWomenHealth,
      filterType: filterType,
    );
  }

  static RecordDashboard dashboardFor(
    DateTime selectedDate, {
    bool showWomenHealth = false,
    RecordEntryType? filterType,
  }) {
    final filters = _filtersFor(showWomenHealth, filterType);
    final timeline = _timelineFor(showWomenHealth, filterType);

    return RecordDashboard(
      selectedDate: selectedDate,
      selectedDay: selectedDate.day,
      weekDays: _weekDaysFor(selectedDate),
      monthDays: _monthDays,
      quickActions: _quickActionsFor(showWomenHealth),
      summary: const RecordDaySummary(items: _summaryItems),
      filters: filters,
      timeline: timeline,
      trends: _trends,
      healthBag: const RecordHealthBag(
        titleKey: RecordCopyKey.healthBagTitle,
        bodyKey: RecordCopyKey.healthBagBody,
        latestKey: RecordCopyKey.healthBagLatest,
        nextKey: RecordCopyKey.healthBagNext,
      ),
      showWomenHealth: showWomenHealth,
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
  static const _activity = Color(0xFF16A66A);
  static const _activitySoft = Color(0xFFEAF9F1);
  static const _medication = Color(0xFFFF7A1A);
  static const _medicationSoft = Color(0xFFFFF0E6);
  static const _women = Color(0xFFFF6F91);
  static const _womenSoft = Color(0xFFFFEEF3);
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
      <Color>[_activity],
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
      markers: <Color>[_activity],
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
      markers: <Color>[_activity],
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
      markers: <Color>[_activity],
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
      markers: <Color>[_activity],
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
      type: RecordEntryType.mood,
      icon: Icons.mood_rounded,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _mood,
      softColor: _moodSoft,
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
      type: RecordEntryType.activity,
      icon: Icons.directions_run_rounded,
      titleKey: RecordCopyKey.typeActivity,
      subtitleKey: RecordCopyKey.summaryTimesUnit,
      accent: _activity,
      softColor: _activitySoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.medication,
      icon: Icons.medication_rounded,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _medication,
      softColor: _medicationSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.womenHealth,
      icon: Icons.local_florist_rounded,
      titleKey: RecordCopyKey.typeWomenHealth,
      subtitleKey: RecordCopyKey.quickWomenSubtitle,
      accent: _women,
      softColor: _womenSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: Icons.dark_mode_rounded,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: _sleep,
      softColor: _sleepSoft,
    ),
  ];

  static List<RecordQuickAction> _quickActionsFor(bool showWomenHealth) {
    if (showWomenHealth) return _quickActions;
    return _quickActions
        .where((action) => action.type != RecordEntryType.womenHealth)
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
    RecordSummaryItem(
      type: RecordEntryType.mood,
      icon: Icons.mood_rounded,
      titleKey: RecordCopyKey.summaryMoodTitle,
      value: '',
      detailKey: RecordCopyKey.summaryRecorded,
      accent: _mood,
      softColor: _moodSoft,
    ),
    RecordSummaryItem(
      type: RecordEntryType.activity,
      icon: Icons.directions_run_rounded,
      titleKey: RecordCopyKey.summaryActivityTitle,
      value: '40',
      unitKey: RecordCopyKey.summaryTimesUnit,
      accent: _activity,
      softColor: _activitySoft,
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
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: Icons.mood_rounded,
      accent: _mood,
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
      type: RecordEntryType.activity,
      titleKey: RecordCopyKey.typeActivity,
      icon: Icons.directions_run_rounded,
      accent: _activity,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: Icons.medication_rounded,
      accent: _medication,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.womenHealth,
      titleKey: RecordCopyKey.typeWomenHealth,
      icon: Icons.local_florist_rounded,
      accent: _women,
      selected: true,
      locked: true,
    ),
    RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: Icons.dark_mode_rounded,
      accent: _sleep,
      selected: true,
    ),
  ];

  static List<RecordFilter> _filtersFor(
    bool showWomenHealth,
    RecordEntryType? filterType,
  ) {
    final filters = showWomenHealth
        ? _filters
        : _filters.where(
            (filter) => filter.type != RecordEntryType.womenHealth,
          );

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

  static List<RecordTimelineEntry> _timelineFor(
    bool showWomenHealth,
    RecordEntryType? filterType,
  ) {
    final timeline = showWomenHealth
        ? _timeline
        : _timeline.where((entry) => entry.type != RecordEntryType.womenHealth);
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
    RecordTimelineEntry(
      time: '20:10',
      type: RecordEntryType.womenHealth,
      icon: Icons.local_florist_rounded,
      accent: _women,
      softColor: _womenSoft,
      titleKey: RecordCopyKey.timelineWomenHealthRecord,
      detailKey: RecordCopyKey.timelineWomenHealthDetail,
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
      time: '06:30',
      type: RecordEntryType.activity,
      icon: Icons.directions_run_rounded,
      accent: _activity,
      softColor: _activitySoft,
      titleKey: RecordCopyKey.timelineActivityWalk,
      detailKey: RecordCopyKey.timelineActivityDetail,
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
      kind: RecordTrendKind.sleepMood,
      titleKey: RecordCopyKey.trendSleepMoodTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: _mood,
      points: <double>[7.1, 8.4, 7.5, 8.5, 6.4, 7.7, 8.1],
      secondaryColor: AppColorTokens.warning,
      secondaryPoints: <double>[5.5, 6.3, 5.6, 6.2, 5.4, 5.7, 7.6],
      legendKey: RecordCopyKey.trendSleepLegend,
      secondaryLegendKey: RecordCopyKey.trendMoodLegend,
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
}

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final dailyRecordRepo = ref.watch(dailyRecordRepositoryProvider);
  return LucentRecordRepository(dailyRecordRepo: dailyRecordRepo);
});
