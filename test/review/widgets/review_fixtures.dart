import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';

/// Review 展示层 widget 测试共享的领域实体夹具。
///
/// 参数结构与 Lucent event review read model 的契约保持一致（fact code +
/// arguments），arguments 用 Map/List 模拟 JSON 解码后的结构。

ReviewSection reviewFactsSection(String code, Map<String, dynamic> arguments) {
  return ReviewSection(
    state: ReviewSectionState.available,
    facts: ReviewSectionFacts(code: code, arguments: arguments),
  );
}

ReviewSection reviewUnknownSection(String? reasonCode) {
  return ReviewSection(
    state: ReviewSectionState.unknown,
    reasonCode: reasonCode,
  );
}

ReviewEvent reviewEventItem({
  required String id,
  required String title,
  ReviewEventStatus status = ReviewEventStatus.ended,
  ReviewEventOutcome? outcome = ReviewEventOutcome.improved,
  String startedAt = '2026-08-01T00:00:00.000Z',
  String? endedAt = '2026-08-10T00:00:00.000Z',
}) {
  return ReviewEvent(
    id: id,
    kind: ReviewEventKind.symptom,
    title: title,
    status: status,
    startedAt: startedAt,
    endedAt: endedAt,
    outcome: outcome,
    currentMedicineIds: const [],
  );
}

ReviewEventPage reviewHistoryPage(List<ReviewEvent> items) {
  return ReviewEventPage(items: items, total: items.length);
}

/// active 事件 + 四段齐全的回顾，附今日未确认与一条严重过敏 red flag。
EventReview reviewActive({ReviewSections? sections}) {
  return EventReview(
    event: const ReviewEvent(
      id: 'evt-active',
      kind: ReviewEventKind.symptom,
      title: '感冒观察',
      status: ReviewEventStatus.active,
      startedAt: '2026-08-01T00:00:00.000Z',
      endedAt: null,
      outcome: null,
      currentMedicineIds: ['med-1', 'med-2'],
    ),
    sections:
        sections ??
        ReviewSections(
          whatHappened: reviewFactsSection('health_event', {
            'kind': 'symptom',
            'title': '感冒观察',
            'startedAt': '2026-08-01T00:00:00.000Z',
            'endedAt': null,
            'medicineIds': ['med-1', 'med-2'],
            'symptomRecordCount': 5,
            'checkInCount': 3,
          }),
          keyChanges: reviewFactsSection('observed_changes', {
            'checkIns': {
              'direction': 'improved',
              'fromOutcome': 'worsened',
              'toOutcome': 'improved',
              'firstDate': '2026-08-02',
              'lastDate': '2026-08-12',
              'count': 6,
            },
            'water': {
              'direction': 'up',
              'firstValue': 1200,
              'lastValue': 1800,
              'firstDate': '2026-08-02',
              'lastDate': '2026-08-12',
              'observedDays': 8,
            },
            'sleep': null,
          }),
          completedActions: reviewFactsSection('completed_actions', {
            'doseSlots': {'confirmed': 9, 'skipped': 2, 'unconfirmed': 1},
            'checkIns': [
              {'date': '2026-08-02', 'outcome': 'worsened'},
              {'date': '2026-08-03', 'outcome': 'unchanged'},
            ],
          }),
          nextStep: reviewFactsSection('active_check_in', {
            'hasTodayCheckIn': false,
            'redFlags': [
              {
                'rule': 'severeAllergy',
                'medicineName': '阿莫西林',
                'relatedLabel': '青霉素',
              },
            ],
          }),
        ),
    coverage: const ReviewCoverage(
      checkIns: ReviewCheckInCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.partial,
        sources: [ReviewObservedSource.manual],
        observedCount: 3,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
      dailyRecords: ReviewObservedCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.partial,
        sources: [ReviewObservedSource.manual],
        observedCount: 5,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
      doseLogs: ReviewObservedCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.partial,
        sources: [ReviewObservedSource.reminderPlan],
        observedCount: 12,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
    ),
    sourceTimestamps: const ReviewSourceTimestamps(checkIns: '2026-08-12'),
    availableActions: const [ReviewAction.checkIn, ReviewAction.endEvent],
    generatedAt: '2026-08-13T10:00:00.000Z',
  );
}

/// 已结束事件：无 check-in 按钮，outcome 为 improved。
EventReview reviewEnded() {
  return reviewActive().copyWith(
    event: const ReviewEvent(
      id: 'evt-ended',
      kind: ReviewEventKind.symptom,
      title: '感冒观察',
      status: ReviewEventStatus.ended,
      startedAt: '2026-08-01T00:00:00.000Z',
      endedAt: '2026-08-10T00:00:00.000Z',
      outcome: ReviewEventOutcome.improved,
      currentMedicineIds: ['med-1'],
    ),
    sections: reviewActive().sections.copyWith(
      nextStep: reviewFactsSection('event_ended', {'outcome': 'improved'}),
    ),
    availableActions: const [ReviewAction.clinicSummary, ReviewAction.export],
  );
}

/// 部分段落 unknown 的回顾：keyChanges 与 completedActions 缺失。
EventReview reviewPartial() {
  return reviewActive().copyWith(
    sections: reviewActive().sections.copyWith(
      keyChanges: reviewUnknownSection(ReviewSectionReasonCodes.noObservations),
      completedActions: reviewUnknownSection(
        ReviewSectionReasonCodes.noCompletedActions,
      ),
    ),
  );
}
/// 有覆盖率、但没有任何事件历史的周期看板。
///
/// 「确认无事件」的判定要求 dashboard **不是**冷启动（至少一个指标有可用
/// 覆盖），否则记录引导卡会顶替 no-event 解释卡。凡是断言 no-event 渲染的
/// 用例都要带上它。
ReviewDashboard reviewDashboardWithCoverage() {
  const observed = ReviewObservedMetric(
    value: 1.5,
    state: ReviewObservedMetricState.observed,
    coverage: ReviewObservedMetricCoverage.sufficient,
    sources: [ReviewObservedMetricSource.manual],
    observedCount: 4,
    expectedCount: 7,
    windowStart: '2026-08-01',
    windowEnd: '2026-08-07',
  );
  return const ReviewDashboard(
    range: ReviewDashboardRange.last7Days,
    startDate: '2026-08-01',
    endDate: '2026-08-07',
    generatedAt: '2026-08-07T00:00:00.000Z',
    metrics: [
      ReviewMetric(
        kind: ReviewDataKind.water,
        iconName: 'water',
        color: SemanticColor.primary,
        value: '1500',
        unit: 'ml',
        status: ReviewStatus.good,
        delta: '+100',
        direction: ReviewMetricDirection.up,
        sparkline: [1200, 1400, 1500],
        observedMetric: observed,
      ),
    ],
    trends: [],
    findings: [],
    exportActions: [],
    patterns: [],
    aiSummaryEnabled: false,
  );
}
