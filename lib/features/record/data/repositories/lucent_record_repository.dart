import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';

/// Lucent-backed implementation of [RecordRepository] that maps real daily
/// records into the timeline while keeping other dashboard sections as static
/// mock until their backend APIs exist.
class LucentRecordRepository implements RecordRepository {
  LucentRecordRepository({required this.dailyRecordRepo});

  final DailyRecordRepository dailyRecordRepo;

  @override
  Future<RecordDashboard> fetchDashboard() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    List<DailyRecordItem> records;
    try {
      final result = await dailyRecordRepo.fetchRecords(dateStr, pageSize: 100);
      records = result.items;
    } catch (_) {
      records = [];
    }

    final timeline = records.map(_toTimelineEntry).toList();

    return RecordDashboard(
      selectedDay: today.day,
      weekDays: _staticWeekDays(today),
      monthDays: _staticMonthDays(today),
      quickActions: _staticQuickActions,
      summary: _staticSummary,
      filters: _staticFilters,
      timeline: timeline.isNotEmpty ? timeline : _staticTimeline,
      trends: _staticTrends,
      healthBag: _staticHealthBag,
    );
  }

  RecordTimelineEntry _toTimelineEntry(DailyRecordItem record) {
    final kind = record.kind;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final (icon, accent, soft, type) = switch (kind) {
      DailyRecordKind.water => (
        Icons.water_drop_rounded,
        const Color(0xFF428BFF),
        const Color(0xFFE8F2FF),
        RecordEntryType.water,
      ),
      DailyRecordKind.meal => (
        Icons.restaurant_rounded,
        AppColorTokens.warning,
        AppColorTokens.warningSoft,
        RecordEntryType.meal,
      ),
      DailyRecordKind.vital => (
        Icons.favorite_rounded,
        AppColorTokens.error,
        AppColorTokens.errorSoft,
        RecordEntryType.vitals,
      ),
      DailyRecordKind.mood => (
        Icons.sentiment_satisfied_rounded,
        const Color(0xFF7D67E8),
        const Color(0xFFF0ECFF),
        RecordEntryType.mood,
      ),
      DailyRecordKind.symptom => (
        Icons.healing_rounded,
        AppColorTokens.warningDeep,
        AppColorTokens.warningSoft,
        RecordEntryType.symptom,
      ),
      DailyRecordKind.activity => (
        Icons.directions_run_rounded,
        AppColorTokens.gradientDevelopStart,
        const Color(0xFFE8FFF2),
        RecordEntryType.activity,
      ),
      DailyRecordKind.note => (
        Icons.notes_rounded,
        AppColorTokens.link,
        AppColorTokens.linkSoft,
        RecordEntryType.medication,
      ),
    };

    return RecordTimelineEntry(
      time: timeStr,
      type: type,
      icon: icon,
      accent: accent,
      softColor: soft,
      titleKey: RecordCopyKey.typeMood,
      rawTitle: record.title ?? '${kind.name} ${record.value ?? ''}'.trim(),
      value: record.value != null
          ? '${record.value}${record.unit != null ? ' ${record.unit}' : ''}'
          : record.note,
      detailKey: record.note != null && record.value != null ? null : null,
      recordId: record.id,
    );
  }

  // --- static mock (backend does not yet provide) ---

  static List<RecordWeekDay> _staticWeekDays(DateTime today) {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return RecordWeekDay(
        day: day.day,
        weekdayKey: _weekdayKey(day.weekday),
        selected: day.day == today.day,
        markers: day.day == today.day ? [const Color(0xFF428BFF)] : [],
      );
    });
  }

  static List<RecordCalendarDay> _staticMonthDays(DateTime today) {
    final first = DateTime(today.year, today.month, 1);
    final last = DateTime(today.year, today.month + 1, 0);
    final startOffset = first.weekday - 1;
    final days = <RecordCalendarDay>[];
    for (var i = 0; i < startOffset; i++) {
      days.add(
        RecordCalendarDay(day: 0, inMonth: false, selected: false, markers: []),
      );
    }
    for (var d = 1; d <= last.day; d++) {
      days.add(
        RecordCalendarDay(
          day: d,
          inMonth: true,
          selected: d == today.day,
          markers: d == today.day ? [const Color(0xFF428BFF)] : [],
        ),
      );
    }
    return days;
  }

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

  static final _staticQuickActions = <RecordQuickAction>[
    RecordQuickAction(
      type: RecordEntryType.meal,
      icon: Icons.restaurant_rounded,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.typeWomenHealth,
      accent: AppColorTokens.warning,
      softColor: AppColorTokens.warningSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.vitals,
      icon: Icons.favorite_rounded,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.typeWomenHealth,
      accent: AppColorTokens.error,
      softColor: AppColorTokens.errorSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.water,
      icon: Icons.water_drop_rounded,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.typeWomenHealth,
      accent: const Color(0xFF428BFF),
      softColor: const Color(0xFFE8F2FF),
    ),
    RecordQuickAction(
      type: RecordEntryType.mood,
      icon: Icons.sentiment_satisfied_rounded,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.typeWomenHealth,
      accent: const Color(0xFF7D67E8),
      softColor: const Color(0xFFF0ECFF),
    ),
  ];

  static const _staticSummary = RecordDaySummary(items: []);

  static const _staticFilters = <RecordFilter>[];

  static const _staticTimeline = <RecordTimelineEntry>[];

  static const _staticTrends = <RecordTrend>[
    RecordTrend(
      kind: RecordTrendKind.bloodSugar,
      titleKey: RecordCopyKey.trendBloodSugarTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: AppColorTokens.link,
      points: [5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9],
      legendKey: RecordCopyKey.trendBloodSugarLegend,
    ),
  ];

  static const _staticHealthBag = RecordHealthBag(
    titleKey: RecordCopyKey.healthBagTitle,
    bodyKey: RecordCopyKey.healthBagBody,
    latestKey: RecordCopyKey.healthBagLatest,
    nextKey: RecordCopyKey.healthBagNext,
  );
}
