import 'package:collection/collection.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/entities/type_mapping.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';

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
    final dateStr = formatRecordDate(date);
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
      } catch (e) {
        appTalker.error('LucentRecordRepository: fetchRecords failed: $e');
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
      timeline: timeline,
      trends: _staticTrends,
    );
  }

  RecordTimelineEntry _toTimelineEntry(DailyRecordItem record) {
    final kind = record.kind;
    final timeStr = formatRecordTimeLabel(record.occurredTime);

    const accent = SemanticColor.primary;
    const soft = SemanticColor.neutral;

    final icon = switch (kind) {
      DailyRecordKind.water => SemanticIcons.recordWater,
      DailyRecordKind.meal => SemanticIcons.recordMeal,
      DailyRecordKind.vital => SemanticIcons.profileCondition,
      DailyRecordKind.mood => SemanticIcons.recordMood,
      DailyRecordKind.symptom => SemanticIcons.safetyDanger,
      DailyRecordKind.activity => SemanticIcons.recordActivity,
      DailyRecordKind.note => SemanticIcons.tabRecord,
      DailyRecordKind.sleep => SemanticIcons.recordMoon,
    };

    // Mood records created through the fast-entry dialog store the level in
    // the payload, so expose a readable subtitle such as "情绪 · 不错".
    final moodValueKey = _moodValueKey(kind, record.payload);
    final mealView = kind == DailyRecordKind.meal
        ? parseMealAnalysisViewData(record.payload)
        : null;

    final titleKey = switch (kind) {
      DailyRecordKind.water => RecordCopyKey.typeWater,
      DailyRecordKind.meal => RecordCopyKey.typeMeal,
      DailyRecordKind.vital => RecordCopyKey.typeVitals,
      DailyRecordKind.mood => RecordCopyKey.typeMood,
      DailyRecordKind.symptom => RecordCopyKey.typeSymptom,
      DailyRecordKind.activity => RecordCopyKey.typeActivity,
      DailyRecordKind.note => RecordCopyKey.typeNote,
      DailyRecordKind.sleep => RecordCopyKey.typeSleep,
    };

    // For notes and mood records without a real title, leave rawTitle null so
    // the timeline resolves through the localized titleKey (or uses note
    // content as a short preview). Other kinds keep the existing "kind value"
    // fallback.
    final String? rawTitle;
    if (record.title != null) {
      rawTitle = record.title;
    } else if (kind == DailyRecordKind.meal &&
        record.mealShortDescription != null) {
      rawTitle = record.mealShortDescription;
    } else if (kind == DailyRecordKind.note || kind == DailyRecordKind.mood) {
      rawTitle = null;
    } else {
      rawTitle = '${kind.name} ${record.value ?? ''}'.trim();
    }

    final mealDetail =
        kind == DailyRecordKind.meal && record.mealTopFoods.isNotEmpty
        ? '识别菜品：${record.mealTopFoods.join('、')}'
        : null;

    final mealValue = kind == DailyRecordKind.meal
        ? (record.mealShortDescription ??
              record.value ??
              mealView?.mealDescription ??
              record.note)
        : null;

    return RecordTimelineEntry(
      time: timeStr,
      type: recordEntryTypeForDailyRecordKind(kind),
      icon: icon,
      accent: accent,
      softColor: soft,
      titleKey: titleKey,
      rawTitle: rawTitle,
      value: kind == DailyRecordKind.meal
          ? mealValue
          : record.value != null
          ? '${record.value}${record.unit != null ? ' ${record.unit}' : ''}'
          : _sleepPayloadValue(kind, record.payload) ?? record.note,
      valueKey: moodValueKey,
      rawDetail: mealDetail,
      detailKey: record.note != null && record.value != null ? null : null,
      badgeKey: _mealBadgeKey(record),
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

  /// Returns a compact sleep-duration display string (e.g. "7h 30m")
  /// extracted from the sleep payload, or null when the record is not a
  /// sleep record or has no usable duration data.
  static String? _sleepPayloadValue(
    DailyRecordKind kind,
    Map<String, dynamic>? payload,
  ) {
    if (kind != DailyRecordKind.sleep || payload == null) return null;
    final minutes = payload['durationMinutes'];
    if (minutes is! num || minutes <= 0) return null;
    final h = minutes ~/ 60;
    final m = minutes.round() % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Returns the localized copy key for a mood record's value line
  /// (e.g. "情绪 · 不错"), or null when the record is not a mood record or has
  /// no usable mood data.
  static RecordCopyKey? _moodValueKey(
    DailyRecordKind kind,
    Map<String, dynamic>? payload,
  ) {
    if (kind != DailyRecordKind.mood || payload == null) return null;
    final label = payload['moodLabel'];
    if (label is! String) return null;
    return switch (label) {
      'great' => RecordCopyKey.timelineMoodGreat,
      'good' => RecordCopyKey.timelineMoodGood,
      'okay' => RecordCopyKey.timelineMoodOkay,
      'bad' => RecordCopyKey.timelineMoodBad,
      'terrible' => RecordCopyKey.timelineMoodTerrible,
      _ => null,
    };
  }

  static RecordCopyKey? _mealBadgeKey(DailyRecordItem record) {
    if (record.kind != DailyRecordKind.meal) return null;
    return switch (record.mealAnalysisStatus) {
      'confirmed' => RecordCopyKey.timelineMealConfirmedBadge,
      'analysis_failed' => RecordCopyKey.timelineMealFailedBadge,
      'analyzing' => RecordCopyKey.timelineMealAnalyzingBadge,
      _ => RecordCopyKey.timelineMealEstimateBadge,
    };
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
        markers: day.day == today.day ? [SemanticColor.primary] : [],
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
        const RecordCalendarDay(
          day: 0,
          inMonth: false,
          selected: false,
          markers: [],
        ),
      );
    }
    for (var d = 1; d <= last.day; d++) {
      days.add(
        RecordCalendarDay(
          day: d,
          inMonth: true,
          selected: d == today.day,
          markers: d == today.day ? [SemanticColor.primary] : [],
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

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static final _staticQuickActions = <RecordQuickAction>[
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
    // Lightweight mood self-check-in quick action.
    const RecordQuickAction(
      type: RecordEntryType.mood,
      icon: SemanticIcons.recordMood,
      titleKey: RecordCopyKey.typeMood,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    const RecordQuickAction(
      type: RecordEntryType.meal,
      icon: SemanticIcons.recordMeal,
      titleKey: RecordCopyKey.typeMeal,
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
      type: RecordEntryType.vitals,
      icon: SemanticIcons.profileCondition,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.summaryNormal,
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
      type: RecordEntryType.note,
      icon: SemanticIcons.tabRecord,
      titleKey: RecordCopyKey.typeNote,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static List<RecordQuickAction> _staticQuickActionsFor() {
    return _staticQuickActions
        .where((action) => _isActiveRecordEntryType(action.type))
        .toList(growable: false);
  }

  static const _staticSummary = RecordDaySummary(items: []);

  static final _staticFilters = <RecordFilter>[
    const RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.symptom,
      titleKey: RecordCopyKey.typeSymptom,
      icon: SemanticIcons.medicineKit,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.mood,
      titleKey: RecordCopyKey.typeMood,
      icon: SemanticIcons.recordMood,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: SemanticIcons.recordWater,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: SemanticIcons.recordMeal,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.vitals,
      titleKey: RecordCopyKey.typeVitals,
      icon: SemanticIcons.profileCondition,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: SemanticIcons.recordMoon,
      accent: SemanticColor.primary,
      selected: true,
    ),
    const RecordFilter(
      type: RecordEntryType.note,
      titleKey: RecordCopyKey.typeNote,
      icon: SemanticIcons.tabRecord,
      accent: SemanticColor.primary,
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

  static final _staticTrends = <RecordTrend>[
    const RecordTrend(
      kind: RecordTrendKind.bloodSugar,
      titleKey: RecordCopyKey.trendBloodSugarTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: SemanticColor.primary,
      points: [5.1, 5.8, 5.4, 6.2, 5.6, 6.5, 5.9],
      legendKey: RecordCopyKey.trendBloodSugarLegend,
    ),
  ];

  static bool _isActiveRecordEntryType(RecordEntryType type) {
    return switch (type) {
      RecordEntryType.symptom ||
      RecordEntryType.water ||
      RecordEntryType.meal ||
      RecordEntryType.sleep ||
      RecordEntryType.medication ||
      RecordEntryType.mood ||
      RecordEntryType.note => true,
      _ => false,
    };
  }

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => Future.value(RecordDashboard.signedOut(selectedDate));
}
