// Simulated repository fakes for the five-tab shell screenshot run.
//
// Every value below is authored for layout capture: all list fields are
// non-empty and every observed metric is `observed`, so the tab pages render
// their populated state instead of an empty or signed-out placeholder.
import 'package:clock/clock.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/repositories/record.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/repositories/dashboard.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';

// ---------------------------------------------------------------------------
// Today
// ---------------------------------------------------------------------------

/// Simulated [TodayRepository] backing the Today tab capture.
class SimulatedTodayRepository implements TodayRepository {
  const SimulatedTodayRepository();

  @override
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard() =>
      TaskEither.right(_dashboard);

  @override
  Future<TodayDashboard> get signedOutDashboard => Future.value(_dashboard);

  static const _windowStart = '2026-06-18T00:00:00+08:00';
  static const _windowEnd = '2026-06-18T23:59:59+08:00';

  static TodayObservedMetric _metric({
    required double value,
    required int observedCount,
    required int expectedCount,
  }) => TodayObservedMetric(
    value: value,
    state: TodayObservedMetricState.observed,
    coverage: TodayObservedMetricCoverage.sufficient,
    sources: const <TodayObservedMetricSource>[
      TodayObservedMetricSource.manual,
      TodayObservedMetricSource.reminderPlan,
    ],
    observedCount: observedCount,
    expectedCount: expectedCount,
    windowStart: _windowStart,
    windowEnd: _windowEnd,
  );

  static final _dashboard = TodayDashboard(
    user: const TodayUserSnapshot(
      moment: TodayDayMoment.morning,
      hasUnreadNotifications: true,
      updatedAtLabel: '08:40',
    ),
    water: TodayWaterSummary(
      completedCount: 3,
      targetCount: 8,
      observedMetric: _metric(value: 750, observedCount: 3, expectedCount: 8),
    ),
    medication: TodayMedicationSummary(
      medicineCount: 3,
      pendingCount: 1,
      nextDoseTimeLabel: '12:30',
      nextMedicineName: '苯磺酸氨氯地平片',
      observedMetric: _metric(value: 2, observedCount: 2, expectedCount: 3),
    ),
    vitals: <TodayVitalSummary>[
      TodayVitalSummary(
        type: TodayVitalType.heartRate,
        valueLabel: '72 次/分',
        observedMetric: _metric(value: 72, observedCount: 1, expectedCount: 1),
      ),
      TodayVitalSummary(
        type: TodayVitalType.bloodPressure,
        valueLabel: '118/76 mmHg',
        observedMetric: _metric(value: 118, observedCount: 2, expectedCount: 2),
      ),
      TodayVitalSummary(
        type: TodayVitalType.sleep,
        valueLabel: '7.2 小时',
        observedMetric: _metric(value: 7.2, observedCount: 1, expectedCount: 1),
      ),
    ],
    mealSuggestion: const TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: const TodayEnvironmentSummary(
      signals: <TodayEnvironmentSignal>[
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.pollen,
          level: TodayEnvironmentLevel.medium,
        ),
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.uv,
          level: TodayEnvironmentLevel.low,
        ),
      ],
    ),
    lumiSuggestion: const TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );
}

// ---------------------------------------------------------------------------
// Record dashboard
// ---------------------------------------------------------------------------

/// Simulated [RecordRepository] backing the Record tab capture.
class SimulatedRecordRepository implements RecordRepository {
  const SimulatedRecordRepository();

  @override
  TaskEither<LucentFailure, RecordDashboard> fetchDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => TaskEither.right(dashboardFor(selectedDate, filterType: filterType));

  @override
  Future<RecordDashboard> signedOutDashboard(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => Future.value(dashboardFor(selectedDate, filterType: filterType));

  static RecordDashboard dashboardFor(
    DateTime selectedDate, {
    RecordEntryType? filterType,
  }) => RecordDashboard(
    selectedDate: selectedDate,
    selectedDay: selectedDate.day,
    monthDays: _monthDays,
    quickActions: _quickActions,
    summary: const RecordDaySummary(items: _summaryItems),
    filters: _filtersFor(filterType),
    timeline: _timelineFor(filterType),
    trends: _trends,
  );

  static const _activeTypes = <RecordEntryType>{
    RecordEntryType.meal,
    RecordEntryType.vitals,
    RecordEntryType.water,
    RecordEntryType.medication,
    RecordEntryType.sleep,
    RecordEntryType.note,
  };

  static final _monthDays = <RecordCalendarDay>[
    ...List<RecordCalendarDay>.generate(
      4,
      (index) => RecordCalendarDay(
        day: 27 + index,
        inMonth: false,
        selected: false,
        markers: const <SemanticColor>[],
      ),
    ),
    ...List<RecordCalendarDay>.generate(30, (index) {
      final day = index + 1;
      final marked =
          day <= 12 || day == 14 || day == 15 || day == 17 || day == 18;
      return RecordCalendarDay(
        day: day,
        inMonth: true,
        selected: day == 18,
        markers: marked
            ? const <SemanticColor>[SemanticColor.primary]
            : const <SemanticColor>[],
        hasAlert: day == 15,
      );
    }),
  ];

  static const _quickActions = <RecordQuickAction>[
    RecordQuickAction(
      type: RecordEntryType.meal,
      icon: SemanticIcons.recordMeal,
      titleKey: RecordCopyKey.typeMeal,
      subtitleKey: RecordCopyKey.summaryTimesUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordQuickAction(
      type: RecordEntryType.water,
      icon: SemanticIcons.recordWater,
      titleKey: RecordCopyKey.typeWater,
      subtitleKey: RecordCopyKey.summaryMlUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordQuickAction(
      type: RecordEntryType.vitals,
      icon: SemanticIcons.profileCondition,
      titleKey: RecordCopyKey.typeVitals,
      subtitleKey: RecordCopyKey.summaryLatestVitalTitle,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordQuickAction(
      type: RecordEntryType.medication,
      icon: SemanticIcons.recordMedicine,
      titleKey: RecordCopyKey.typeMedication,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordQuickAction(
      type: RecordEntryType.sleep,
      icon: SemanticIcons.recordMoon,
      titleKey: RecordCopyKey.typeSleep,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordQuickAction(
      type: RecordEntryType.note,
      icon: SemanticIcons.recordNote,
      titleKey: RecordCopyKey.typeNote,
      subtitleKey: RecordCopyKey.summaryRecorded,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static const _summaryItems = <RecordSummaryItem>[
    RecordSummaryItem(
      type: RecordEntryType.water,
      icon: SemanticIcons.recordWater,
      titleKey: RecordCopyKey.summaryWaterTitle,
      value: '1500',
      unitKey: RecordCopyKey.summaryMlUnit,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordSummaryItem(
      type: RecordEntryType.sleep,
      icon: SemanticIcons.recordMoon,
      titleKey: RecordCopyKey.typeSleep,
      value: '7.2',
      unitKey: RecordCopyKey.summaryTimesUnit,
      detailKey: RecordCopyKey.summaryNormal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
    RecordSummaryItem(
      type: RecordEntryType.vitals,
      icon: SemanticIcons.profileCondition,
      titleKey: RecordCopyKey.summaryLatestVitalTitle,
      value: '118/76',
      detailKey: RecordCopyKey.summaryNormal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
    ),
  ];

  static const _filters = <RecordFilter>[
    RecordFilter(
      type: RecordEntryType.meal,
      titleKey: RecordCopyKey.typeMeal,
      icon: SemanticIcons.recordMeal,
      accent: SemanticColor.primary,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.water,
      titleKey: RecordCopyKey.typeWater,
      icon: SemanticIcons.recordWater,
      accent: SemanticColor.primary,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.vitals,
      titleKey: RecordCopyKey.typeVitals,
      icon: SemanticIcons.profileCondition,
      accent: SemanticColor.primary,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.medication,
      titleKey: RecordCopyKey.typeMedication,
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.sleep,
      titleKey: RecordCopyKey.typeSleep,
      icon: SemanticIcons.recordMoon,
      accent: SemanticColor.primary,
      selected: true,
    ),
    RecordFilter(
      type: RecordEntryType.note,
      titleKey: RecordCopyKey.typeNote,
      icon: SemanticIcons.recordNote,
      accent: SemanticColor.primary,
      selected: true,
    ),
  ];

  static List<RecordFilter> _filtersFor(RecordEntryType? filterType) => _filters
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

  static const _timeline = <RecordTimelineEntry>[
    RecordTimelineEntry(
      time: '07:40',
      type: RecordEntryType.meal,
      icon: SemanticIcons.recordMeal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineMealLunch,
      value: '早餐：燕麦牛奶',
      unitKey: RecordCopyKey.summaryTimesUnit,
      detailKey: RecordCopyKey.timelineMealNutrition,
      badgeKey: RecordCopyKey.timelineAiBadge,
      trailingIcon: SemanticIcons.actionNext,
    ),
    RecordTimelineEntry(
      time: '08:05',
      type: RecordEntryType.vitals,
      icon: SemanticIcons.profileCondition,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineBloodPressure,
      value: '晨起血压 118/76',
      detailKey: RecordCopyKey.timelineBloodPressureDetail,
      badgeKey: RecordCopyKey.summaryNormal,
      trailingIcon: SemanticIcons.actionNext,
    ),
    RecordTimelineEntry(
      time: '08:30',
      type: RecordEntryType.medication,
      icon: SemanticIcons.recordMedicine,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineMedicationName,
      value: '服药：苯磺酸氨氯地平片',
      unitKey: RecordCopyKey.summaryTimesUnit,
      detailKey: RecordCopyKey.timelineMedicationDetail,
      trailingIcon: SemanticIcons.statusSuccess,
    ),
    RecordTimelineEntry(
      time: '10:15',
      type: RecordEntryType.water,
      icon: SemanticIcons.recordWater,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeWater,
      value: '250',
      unitKey: RecordCopyKey.summaryMlUnit,
      detailKey: RecordCopyKey.timelineWaterProgress,
      trailingIcon: SemanticIcons.actionNext,
    ),
    RecordTimelineEntry(
      time: '12:45',
      type: RecordEntryType.meal,
      icon: SemanticIcons.recordMeal,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineMealLunch,
      value: '午餐：杂粮饭配清蒸鲈鱼',
      detailKey: RecordCopyKey.timelineMealNutrition,
      badgeKey: RecordCopyKey.timelineManualBadge,
      trailingIcon: SemanticIcons.actionMore,
    ),
    RecordTimelineEntry(
      time: '23:10',
      type: RecordEntryType.sleep,
      icon: SemanticIcons.recordMoon,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.timelineSleepRecord,
      value: '7.2',
      unitKey: RecordCopyKey.summaryTimesUnit,
      detailKey: RecordCopyKey.timelineSleepDetail,
      badgeKey: RecordCopyKey.summaryNormal,
      trailingIcon: SemanticIcons.actionNext,
    ),
    RecordTimelineEntry(
      time: '16:20',
      type: RecordEntryType.note,
      icon: SemanticIcons.recordNote,
      accent: SemanticColor.primary,
      softColor: SemanticColor.neutral,
      titleKey: RecordCopyKey.typeNote,
      value: '午后轻微头胀，休息后缓解',
      trailingIcon: SemanticIcons.actionNext,
    ),
  ];

  static List<RecordTimelineEntry> _timelineFor(RecordEntryType? filterType) {
    final timeline = _timeline.where(
      (entry) => _activeTypes.contains(entry.type),
    );
    if (filterType == null || !_activeTypes.contains(filterType)) {
      return timeline.toList(growable: false);
    }
    return timeline
        .where((entry) => entry.type == filterType)
        .toList(growable: false);
  }

  static const _trends = <RecordTrend>[
    RecordTrend(
      kind: RecordTrendKind.bloodSugar,
      titleKey: RecordCopyKey.trendBloodSugarTitle,
      rangeKey: RecordCopyKey.range7Days,
      color: SemanticColor.primary,
      secondaryColor: SemanticColor.info,
      points: <double>[112, 118, 115, 121, 117, 119, 118],
      secondaryPoints: <double>[74, 71, 76, 73, 70, 72, 71],
      legendKey: RecordCopyKey.trendBloodSugarLegend,
    ),
    RecordTrend(
      kind: RecordTrendKind.hydration,
      titleKey: RecordCopyKey.trendHydrationTitle,
      rangeKey: RecordCopyKey.range30Days,
      color: SemanticColor.info,
      points: <double>[1200, 1400, 1650, 1500, 1750, 1600, 1500],
      bars: <double>[1200, 1400, 1650, 1500, 1750, 1600, 1500],
      legendKey: RecordCopyKey.summaryWaterTitle,
    ),
  ];
}

// ---------------------------------------------------------------------------
// Daily record
// ---------------------------------------------------------------------------

/// Simulated [DailyRecordRepository]: reads return an authored daily record,
/// writes report success.
class SimulatedDailyRecordRepository implements DailyRecordRepository {
  const SimulatedDailyRecordRepository();

  static const _createdAt = '2026-06-18T07:40:00+08:00';

  static const _records = <DailyRecordItem>[
    DailyRecordItem(
      id: 'dr_2026_06_18',
      kind: DailyRecordKind.meal,
      occurredAt: '2026-06-18T07:40:00+08:00',
      occurredTime: '07:40',
      title: '早餐',
      value: '燕麦牛奶配水煮蛋',
      unit: '份',
      note: '蛋白质约 18 g',
      source: 'manual',
      payload: <String, dynamic>{'meal': 'oatmeal_milk', 'calories': 420},
      createdAt: _createdAt,
      updatedAt: _createdAt,
    ),
    DailyRecordItem(
      id: 'dr_2026_06_18_bp',
      kind: DailyRecordKind.vital,
      occurredAt: '2026-06-18T08:05:00+08:00',
      occurredTime: '08:05',
      title: '晨起血压',
      value: '118/76',
      unit: 'mmHg',
      source: 'manual',
      payload: <String, dynamic>{'systolic': 118, 'diastolic': 76},
      createdAt: _createdAt,
      updatedAt: _createdAt,
    ),
    DailyRecordItem(
      id: 'dr_2026_06_18_med',
      kind: DailyRecordKind.note,
      occurredAt: '2026-06-18T08:30:00+08:00',
      occurredTime: '08:30',
      title: '服药',
      value: '苯磺酸氨氯地平片 5 mg',
      unit: '片',
      source: 'reminder',
      payload: <String, dynamic>{'medicine': 'amlodipine', 'dose': '5mg'},
      createdAt: _createdAt,
      updatedAt: _createdAt,
    ),
  ];

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) => TaskEither.right(
    DailyRecordListData(items: _records, total: _records.length),
  );

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) =>
      TaskEither.right(
        const DailyRecordSummaryData(
          summaries: <DailyRecordSummary>[
            DailyRecordSummary(
              kind: DailyRecordKind.meal,
              count: 3,
              latest: _records0,
            ),
            DailyRecordSummary(
              kind: DailyRecordKind.vital,
              count: 2,
              latest: _records1,
            ),
            DailyRecordSummary(kind: DailyRecordKind.water, count: 6),
            DailyRecordSummary(kind: DailyRecordKind.sleep, count: 1),
          ],
        ),
      );
  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) =>
      TaskEither.right(_records.first);

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) => TaskEither.right(
    DailyRecordAttachmentInput(
      objectKey: 'simulated/2026-06-18/meal-01.jpg',
      bucket: 'luminous-simulated',
      provider: 'local',
      fileName: input.fileName ?? 'meal-01.jpg',
      contentType: input.contentType,
      sizeBytes: input.sizeBytes,
      width: 1080,
      height: 1440,
      publicUrl: 'https://cdn.example.invalid/simulated/meal-01.jpg',
    ),
  );

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) => TaskEither.right(
    DailyRecordCandidateResult(
      locale: 'zh-CN',
      generatedAt: _createdAt,
      confirmationHint: '确认后写入当日记录',
      items: <DailyRecordCandidateItem>[
        DailyRecordCandidateItem(
          kind: DailyRecordKind.water,
          occurredAt: occurredAt,
          title: '饮水',
          value: '250',
          unit: 'ml',
          rationale: '文本中出现饮品容量，按 250 ml 一条候选。',
        ),
        DailyRecordCandidateItem(
          kind: DailyRecordKind.symptom,
          occurredAt: occurredAt,
          title: '头胀',
          note: text,
          rationale: '文本描述身体感受，归为症状记录。',
        ),
      ],
    ),
  );

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) => TaskEither.right(_itemFor(input));

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) => TaskEither.right(_records.first);

  @override
  TaskEither<LucentFailure, void> delete(String id) => TaskEither.right(null);

  static DailyRecordItem _itemFor(DailyRecordCreateInput input) =>
      DailyRecordItem(
        id: 'dr_2026_06_18',
        kind: input.kind,
        occurredAt: input.occurredAt,
        occurredTime: input.occurredTime,
        title: input.title,
        value: input.value,
        unit: input.unit,
        note: input.note,
        source: 'simulated',
        payload: input.payload,
        createdAt: _createdAt,
        updatedAt: _createdAt,
      );
}

// Named aliases keep the const summary list above readable.
const DailyRecordItem _records0 = DailyRecordItem(
  id: 'dr_2026_06_18',
  kind: DailyRecordKind.meal,
  occurredAt: '2026-06-18T07:40:00+08:00',
  occurredTime: '07:40',
  title: '早餐',
  value: '燕麦牛奶配水煮蛋',
  unit: '份',
  source: 'manual',
  createdAt: SimulatedDailyRecordRepository._createdAt,
  updatedAt: SimulatedDailyRecordRepository._createdAt,
);

const DailyRecordItem _records1 = DailyRecordItem(
  id: 'dr_2026_06_18_bp',
  kind: DailyRecordKind.vital,
  occurredAt: '2026-06-18T08:05:00+08:00',
  occurredTime: '08:05',
  title: '晨起血压',
  value: '118/76',
  unit: 'mmHg',
  source: 'manual',
  createdAt: SimulatedDailyRecordRepository._createdAt,
  updatedAt: SimulatedDailyRecordRepository._createdAt,
);

// ---------------------------------------------------------------------------
// Review dashboard
// ---------------------------------------------------------------------------

/// Simulated [ReviewDashboardRepository] backing the Review tab capture.
class SimulatedReviewDashboardRepository implements ReviewDashboardRepository {
  const SimulatedReviewDashboardRepository();

  @override
  TaskEither<LucentFailure, ReviewDashboard> fetchDashboard(
    ReviewDashboardQuery query,
  ) => TaskEither.right(_dashboardFor(query));

  @override
  Future<ReviewDashboard> get signedOutDashboard => Future.value(
    _dashboardFor(
      const ReviewDashboardQuery(range: ReviewDashboardRange.last7Days),
    ),
  );

  static ReviewDashboard _dashboardFor(ReviewDashboardQuery query) {
    final startDate =
        query.startDate ?? clock.now().subtract(const Duration(days: 7));
    final endDate = query.endDate ?? clock.now();
    return _dashboard.copyWith(
      range: query.range,
      startDate: _dateOnly(startDate),
      endDate: _dateOnly(endDate),
    );
  }

  static String _dateOnly(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static ReviewObservedMetric _metric({
    required double value,
    required int observedCount,
    required int expectedCount,
  }) => ReviewObservedMetric(
    value: value,
    state: ReviewObservedMetricState.observed,
    coverage: ReviewObservedMetricCoverage.sufficient,
    sources: const <ReviewObservedMetricSource>[
      ReviewObservedMetricSource.manual,
      ReviewObservedMetricSource.derived,
    ],
    observedCount: observedCount,
    expectedCount: expectedCount,
    windowStart: '2026-06-12',
    windowEnd: '2026-06-18',
  );

  static const _adherenceSparkline = <double>[74, 78, 80, 79, 84, 81, 82];

  static final _dashboard = ReviewDashboard(
    range: ReviewDashboardRange.last7Days,
    startDate: _dateOnly(clock.now().subtract(const Duration(days: 7))),
    endDate: _dateOnly(clock.now()),
    generatedAt: clock.now().toIso8601String(),
    metrics: <ReviewMetric>[
      ReviewMetric(
        kind: ReviewDataKind.medication,
        icon: SemanticIcons.recordMedicine,
        color: SemanticColor.primary,
        value: '82',
        unit: '%',
        status: ReviewStatus.good,
        delta: '+4%',
        direction: ReviewMetricDirection.up,
        sparkline: _adherenceSparkline,
        observedMetric: _metric(
          value: 82,
          observedCount: 23,
          expectedCount: 28,
        ),
      ),
      ReviewMetric(
        kind: ReviewDataKind.water,
        icon: SemanticIcons.recordWater,
        color: SemanticColor.info,
        value: '1500',
        unit: 'ml',
        status: ReviewStatus.stable,
        delta: '+120 ml',
        direction: ReviewMetricDirection.up,
        sparkline: const <double>[1200, 1400, 1650, 1500, 1750, 1600, 1500],
        observedMetric: _metric(
          value: 1500,
          observedCount: 6,
          expectedCount: 8,
        ),
      ),
      ReviewMetric(
        kind: ReviewDataKind.sleep,
        icon: SemanticIcons.recordMoon,
        color: SemanticColor.neutral,
        value: '7.2',
        unit: 'h',
        status: ReviewStatus.good,
        delta: '-0.3 h',
        direction: ReviewMetricDirection.down,
        sparkline: const <double>[6.8, 7.1, 7.4, 7.0, 7.6, 7.3, 7.2],
        observedMetric: _metric(value: 7.2, observedCount: 7, expectedCount: 7),
      ),
      ReviewMetric(
        kind: ReviewDataKind.general,
        icon: SemanticIcons.profileCondition,
        color: SemanticColor.success,
        value: '118/76',
        unit: 'mmHg',
        status: ReviewStatus.good,
        delta: '持平',
        direction: ReviewMetricDirection.flat,
        sparkline: const <double>[120, 119, 121, 117, 118, 119, 118],
        observedMetric: _metric(value: 118, observedCount: 7, expectedCount: 7),
      ),
    ],
    trends: <ReviewTrendSeries>[
      ReviewTrendSeries(
        kind: ReviewDataKind.medication,
        color: SemanticColor.primary,
        unit: '%',
        values: _adherenceSparkline,
        currentValue: '82',
        observedMetric: _metric(
          value: 82,
          observedCount: 23,
          expectedCount: 28,
        ),
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.water,
        color: SemanticColor.info,
        unit: 'ml',
        values: const <double>[1200, 1400, 1650, 1500, 1750, 1600, 1500],
        currentValue: '1500',
        observedMetric: _metric(
          value: 1500,
          observedCount: 6,
          expectedCount: 8,
        ),
      ),
      ReviewTrendSeries(
        kind: ReviewDataKind.sleep,
        color: SemanticColor.neutral,
        unit: 'h',
        values: const <double>[6.8, 7.1, 7.4, 7.0, 7.6, 7.3, 7.2],
        currentValue: '7.2',
        observedMetric: _metric(value: 7.2, observedCount: 7, expectedCount: 7),
      ),
    ],
    findings: const <ReviewFinding>[
      ReviewFinding(
        kind: ReviewInsightKind.medication,
        icon: SemanticIcons.reportAdherence,
        color: SemanticColor.primary,
        title: '服药依从率 82%',
        body: '本周 28 次计划服药完成 23 次，晚间那一次最容易漏服。',
      ),
      ReviewFinding(
        kind: ReviewInsightKind.hydration,
        icon: SemanticIcons.recordWater,
        color: SemanticColor.info,
        title: '饮水集中在上午',
        body: '1500 ml 中有 1000 ml 在 12:00 前完成，午后偏少。',
      ),
      ReviewFinding(
        kind: ReviewInsightKind.sleep,
        icon: SemanticIcons.recordMoon,
        color: SemanticColor.neutral,
        title: '入睡时间稳定',
        body: '最近 7 天平均入睡 23:10，睡眠时长在 6.8 至 7.6 小时之间。',
      ),
    ],
    exportActions: const <ReviewExportAction>[
      ReviewExportAction(
        kind: ReviewExportKind.hospital,
        icon: SemanticIcons.medicineKit,
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.monthly,
        icon: FLucideIcons.barChart,
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.print,
        icon: SemanticIcons.actionExport,
        color: SemanticColor.primary,
      ),
      ReviewExportAction(
        kind: ReviewExportKind.clinicShare,
        icon: SemanticIcons.actionShare,
        color: SemanticColor.primary,
      ),
    ],
    patterns: const <ReviewPatternCard>[
      ReviewPatternCard(
        kind: ReviewInsightKind.medication,
        icon: SemanticIcons.reportAdherence,
        color: SemanticColor.primary,
        title: '晚间漏服偏多',
        status: ReviewStatus.needsAttention,
        body: '近 7 天有 5 次 20:00 的药未记录，白天几乎不缺席。',
        sparkline: _adherenceSparkline,
      ),
      ReviewPatternCard(
        kind: ReviewInsightKind.hydration,
        icon: SemanticIcons.recordWater,
        color: SemanticColor.info,
        title: '午后饮水偏低',
        status: ReviewStatus.stable,
        body: '14:00 至 18:00 的平均饮水为 210 ml。',
        sparkline: <double>[420, 380, 260, 240, 210, 230, 210],
      ),
      ReviewPatternCard(
        kind: ReviewInsightKind.sleep,
        icon: SemanticIcons.recordMoon,
        color: SemanticColor.neutral,
        title: '周末睡得更好',
        status: ReviewStatus.good,
        body: '周末平均 7.5 小时，工作日平均 7.0 小时。',
        sparkline: <double>[6.9, 7.0, 7.1, 7.0, 7.2, 7.5, 7.6],
      ),
      ReviewPatternCard(
        kind: ReviewInsightKind.general,
        icon: SemanticIcons.reportTrend,
        color: SemanticColor.success,
        title: '血压保持平稳',
        status: ReviewStatus.good,
        body: '晨起血压 7 天都在 117–121 / 74–78 mmHg 区间。',
        sparkline: <double>[120, 119, 121, 117, 118, 119, 118],
      ),
    ],
    aiSummaryEnabled: true,
  );
}
