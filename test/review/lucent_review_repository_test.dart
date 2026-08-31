import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/database/daos/review.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/review/data/repositories/lucent_review.dart';
import 'package:luminous/features/review/domain/entities/review.dart';

import '../helpers/task_either.dart';

void main() {
  group('LucentReviewRepository – current', () {
    test(
      'maps a full review preserving sections, coverage and sources',
      () async {
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
          dataSource: _FakeReviewRemoteDataSource(current: _reviewDto()),
        );

        final review = await expectTaskRight(repository.fetchCurrentReview());

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
        dao: _FakeReviewDao(),
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

      final review = await expectTaskRight(repository.fetchCurrentReview());

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
        dao: _FakeReviewDao(),
        dataSource: _FakeReviewRemoteDataSource(current: null),
      );

      final review = await expectTaskRight(repository.fetchCurrentReview());

      expect(review, isNull);
    });

    test(
      'drops unknown available actions but keeps known ones in order',
      () async {
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
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

        final review = await expectTaskRight(repository.fetchCurrentReview());

        expect(review!.availableActions, const [
          ReviewAction.checkIn,
          ReviewAction.export,
        ]);
      },
    );

    test('keeps fact code when arguments are not a JSON object', () async {
      final repository = LucentReviewRepository(
        dao: _FakeReviewDao(),
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

      final review = await expectTaskRight(repository.fetchCurrentReview());

      expect(review!.sections.whatHappened.facts?.code, 'fact.broken');
      expect(review.sections.whatHappened.facts?.arguments, isEmpty);
    });
  });

  group('LucentReviewRepository – history', () {
    test('maps a page of event summaries with total and cursor', () async {
      final repository = LucentReviewRepository(
        dao: _FakeReviewDao(),
        dataSource: _FakeReviewRemoteDataSource(
          page: lucent.EventReviewListResponseDto(
            items: [
              _eventDto(id: 'evt-2', status: lucent.HealthEventStatus.ended),
              _eventDto(id: 'evt-1', status: lucent.HealthEventStatus.active),
            ],
            total: 42,
            nextCursor: '2026-08-01T00:00:00.000Z|evt-2',
          ),
        ),
      );

      final page = await expectTaskRight(repository.fetchHistory(limit: 2));

      expect(page.items, hasLength(2));
      expect(page.items.first.id, 'evt-2');
      expect(page.items.first.status, ReviewEventStatus.ended);
      expect(page.items.last.id, 'evt-1');
      expect(page.total, 42);
      expect(page.nextCursor, '2026-08-01T00:00:00.000Z|evt-2');
    });

    test(
      'forwards status, cursor and limit to the remote data source',
      () async {
        final dataSource = _FakeReviewRemoteDataSource(
          page: lucent.EventReviewListResponseDto(
            items: const [],
            total: 0,
            nextCursor: null,
          ),
        );
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
          dataSource: dataSource,
        );

        await expectTaskRight(
          repository.fetchHistory(
            status: ReviewEventStatus.ended,
            cursor: '2026-08-01T00:00:00.000Z|evt-2',
            limit: 7,
          ),
        );
        expect(dataSource.lastStatus, ReviewEventStatus.ended);
        expect(dataSource.lastCursor, '2026-08-01T00:00:00.000Z|evt-2');
        expect(dataSource.lastLimit, 7);

        // 默认参数：无状态过滤、limit 20。
        await expectTaskRight(repository.fetchHistory());
        expect(dataSource.lastStatus, isNull);
        expect(dataSource.lastCursor, isNull);
        expect(dataSource.lastLimit, 20);
      },
    );
  });

  group('LucentReviewRepository – detail', () {
    test('maps an ended event review with outcome', () async {
      final repository = LucentReviewRepository(
        dao: _FakeReviewDao(),
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

      final review = await expectTaskRight(repository.fetchReview('evt-9'));

      expect(review.event.id, 'evt-9');
      expect(review.event.status, ReviewEventStatus.ended);
      expect(review.event.endedAt, '2026-07-10T00:00:00.000Z');
      expect(review.event.outcome, ReviewEventOutcome.worsened);
      expect(review.event.currentMedicineIds, const ['med-3']);
    });
  });

  group('LucentReviewRepository – failure branches', () {
    test('network failure maps to Left(network)', () async {
      final repository = LucentReviewRepository(
        dao: _FakeReviewDao(),
        dataSource: _FakeReviewRemoteDataSource(
          current: _reviewDto(),
          error: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/reviews/current',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      final failure = await expectTaskLeft(repository.fetchCurrentReview());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });

    test('detail not-found keeps Problem Details code and status', () async {
      final repository = LucentReviewRepository(
        dao: _FakeReviewDao(),
        dataSource: _FakeReviewRemoteDataSource(
          error: DioException(
            requestOptions: RequestOptions(
              path: '/api/v1/user/reports/reviews/evt-x',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: '/api/v1/user/reports/reviews/evt-x',
              ),
              statusCode: 404,
              headers: Headers.fromMap({
                Headers.contentTypeHeader: ['application/problem+json'],
              }),
              data: <String, Object?>{
                'type': 'about:blank',
                'title': 'Not Found',
                'status': 404,
                'detail': '事件回顾不存在',
                'code': 'REVIEW_NOT_FOUND',
              },
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      );

      final failure = await expectTaskLeft(repository.fetchReview('evt-x'));
      expect(failure.code, 'REVIEW_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test(
      'empty success response body maps to Left(network/emptyResponse)',
      () async {
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
          dataSource: _FakeReviewRemoteDataSource(
            page: null,
            error: LucentFailure.network(
              message: 'API 返回空响应体（fetchHistory）',
              networkErrorCode: NetworkErrorCode.emptyResponse,
            ),
          ),
        );

        final failure = await expectTaskLeft(repository.fetchHistory());
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test(
      'non problem+json error body keeps FormatException from .run()',
      () async {
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
          dataSource: _FakeReviewRemoteDataSource(
            error: DioException(
              requestOptions: RequestOptions(
                path: '/api/v1/user/reports/reviews',
              ),
              response: Response(
                requestOptions: RequestOptions(
                  path: '/api/v1/user/reports/reviews',
                ),
                statusCode: 500,
                headers: Headers.fromMap({
                  Headers.contentTypeHeader: ['text/plain'],
                }),
                data: 'boom',
              ),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        await expectLater(
          repository.fetchHistory().run(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'unexpected exception maps to Left(unknown) with cause preserved',
      () async {
        final repository = LucentReviewRepository(
          dao: _FakeReviewDao(),
          dataSource: _FakeReviewRemoteDataSource(
            current: _reviewDto(),
            error: StateError('boom'),
          ),
        );

        final failure = await expectTaskLeft(repository.fetchCurrentReview());
        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isA<StateError>());
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Fake review DAO - returns empty cache so tests exercise the network path
// ---------------------------------------------------------------------------

class _FakeReviewDao implements ReviewDao {
  @override
  Future<String?> fetchCurrent() async => null;

  @override
  Future<String?> fetchHistory(String cacheKey) async => null;

  @override
  Future<void> replaceCurrent(String jsonData) async {}

  @override
  Future<void> replaceHistory(String cacheKey, String jsonData) async {}

  @override
  Future<void> clear() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fake remote data source
// ---------------------------------------------------------------------------

class _FakeReviewRemoteDataSource extends ReviewRemoteDataSource {
  _FakeReviewRemoteDataSource({
    this.current,
    this.page,
    this.detail,
    this.error,
  }) : super(api: lucent.ReportsApi(Dio(BaseOptions())));

  lucent.EventReviewDataDto? current;
  lucent.EventReviewListResponseDto? page;
  lucent.EventReviewDataDto? detail;
  Object? error;

  ReviewEventStatus? lastStatus;
  String? lastCursor;
  int? lastLimit;

  @override
  Future<lucent.EventReviewDataDto?> fetchCurrentReview() async {
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return current;
  }

  @override
  Future<lucent.EventReviewListResponseDto> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int? limit,
  }) async {
    lastStatus = status;
    lastCursor = cursor;
    lastLimit = limit;
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return page!;
  }

  @override
  Future<lucent.EventReviewDataDto> fetchReview(String eventId) async {
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return detail!;
  }
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
