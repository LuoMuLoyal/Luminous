// Simulated event-review data for the screenshot generator.
//
// The Review tab reaches four providers that are all backed by the real
// `ReviewRepository`. Leaving them unmounted makes the page issue a real
// network call, whose `.timeout(_reviewTimeout)` then leaves a pending 10s
// timer and fails the capture with "A Timer is still pending" even though the
// PNG was already written. Overriding the providers directly is both cheaper
// and more precise than faking the repository.
//
// All content is new, authored Chinese clinical data (user 陈静, 2026 dates).
import 'package:luminous/features/review/domain/entities/review.dart';

/// One active 健康事件 with a fully populated four-section review.
EventReview buildSimulatedEventReview() {
  const windowStart = '2026-06-12';
  const windowEnd = '2026-06-18';

  return const EventReview(
    event: ReviewEvent(
      id: 'sim_ev_2026_06_12_hypertension',
      kind: ReviewEventKind.symptom,
      title: '近一周午后头晕',
      status: ReviewEventStatus.active,
      startedAt: '2026-06-12T15:20:00+08:00',
      currentMedicineIds: <String>[
        'cm_amlodipine_2026',
        'cm_aspirin_2026',
        'cm_metformin_2026',
      ],
    ),
    sections: ReviewSections(
      whatHappened: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(
          code: 'health_event',
          arguments: <String, dynamic>{
            'startedAt': '2026-06-12T15:20:00+08:00',
            'endedAt': null,
            'reasonRecordTitle': '午后头晕',
            'symptomRecordCount': 5,
            'checkInCount': 6,
          },
        ),
      ),
      keyChanges: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(
          code: 'observed_changes',
          arguments: <String, dynamic>{
            'checkIns': <String, dynamic>{
              'fromOutcome': 'worsened',
              'toOutcome': 'improved',
              'count': 4,
            },
            'water': <String, dynamic>{
              'direction': 'up',
              'firstValue': 1200,
              'lastValue': 1500,
              'observedDays': 7,
            },
            'sleep': <String, dynamic>{
              'direction': 'down',
              'firstValue': 7.5,
              'lastValue': 7.2,
              'observedDays': 7,
            },
          },
        ),
      ),
      completedActions: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(
          code: 'completed_actions',
          arguments: <String, dynamic>{
            'doseSlots': <String, dynamic>{
              'confirmed': 16,
              'skipped': 2,
              'unconfirmed': 3,
            },
            'checkIns': <Map<String, dynamic>>[
              <String, dynamic>{'date': '2026-06-13', 'outcome': 'unchanged'},
              <String, dynamic>{'date': '2026-06-15', 'outcome': 'improved'},
              <String, dynamic>{'date': '2026-06-18', 'outcome': 'improved'},
            ],
          },
        ),
      ),
      nextStep: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(
          code: 'active_check_in',
          arguments: <String, dynamic>{
            'hasTodayCheckIn': true,
            'redFlags': <Map<String, dynamic>>[
              <String, dynamic>{
                'rule': 'informationGap',
                'medicineName': '盐酸二甲双胍片',
              },
            ],
          },
        ),
      ),
    ),
    coverage: ReviewCoverage(
      checkIns: ReviewCheckInCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.sufficient,
        sources: <ReviewObservedSource>[ReviewObservedSource.manual],
        observedCount: 6,
        expectedCount: 7,
        firstCheckInDate: '2026-06-12',
        lastCheckInDate: '2026-06-18',
        todayCheckIn: ReviewTodayCheckIn(
          date: '2026-06-18',
          outcome: ReviewEventOutcome.improved,
          updatedAt: '2026-06-18T09:05:00+08:00',
        ),
        windowStart: windowStart,
        windowEnd: windowEnd,
      ),
      dailyRecords: ReviewObservedCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.partial,
        sources: <ReviewObservedSource>[
          ReviewObservedSource.manual,
          ReviewObservedSource.derived,
        ],
        observedCount: 9,
        expectedCount: 14,
        windowStart: windowStart,
        windowEnd: windowEnd,
      ),
      doseLogs: ReviewObservedCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.sufficient,
        sources: <ReviewObservedSource>[ReviewObservedSource.reminderPlan],
        observedCount: 16,
        expectedCount: 21,
        windowStart: windowStart,
        windowEnd: windowEnd,
      ),
    ),
    sourceTimestamps: ReviewSourceTimestamps(
      checkIns: '2026-06-18T09:05:00+08:00',
      dailyRecords: '2026-06-18T08:40:00+08:00',
      doseLogs: '2026-06-18T12:35:00+08:00',
    ),
    availableActions: <ReviewAction>[
      ReviewAction.checkIn,
      ReviewAction.endEvent,
      ReviewAction.clinicSummary,
      ReviewAction.export,
    ],
    generatedAt: '2026-06-18T09:30:00+08:00',
  );
}

/// The first page of 事件回顾历史.
ReviewEventPage buildSimulatedReviewHistory() {
  return const ReviewEventPage(
    items: <ReviewEvent>[
      ReviewEvent(
        id: 'sim_ev_2026_06_12_hypertension',
        kind: ReviewEventKind.symptom,
        title: '近一周午后头晕',
        status: ReviewEventStatus.active,
        startedAt: '2026-06-12T15:20:00+08:00',
        currentMedicineIds: <String>['cm_amlodipine_2026'],
      ),
      ReviewEvent(
        id: 'sim_ev_2026_05_20_gastritis',
        kind: ReviewEventKind.symptom,
        title: '二甲双胍餐后胃部不适',
        status: ReviewEventStatus.ended,
        startedAt: '2026-05-20T19:10:00+08:00',
        endedAt: '2026-05-27T10:00:00+08:00',
        outcome: ReviewEventOutcome.improved,
        currentMedicineIds: <String>['cm_metformin_2026'],
      ),
      ReviewEvent(
        id: 'sim_ev_2026_04_08_cold',
        kind: ReviewEventKind.other,
        title: '春季过敏性鼻炎发作',
        status: ReviewEventStatus.ended,
        startedAt: '2026-04-08T07:45:00+08:00',
        endedAt: '2026-04-15T21:30:00+08:00',
        outcome: ReviewEventOutcome.unchanged,
        currentMedicineIds: <String>['cm_aspirin_2026'],
      ),
    ],
    total: 3,
  );
}
