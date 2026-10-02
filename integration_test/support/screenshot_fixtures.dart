// Realistic fixture data for the page-catalog screenshot harness.
//
// These are NOT placeholder/empty values. Each fixture is shaped exactly like
// the real domain entity and carries plausible clinical content, so a captured
// screenshot shows the page as a real user would see it mid-use: populated
// cards, real numbers, real Chinese labels — not the signed-out empty state.
//
// Keep this file in step with the domain entities it builds. If an entity gains
// a required field, add it here and the compiler will point at the rest.
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';

// ── Helpers ─────────────────────────────────────────────────────────────────

String _todayIso() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

/// An observed metric with a real measured value.
TodayObservedMetric _observed({
  required double value,
  int observedCount = 1,
  int? expectedCount,
}) {
  final date = _todayIso();
  return TodayObservedMetric(
    value: value,
    state: TodayObservedMetricState.observed,
    coverage: TodayObservedMetricCoverage.sufficient,
    sources: const [TodayObservedMetricSource.manual],
    observedCount: observedCount,
    expectedCount: expectedCount,
    windowStart: date,
    windowEnd: date,
  );
}

// ── Today dashboard ─────────────────────────────────────────────────────────

/// A fully-populated Today dashboard.
///
/// Mirrors what a real user with a medication plan, logged hydration, and
/// measured vitals sees: 3 medicines due with 1 pending, 750/2000 ml water,
/// and concrete vital readouts.
TodayDashboard buildPopulatedDashboard() {
  return TodayDashboard(
    user: TodayUserSnapshot(
      moment: todayDayMomentFromHour(DateTime.now().hour),
      hasUnreadNotifications: true,
      updatedAtLabel: '08:42',
    ),
    water: TodayWaterSummary(
      completedCount: 3,
      targetCount: 8,
      observedMetric: _observed(value: 750, observedCount: 3, expectedCount: 8),
    ),
    medication: TodayMedicationSummary(
      medicineCount: 3,
      pendingCount: 1,
      nextDoseTimeLabel: '12:30',
      nextMedicineName: '苯磺酸氨氯地平片',
      observedMetric: _observed(value: 2, observedCount: 2, expectedCount: 3),
    ),
    vitals: [
      TodayVitalSummary(
        type: TodayVitalType.heartRate,
        valueLabel: '72 次/分',
        observedMetric: _observed(value: 72),
      ),
      TodayVitalSummary(
        type: TodayVitalType.bloodPressure,
        valueLabel: '118/76 mmHg',
        observedMetric: _observed(value: 118),
      ),
      TodayVitalSummary(
        type: TodayVitalType.sleep,
        valueLabel: '7.2 h',
        observedMetric: _observed(value: 7.2),
      ),
      TodayVitalSummary(
        type: TodayVitalType.mood,
        valueLabel: '平稳',
        observedMetric: _observed(value: 4),
      ),
    ],
    mealSuggestion: const TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: const TodayEnvironmentSummary(
      signals: <TodayEnvironmentSignal>[
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.pollen,
          level: TodayEnvironmentLevel.high,
        ),
        TodayEnvironmentSignal(
          type: TodayEnvironmentSignalType.uv,
          level: TodayEnvironmentLevel.medium,
        ),
      ],
    ),
    lumiSuggestion: const TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );
}

/// TodayRepository serving [buildPopulatedDashboard] for both states, so the
/// page renders populated regardless of the injected auth session.
class FixtureTodayRepository implements TodayRepository {
  const FixtureTodayRepository();

  @override
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard() =>
      TaskEither.right(buildPopulatedDashboard());

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(buildPopulatedDashboard());
}

// ── Today suggestions ───────────────────────────────────────────────────────

/// The primary card: an adherence warning naming the actual medicine and the
/// real scheduled time it refers to.
TodaySuggestionCard fixturePrimarySuggestion() {
  return TodaySuggestionCard(
    id: 'fixture-suggestion-1',
    type: TodaySuggestionType.compliance,
    cardTone: TodaySuggestionCardTone.urgent,
    icon: 'pill',
    title: '午间这次降压药还没确认服用',
    reason:
        '苯磺酸氨氯地平片按计划应在 12:30 服用，现在已经过去 40 分钟，'
        '近 7 天有 2 天出现午后漏服。',
    evidence: const [
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.reminder,
        label: '今日计划',
        value: '苯磺酸氨氯地平片 5mg · 12:30',
        medicineId: 'fixture-med-1',
      ),
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.record,
        label: '近 7 天依从率',
        value: '5/7 天按时服用',
      ),
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.trend,
        label: '血压趋势',
        value: '午后收缩压平均偏高 6 mmHg',
      ),
    ],
    boundary: '仅依据你记录的用药与血压数据，不构成诊疗建议。',
    primaryAction: const TodaySuggestionAction(
      actionId: 'go_confirm',
      label: '去确认',
      route: '/medicine',
      authRequired: true,
    ),
    // Mirrors `missed_dose_pending`: the secondary action is `skip_dose`, whose
    // server-localized label is 跳过此次. Using a label that collides with a
    // feedback option (e.g. 稍后提醒) would render the same word twice, once per
    // action surface.
    secondaryActions: [
      TodaySuggestionAction(
        actionId: 'skip_dose',
        label: '跳过此次',
        route:
            '/medicine?action=skip&currentMedicineId=fixture-med-1'
            '&reminderId=fixture-rem-1&scheduledFor=${_todayIso()}'
            '&scheduledTime=12:30',
        authRequired: true,
      ),
    ],
    confidence: TodaySuggestionConfidence.high,
    ruleId: 'missed_dose_pending',
    ruleVersion: '2.1.0',
    triggerType: TodaySuggestionTriggerType.timer,
    lifecycleState: TodaySuggestionLifecycleState.active,
    notificationEligible: true,
    feedbackOptions: const [
      TodaySuggestionFeedback.accepted,
      TodaySuggestionFeedback.later,
      TodaySuggestionFeedback.notApplicable,
      TodaySuggestionFeedback.suppress,
    ],
  );
}

/// A "值得注意的变化" card: an evidence-backed trend the user should notice.
TodaySuggestionCard fixtureSecondarySuggestion() {
  return const TodaySuggestionCard(
    id: 'fixture-suggestion-2',
    type: TodaySuggestionType.trend,
    cardTone: TodaySuggestionCardTone.emphasis,
    icon: 'trending-up',
    title: '近 3 天静息心率较上周略升高',
    reason:
        '本周静息心率均值 78 次/分，比上周高 6 次/分，'
        '同期睡眠时长下降约 50 分钟。',
    evidence: [
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.trend,
        label: '静息心率',
        value: '78 次/分（上周 72）',
      ),
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.record,
        label: '睡眠时长',
        value: '平均 6.4 小时（上周 7.2）',
      ),
    ],
    boundary: '趋势仅基于你手动记录的数据，样本较少时仅供参考。',
    primaryAction: TodaySuggestionAction(
      actionId: 'view-trend',
      label: '查看趋势',
      route: '/review',
      authRequired: true,
    ),
    confidence: TodaySuggestionConfidence.medium,
    ruleId: 'trend.resting_hr_shift',
    ruleVersion: '1.4.2',
    triggerType: TodaySuggestionTriggerType.event,
    lifecycleState: TodaySuggestionLifecycleState.active,
  );
}

/// An observation card — the "留意事项" list under the primary suggestion.
TodaySuggestionCard fixtureObservation() {
  return const TodaySuggestionCard(
    id: 'fixture-observation-1',
    type: TodaySuggestionType.coverage,
    cardTone: TodaySuggestionCardTone.soft,
    icon: 'moon',
    title: '最近还缺 1 天睡眠记录',
    reason: '本周有 1 天没有睡眠数据，补齐后趋势判断会更准。',
    evidence: [
      TodaySuggestionEvidence(
        kind: TodaySuggestionEvidenceKind.record,
        label: '本周已记录',
        value: '6/7 天',
      ),
    ],
    boundary: '以下内容仅供参考，不构成待办。',
    primaryAction: TodaySuggestionAction(
      actionId: 'add-record',
      label: '补记录',
      route: '/record/create',
      authRequired: true,
    ),
    confidence: TodaySuggestionConfidence.high,
    ruleId: 'coverage.missing_sleep',
    ruleVersion: '1.0.3',
    triggerType: TodaySuggestionTriggerType.timer,
    lifecycleState: TodaySuggestionLifecycleState.active,
  );
}

/// A populated bundle: primary + secondary + observations.
TodaySuggestionBundle buildPopulatedSuggestionBundle() {
  return TodaySuggestionBundle(
    generatedAt: DateTime.now().toUtc().toIso8601String(),
    materializationStatus: TodaySuggestionMaterializationStatus.ready,
    sourceVersion: 42,
    computedAt: DateTime.now(),
    primary: fixturePrimarySuggestion(),
    secondary: <TodaySuggestionCard>[fixtureSecondarySuggestion()],
    observations: <TodaySuggestionCard>[fixtureObservation()],
  );
}
