import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:luminous/core/design/app_color_tokens.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/record/domain/repositories/record_repository.dart';

/// Lucent-backed implementation of [RecordRepository] that maps real daily
/// records into the timeline while keeping other dashboard sections as static
/// mock until their backend APIs exist.
class LucentRecordRepository implements RecordRepository {
  LucentRecordRepository({required this.dailyRecordRepo});

  final DailyRecordRepository dailyRecordRepo;

  @override
  Future<RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) async {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final dateStr = _formatDate(date);
    final selectedKind = filterType == null
        ? null
        : dailyRecordKindForEntryType(filterType);
    final kind = selectedKind?.name;

    List<DailyRecordItem> records;
    if (filterType != null &&
        (selectedKind == null || !_isActiveRecordEntryType(filterType))) {
      records = [];
    } else {
      try {
        final result = await dailyRecordRepo.fetchRecords(
          dateStr,
          kind: kind,
          pageSize: 100,
        );
        records = result.items
            .where((record) {
              final type = recordEntryTypeForDailyRecordKind(record.kind);
              return _isActiveRecordEntryType(type);
            })
            .toList(growable: false);
      } catch (_) {
        records = [];
      }
    }

    final timeline = records.map(_toTimelineEntry).toList();

    return RecordDashboard(
      selectedDate: date,
      selectedDay: date.day,
      weekDays: _staticWeekDays(date),
      monthDays: _staticMonthDays(date),
      quickActions: _staticQuickActionsFor(),
      summary: _staticSummary,
      filters: _staticFiltersFor(filterType),
      timeline: timeline.isNotEmpty ? timeline : _staticTimeline,
      trends: _staticTrends,
    );
  }

  RecordTimelineEntry _toTimelineEntry(DailyRecordItem record) {
    final kind = record.kind;
    final timeStr = _formatRecordTime(record.occurredAt);

    final (icon, accent, soft) = switch (kind) {
      DailyRecordKind.water => (
        Icons.water_drop_rounded,
        const Color(0xFF428BFF),
        const Color(0xFFE8F2FF),
      ),
      DailyRecordKind.meal => (
        Icons.restaurant_rounded,
        AppColorTokens.warning,
        AppColorTokens.warningSoft,
      ),
      DailyRecordKind.vital => (
        Icons.favorite_rounded,
        AppColorTokens.error,
        AppColorTokens.errorSoft,
      ),
      DailyRecordKind.mood => (
        Icons.sentiment_satisfied_rounded,
        const Color(0xFF7D67E8),
        const Color(0xFFF0ECFF),
      ),
      DailyRecordKind.symptom => (
        Icons.healing_rounded,
        AppColorTokens.warningDeep,
        AppColorTokens.warningSoft,
      ),
      DailyRecordKind.activity => (
        Icons.directions_run_rounded,
        AppColorTokens.gradientDevelopStart,
        const Color(0xFFE8FFF2),
      ),
      DailyRecordKind.note => (
        Icons.notes_rounded,
        AppColorTokens.link,
        AppColorTokens.linkSoft,
      ),
    };

    return RecordTimelineEntry(
      time: timeStr,
      type: recordEntryTypeForDailyRecordKind(kind),
      icon: icon,
      accent: accent,
      softColor: soft,
      titleKey: RecordCopyKey.typeMood,
      rawTitle: record.title ?? '${kind.name} ${record.value ?? ''}'.trim(),
      value: record.value != null
          ? '${record.value}${record.unit != null ? ' ${record.unit}' : ''}'
          : record.note,
      detailKey: record.note != null && record.value != null ? null : null,
      imageUrl: record.attachments
          .where(
            (attachment) => attachment.kind == DailyRecordAttachmentKind.image,
          )
          .map((attachment) => attachment.displayUrl)
          .whereType<String>()
          .firstOrNull,
      recordId: record.id,
    );
  }

  // --- static mock (backend does not yet provide) ---

  static List<RecordWeekDay> _staticWeekDays(DateTime today) {
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return RecordWeekDay(
        date: day,
        day: day.day,
        weekdayKey: _weekdayKey(day.weekday),
        selected: _isSameDay(day, today),
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

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatRecordTime(String occurredAt) {
    final parsed = DateTime.tryParse(occurredAt);
    final time = parsed?.toLocal();
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static final _staticQuickActions = <RecordQuickAction>[
    RecordQuickAction(
      type: RecordEntryType.symptom,
      icon: Icons.medical_services_outlined,
      titleKey: RecordCopyKey.typeSymptom,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: AppColorTokens.warning,
      softColor: AppColorTokens.warningSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.medication,
      icon: Icons.medication_rounded,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: AppColorTokens.cyanDeep,
      softColor: AppColorTokens.cyanSoft,
    ),
    // Deferred by Product_Vision MVP: keep the lightweight mood shape for
    // future self-check-ins, but do not surface it as a formal mental-health
    // module in the active Record quick actions.
    RecordQuickAction(
      type: RecordEntryType.mood,
      icon: Icons.sentiment_satisfied_rounded,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: AppColorTokens.violet,
      softColor: AppColorTokens.violetSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.meal,
      icon: Icons.restaurant_rounded,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: AppColorTokens.cyanDeep,
      softColor: AppColorTokens.cyanSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.water,
      icon: Icons.water_drop_rounded,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.summaryCupsUnit,
      accent: AppColorTokens.link,
      softColor: AppColorTokens.linkSoft,
    ),
    RecordQuickAction(
      type: RecordEntryType.vitals,
      icon: Icons.favorite_rounded,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.summaryNormal,
      accent: AppColorTokens.error,
      softColor: AppColorTokens.errorSoft,
    ),
    // Deferred by Product_Vision MVP: keep the sleep entry shape because sleep
    // is in the product vision, but do not surface it until the backend
    // contract maps sleep records explicitly.
    RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: Icons.dark_mode_rounded,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: AppColorTokens.violet,
      softColor: AppColorTokens.violetSoft,
    ),
  ];

  static List<RecordQuickAction> _staticQuickActionsFor() {
    return _staticQuickActions
        .where((action) => _isActiveRecordEntryType(action.type))
        .toList(growable: false);
  }

  static const _staticSummary = RecordDaySummary(items: []);

  static const _staticFilters = <RecordFilter>[
    RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: Icons.medication_rounded,
      accent: AppColorTokens.cyanDeep,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.symptom,
      titleKey: RecordCopyKey.typeSymptom,
      icon: Icons.medical_services_outlined,
      accent: AppColorTokens.warning,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: Icons.sentiment_satisfied_rounded,
      accent: AppColorTokens.violet,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: Icons.water_drop_rounded,
      accent: AppColorTokens.link,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: Icons.restaurant_rounded,
      accent: AppColorTokens.cyanDeep,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.vitals,
      titleKey: RecordCopyKey.typeVitals,
      icon: Icons.favorite_rounded,
      accent: AppColorTokens.error,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: Icons.dark_mode_rounded,
      accent: AppColorTokens.violet,
      selected: true,
    ),
  ];

  static List<RecordFilter> _staticFiltersFor(RecordEntryType? filterType) {
    final filters = _staticFilters.where(
      (filter) => _isActiveRecordEntryType(filter.type),
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

  static bool _isActiveRecordEntryType(RecordEntryType type) {
    return type != RecordEntryType.activity &&
        type != RecordEntryType.sleep &&
        type != RecordEntryType.mood;
  }
}
