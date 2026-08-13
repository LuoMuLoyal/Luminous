import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/features/report/data/repositories/lucent_review.dart';
import 'package:luminous/features/report/domain/entities/review.dart';

void main() {
  group('LucentReviewRepository – current', () {
    test(
      'maps a full review preserving sections, coverage and sources',
      () async {
        final repository = LucentReviewRepository(
          dataSource: _FakeReviewRemoteDataSource(current: _reviewDto()),
        );

        final review = await repository.fetchCurrentReview();

        expect(review, isNotNull);
        expect(review!.event.id, 'evt-1');
        expect(review.event.kind, ReviewEventKind.symptom);
        expect(review.event.status, ReviewEventStatus.active);
        expect(review.event.endedAt, isNull);
        expect(review.event.outcome, isNull);
        expect(review.event.currentMedicineIds, const ['med-1', 'med-2']);

        // 四段独立状态：available 段携带 facts，unknown 段携带原因码。
        expect(
          review.sections.whatHappened.state,
          ReviewSectionState.available,
        );
        expect(review.sections.whatHappened.facts?.code, 'fact.observed');
        expect(review.sections.whatHappened.facts?.arguments, {
          'count': 3,
          'unit': 'times',
        });
        expect(review.sections.keyChanges.state, ReviewSectionState.unknown);
        expect(
          review.sections.keyChanges.reasonCode,
          ReviewSectionReasonCodes.noObservations,
        );
        expect(
          review.sections.completedActions.state,
          ReviewSectionState.available,
        );
        expect(review.sections.nextStep.state, ReviewSectionState.unknown);
        expect(
          review.sections.nextStep.reasonCode,
          ReviewSectionReasonCodes.insufficientCoverage,
        );

        // coverage 与 source 原样保留。
        expect(review.coverage.checkIns.state, ReviewCoverageState.observed);
        expect(
          review.coverage.checkIns.coverage,
          ReviewCoverageLevel.sufficient,
        );
        expect(review.coverage.checkIns.sources, const [
          ReviewObservedSource.manual,
          ReviewObservedSource.healthPlatform,
        ]);
        expect(review.coverage.checkIns.observedCount, 3);
        expect(
          review.coverage.checkIns.todayCheckIn?.outcome,
          ReviewEventOutcome.improved,
        );
        expect(
          review.coverage.dailyRecords.coverage,
          ReviewCoverageLevel.partial,
        );
        expect(review.coverage.doseLogs.state, ReviewCoverageState.unknown);
        expect(review.coverage.doseLogs.coverage, ReviewCoverageLevel.none);

        expect(review.sourceTimestamps.checkIns, '2026-08-12');
        expect(review.sourceTimestamps.doseLogs, isNull);
        expect(review.availableActions, const [
          ReviewAction.checkIn,
          ReviewAction.endEvent,
          ReviewAction.clinicSummary,
          ReviewAction.export,
        ]);
        expect(review.generatedAt, '2026-08-13T10:00:00.000Z');
      },
    );

    test('preserves unknown enum values instead of collapsing them', () async {
      final repository = LucentReviewRepository(
        dataSource: _FakeReviewRemoteDataSource(
          current: _reviewDto(
            event: lucent.EventReviewEventDto(
              id: 'evt-x',
              kind: lucent.HealthEventKind.unknownDefaultOpenApi,
              title: '未知事件',
              status: lucent.HealthEventStatus.unknownDefaultOpenApi,
              startedAt: '2026-08-01T00:00:00.000Z',
              endedAt: null,
              outcome: lucent.HealthEventOutcome.unknownDefaultOpenApi,
              currentMedicineIds: const [],
            ),
            whatHappened: lucent.EventReviewSectionDto(
              state:
                  lucent.EventReviewSectionDtoStateEnum.unknownDefaultOpenApi,
              reasonCode: lucent
                  .EventReviewSectionDtoReasonCodeEnum
                  .unknownDefaultOpenApi,
            ),
            checkIns: lucent.EventReviewCheckInCoverageDto(
              state: lucent
                  .EventReviewCheckInCoverageDtoStateEnum
                  .unknownDefaultOpenApi,
              coverage: lucent
                  .EventReviewCheckInCoverageDtoCoverageEnum
                  .unknownDefaultOpenApi,
              sources: [
                lucent.EventReviewCheckInCoverageDtoSourcesEnum.manual,
                lucent
                    .EventReviewCheckInCoverageDtoSourcesEnum
                    .unknownDefaultOpenApi,
              ],
              observedCount: 5,
              expectedCount: null,
              firstCheckInDate: null,
              lastCheckInDate: null,
              todayCheckIn: null,
              windowStart: '2026-08-01T00:00:00.000Z',
              windowEnd: '2026-08-13T00:00:00.000Z',
            ),
          ),
        ),
      );

      final review = await repository.fetchCurrentReview();

      expect(review!.event.kind, ReviewEventKind.unknown);
      expect(review.event.status, ReviewEventStatus.unknown);
      expect(review.event.outcome, ReviewEventOutcome.unknown);
      expect(review.sections.whatHappened.state, ReviewSectionState.unknown);
      // 契约外原因码不会被折叠成 null。
      expect(
        review.sections.whatHappened.reasonCode,
        'unknown_default_open_api',
      );
      expect(review.coverage.checkIns.state, ReviewCoverageState.unknown);
      expect(review.coverage.checkIns.coverage, ReviewCoverageLevel.unknown);
      // 来源列表长度与契约一致，未知来源映射为 unknown 成员而不是丢弃。
      expect(review.coverage.checkIns.sources, const [
        ReviewObservedSource.manual,
        ReviewObservedSource.unknown,
      ]);
      expect(review.coverage.checkIns.observedCount, 5);
    });

    test('returns null when the user has no events', () async {
      final repository = LucentReviewRepository(
        dataSource: _FakeReviewRemoteDataSource(current: null),
      );

      final review = await repository.fetchCurrentReview();

      expect(review, isNull);
    });

    test(
      'drops unknown available actions but keeps known ones in order',
      () async {
        final repository = LucentReviewRepository(
          dataSource: _FakeReviewRemoteDataSource(
            current: _reviewDto(
              availableActions: [
                lucent.EventReviewDataDtoAvailableActionsEnum.checkIn,
                lucent
                    .EventReviewDataDtoAvailableActionsEnum
                    .unknownDefaultOpenApi,
                lucent.EventReviewDataDtoAvailableActionsEnum.export_,
              ],
            ),
          ),
        );

        final review = await repository.fetchCurrentReview();

        expect(review!.availableActions, const [
          ReviewAction.checkIn,
          ReviewAction.export,
        ]);
      },
    );

    test('keeps fact code when arguments are not a JSON object', () async {
      final repository = LucentReviewRepository(
        dataSource: _FakeReviewRemoteDataSource(
          current: _reviewDto(
            whatHappened: lucent.EventReviewSectionDto(
              state: lucent.EventReviewSectionDtoStateEnum.available,
              facts: lucent.EventReviewSectionFactsDto(
                code: 'fact.broken',
                arguments: 'not-a-map',
              ),
            ),
          ),
        ),
      );

      final review = await repository.fetchCurrentReview();

      expect(review!.sections.whatHappened.facts?.code, 'fact.broken');
      expect(review.sections.whatHappened.facts?.arguments, isEmpty);
    });
  });

  group('LucentReviewRepository – history', () {
    test('maps a page of event summaries with total and cursor', () async {
      final repository = LucentReviewRepository(
        dataSource: _FakeReviewRemoteDataSource(
          page: lucent.EventReviewListDataDto(
            items: [
              _eventDto(id: 'evt-2', status: lucent.HealthEventStatus.ended),
              _eventDto(id: 'evt-1', status: lucent.HealthEventStatus.active),
            ],
            total: 42,
            nextCursor: '2026-08-01T00:00:00.000Z|evt-2',
          ),
        ),
      );

      final page = await repository.fetchHistory(limit: 2);

      expect(page.items, hasLength(2));
      expect(page.items.first.id, 'evt-2');
      expect(page.items.first.status, ReviewEventStatus.ended);
      expect(page.items.last.id, 'evt-1');
      expect(page.total, 42);
      expect(page.nextCursor, '2026-08-01T00:00:00.000Z|evt-2');
    });
  });

  group('LucentReviewRepository – detail', () {
    test('maps an ended event review with outcome', () async {
      final repository = LucentReviewRepository(
        dataSource: _FakeReviewRemoteDataSource(
          detail: _reviewDto(
            event: lucent.EventReviewEventDto(
              id: 'evt-9',
              kind: lucent.HealthEventKind.other,
              title: '已结束的事件',
              status: lucent.HealthEventStatus.ended,
              startedAt: '2026-07-01T00:00:00.000Z',
              endedAt: '2026-07-10T00:00:00.000Z',
              outcome: lucent.HealthEventOutcome.worsened,
              currentMedicineIds: const ['med-3'],
            ),
          ),
        ),
      );

      final review = await repository.fetchReview('evt-9');

      expect(review.event.id, 'evt-9');
      expect(review.event.status, ReviewEventStatus.ended);
      expect(review.event.endedAt, '2026-07-10T00:00:00.000Z');
      expect(review.event.outcome, ReviewEventOutcome.worsened);
      expect(review.event.currentMedicineIds, const ['med-3']);
    });
  });
}

// ---------------------------------------------------------------------------
// Fake remote data source
// ---------------------------------------------------------------------------

class _FakeReviewRemoteDataSource extends ReviewRemoteDataSource {
  _FakeReviewRemoteDataSource({this.current, this.page, this.detail})
    : super(api: lucent.ReportsApi(Dio(BaseOptions())));

  lucent.EventReviewDataDto? current;
  lucent.EventReviewListDataDto? page;
  lucent.EventReviewDataDto? detail;

  @override
  Future<lucent.EventReviewDataDto?> fetchCurrentReview() async => current;

  @override
  Future<lucent.EventReviewListDataDto> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int? limit,
  }) async => page!;

  @override
  Future<lucent.EventReviewDataDto> fetchReview(String eventId) async =>
      detail!;
}

// ---------------------------------------------------------------------------
// DTO builders
// ---------------------------------------------------------------------------

lucent.EventReviewEventDto _eventDto({
  required String id,
  required lucent.HealthEventStatus status,
}) {
  return lucent.EventReviewEventDto(
    id: id,
    kind: lucent.HealthEventKind.symptom,
    title: '事件 $id',
    status: status,
    startedAt: '2026-08-01T00:00:00.000Z',
    endedAt: null,
    outcome: null,
    currentMedicineIds: const [],
  );
}

lucent.EventReviewDataDto _reviewDto({
  lucent.EventReviewEventDto? event,
  lucent.EventReviewSectionDto? whatHappened,
  lucent.EventReviewCheckInCoverageDto? checkIns,
  List<lucent.EventReviewDataDtoAvailableActionsEnum>? availableActions,
}) {
  return lucent.EventReviewDataDto(
    event:
        event ??
        lucent.EventReviewEventDto(
          id: 'evt-1',
          kind: lucent.HealthEventKind.symptom,
          title: '流感观察',
          status: lucent.HealthEventStatus.active,
          startedAt: '2026-08-01T00:00:00.000Z',
          endedAt: null,
          outcome: null,
          currentMedicineIds: const ['med-1', 'med-2'],
        ),
    sections: lucent.EventReviewSectionsDto(
      whatHappened:
          whatHappened ??
          lucent.EventReviewSectionDto(
            state: lucent.EventReviewSectionDtoStateEnum.available,
            facts: lucent.EventReviewSectionFactsDto(
              code: 'fact.observed',
              arguments: {'count': 3, 'unit': 'times'},
            ),
          ),
      keyChanges: lucent.EventReviewSectionDto(
        state: lucent.EventReviewSectionDtoStateEnum.unknown,
        reasonCode: lucent.EventReviewSectionDtoReasonCodeEnum.noObservations,
      ),
      completedActions: lucent.EventReviewSectionDto(
        state: lucent.EventReviewSectionDtoStateEnum.available,
        facts: lucent.EventReviewSectionFactsDto(
          code: 'fact.doses',
          arguments: {'done': 6, 'expected': 7},
        ),
      ),
      nextStep: lucent.EventReviewSectionDto(
        state: lucent.EventReviewSectionDtoStateEnum.unknown,
        reasonCode:
            lucent.EventReviewSectionDtoReasonCodeEnum.insufficientCoverage,
      ),
    ),
    coverage: lucent.EventReviewCoverageSummaryDto(
      checkIns:
          checkIns ??
          lucent.EventReviewCheckInCoverageDto(
            state: lucent.EventReviewCheckInCoverageDtoStateEnum.observed,
            coverage:
                lucent.EventReviewCheckInCoverageDtoCoverageEnum.sufficient,
            sources: [
              lucent.EventReviewCheckInCoverageDtoSourcesEnum.manual,
              lucent.EventReviewCheckInCoverageDtoSourcesEnum.healthPlatform,
            ],
            observedCount: 3,
            expectedCount: null,
            firstCheckInDate: '2026-08-01',
            lastCheckInDate: '2026-08-12',
            todayCheckIn: lucent.EventReviewTodayCheckInDto(
              date: '2026-08-13',
              outcome: lucent.HealthEventOutcome.improved,
              updatedAt: '2026-08-13T08:30:00.000Z',
            ),
            windowStart: '2026-08-01T00:00:00.000Z',
            windowEnd: '2026-08-13T00:00:00.000Z',
          ),
      dailyRecords: lucent.EventReviewObservedSourceDto(
        state: lucent.EventReviewObservedSourceDtoStateEnum.observed,
        coverage: lucent.EventReviewObservedSourceDtoCoverageEnum.partial,
        sources: const [lucent.EventReviewObservedSourceDtoSourcesEnum.derived],
        observedCount: 2,
        expectedCount: 7,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
      doseLogs: lucent.EventReviewObservedSourceDto(
        state: lucent.EventReviewObservedSourceDtoStateEnum.unknown,
        coverage: lucent.EventReviewObservedSourceDtoCoverageEnum.none,
        sources: const [],
        observedCount: 0,
        expectedCount: null,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
    ),
    sourceTimestamps: lucent.EventReviewSourceTimestampsDto(
      checkIns: '2026-08-12',
      dailyRecords: '2026-08-12T20:00:00.000Z',
      doseLogs: null,
    ),
    availableActions:
        availableActions ??
        const [
          lucent.EventReviewDataDtoAvailableActionsEnum.checkIn,
          lucent.EventReviewDataDtoAvailableActionsEnum.endEvent,
          lucent.EventReviewDataDtoAvailableActionsEnum.clinicSummary,
          lucent.EventReviewDataDtoAvailableActionsEnum.export_,
        ],
    generatedAt: '2026-08-13T10:00:00.000Z',
  );
}
