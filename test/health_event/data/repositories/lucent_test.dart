import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lucent_api/lucent_api.dart' as api;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/health_event/data/repositories/lucent.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/task_either.dart';

class _MockHealthEventsApi extends Mock implements api.HealthEventsApi {}

class _HealthEventsControllerCreateV1RequestFake extends Fake
    implements api.HealthEventsControllerCreateV1Request {}

class _HealthEventsControllerUpsertCheckInV1RequestFake extends Fake
    implements api.HealthEventsControllerUpsertCheckInV1Request {}

class _HealthEventsControllerEndV1RequestFake extends Fake
    implements api.HealthEventsControllerEndV1Request {}

void main() {
  late _MockHealthEventsApi healthEventsApi;
  late LucentHealthEventRepository repository;

  setUpAll(() {
    registerFallbackValue(_HealthEventsControllerCreateV1RequestFake());
    registerFallbackValue(_HealthEventsControllerUpsertCheckInV1RequestFake());
    registerFallbackValue(_HealthEventsControllerEndV1RequestFake());
  });

  setUp(() {
    healthEventsApi = _MockHealthEventsApi();
    repository = LucentHealthEventRepository(apiClient: healthEventsApi);
  });

  group('fetchActive', () {
    test('maps generated event response into domain data', () async {
      when(
        () => healthEventsApi.healthEventsControllerActiveV1(),
      ).thenAnswer((_) async => _activeResponse(_eventDto()));

      final event = await expectTaskRight(repository.fetchActive());

      expect(event, isNotNull);
      expect(event!.id, 'event-1');
      expect(event.status, HealthEventStatus.active);
      expect(event.outcome, HealthEventOutcome.improved);
      expect(event.checkIn?.date, '2026-08-09');
      expect(event.coverage.checkInCount, 3);
    });

    test('maps an empty active response to Right(null)', () async {
      when(
        () => healthEventsApi.healthEventsControllerActiveV1(),
      ).thenAnswer((_) async => _activeResponse(null));

      expect(await expectTaskRight(repository.fetchActive()), isNull);
    });

    test(
      'maps an active 404 to Right(null) — no active event is normal',
      () async {
        when(
          () => healthEventsApi.healthEventsControllerActiveV1(),
        ).thenThrow(_dioException(404));

        expect(await expectTaskRight(repository.fetchActive()), isNull);
      },
    );

    test('maps an active 404 Problem Details to Right(null)', () async {
      when(
        () => healthEventsApi.healthEventsControllerActiveV1(),
      ).thenThrow(_problemDetails(404, code: 'EVENT_NOT_FOUND'));

      expect(await expectTaskRight(repository.fetchActive()), isNull);
    });

    test('maps active network failure to Left(network)', () async {
      when(
        () => healthEventsApi.healthEventsControllerActiveV1(),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(repository.fetchActive());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });

    test('maps a non-string field in the response to Left(unknown) keeping the '
        'cause (protocol invariant)', () async {
      final malformed = _eventDto().toJson()..['endedAt'] = 123;
      when(() => healthEventsApi.healthEventsControllerActiveV1()).thenAnswer(
        (_) async =>
            _activeResponse(api.HealthEventItemDto.fromJson(malformed)),
      );

      final failure = await expectTaskLeft(repository.fetchActive());
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<CheckedFromJsonException>());
    });
  });

  group('fetchById', () {
    test('maps detail response into domain data', () async {
      when(
        () => healthEventsApi.healthEventsControllerGetV1(id: 'event-1'),
      ).thenAnswer((_) async => _eventResponse(_eventDto()));

      final detail = await expectTaskRight(repository.fetchById('event-1'));
      expect(detail?.title, 'Cold observation');
      expect(detail?.id, 'event-1');
    });

    test('maps a detail 404 to Right(null)', () async {
      when(
        () => healthEventsApi.healthEventsControllerGetV1(id: 'event-1'),
      ).thenThrow(_dioException(404));

      expect(await expectTaskRight(repository.fetchById('event-1')), isNull);
    });
  });

  group('fetchHistory', () {
    test('maps history response into domain data', () async {
      when(
        () => healthEventsApi.healthEventsControllerListV1(),
      ).thenAnswer((_) async => _listResponse([_eventDto()]));

      final history = await expectTaskRight(repository.fetchHistory());
      expect(history.single.id, 'event-1');
    });

    test('keeps a legal empty history as Right', () async {
      when(
        () => healthEventsApi.healthEventsControllerListV1(),
      ).thenAnswer((_) async => _listResponse(const []));

      expect(await expectTaskRight(repository.fetchHistory()), isEmpty);
    });

    test(
      'maps empty history success body to Left(network, emptyResponse)',
      () async {
        when(
          () => healthEventsApi.healthEventsControllerListV1(),
        ).thenAnswer((_) async => _emptyListResponse());

        final failure = await expectTaskLeft(repository.fetchHistory());
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => healthEventsApi.healthEventsControllerListV1(),
      ).thenThrow(_problemDetails(404, code: 'EVENT_NOT_FOUND'));

      final failure = await expectTaskLeft(repository.fetchHistory());
      expect(failure.code, 'EVENT_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test('maps history network failure to Left(network)', () async {
      when(
        () => healthEventsApi.healthEventsControllerListV1(),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(repository.fetchHistory());
      expect(failure.kind, LucentFailureKind.network);
    });
  });

  group('writes', () {
    test('maps successful writes, detail, and history responses', () async {
      when(
        () => healthEventsApi.healthEventsControllerCreateV1(
          healthEventsControllerCreateV1Request: any(
            named: 'healthEventsControllerCreateV1Request',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_eventDto()));
      when(
        () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
          id: any(named: 'id'),
          date: any(named: 'date'),
          healthEventsControllerUpsertCheckInV1Request: any(
            named: 'healthEventsControllerUpsertCheckInV1Request',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_eventDto()));
      when(
        () => healthEventsApi.healthEventsControllerEndV1(
          id: any(named: 'id'),
          healthEventsControllerEndV1Request: any(
            named: 'healthEventsControllerEndV1Request',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_eventDto()));

      final created = await expectTaskRight(
        repository.create(
          title: 'Cold observation',
          reasonRecordId: 'record-1',
          currentMedicineIds: const ['medicine-1'],
        ),
      );
      final checkedIn = await expectTaskRight(
        repository.checkIn(
          eventId: 'event-1',
          date: '2026-08-09',
          outcome: HealthEventOutcome.improved,
        ),
      );
      final ended = await expectTaskRight(
        repository.end(
          eventId: 'event-1',
          outcome: HealthEventOutcome.unchanged,
        ),
      );

      expect(created.id, 'event-1');
      expect(checkedIn.checkIn?.outcome, HealthEventOutcome.improved);
      expect(ended.coverage.checkInCount, 3);

      final createCall =
          verify(
                () => healthEventsApi.healthEventsControllerCreateV1(
                  healthEventsControllerCreateV1Request: captureAny(
                    named: 'healthEventsControllerCreateV1Request',
                  ),
                ),
              ).captured.single
              as api.HealthEventsControllerCreateV1Request;
      expect(createCall.title, 'Cold observation');
      expect(createCall.reasonRecordId, 'record-1');
      expect(createCall.currentMedicineIds, ['medicine-1']);
      verify(
        () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
          id: 'event-1',
          date: DateTime.parse('2026-08-09'),
          healthEventsControllerUpsertCheckInV1Request: captureAny(
            named: 'healthEventsControllerUpsertCheckInV1Request',
          ),
        ),
      ).called(1);
      verify(
        () => healthEventsApi.healthEventsControllerEndV1(
          id: 'event-1',
          healthEventsControllerEndV1Request: captureAny(
            named: 'healthEventsControllerEndV1Request',
          ),
        ),
      ).called(1);
    });

    test('rejects missing write response data as Left(unknown) keeping the '
        'StateError cause (protocol invariant)', () async {
      when(
        () => healthEventsApi.healthEventsControllerCreateV1(
          healthEventsControllerCreateV1Request: any(
            named: 'healthEventsControllerCreateV1Request',
          ),
        ),
      ).thenAnswer((_) async => _emptyEventResponse());
      when(
        () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
          id: any(named: 'id'),
          date: any(named: 'date'),
          healthEventsControllerUpsertCheckInV1Request: any(
            named: 'healthEventsControllerUpsertCheckInV1Request',
          ),
        ),
      ).thenAnswer((_) async => _emptyEventResponse());
      when(
        () => healthEventsApi.healthEventsControllerEndV1(
          id: any(named: 'id'),
          healthEventsControllerEndV1Request: any(
            named: 'healthEventsControllerEndV1Request',
          ),
        ),
      ).thenAnswer((_) async => _emptyEventResponse());

      for (final task in [
        repository.create(title: 'Cold observation'),
        repository.checkIn(
          eventId: 'event-1',
          date: '2026-08-09',
          outcome: HealthEventOutcome.improved,
        ),
        repository.end(
          eventId: 'event-1',
          outcome: HealthEventOutcome.unchanged,
        ),
      ]) {
        final failure = await expectTaskLeft(task);
        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isA<StateError>());
      }
    });

    test('maps an unknown status enum to Left(unknown) keeping the StateError '
        'cause (protocol invariant)', () async {
      when(
        () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
          id: any(named: 'id'),
          date: any(named: 'date'),
          healthEventsControllerUpsertCheckInV1Request: any(
            named: 'healthEventsControllerUpsertCheckInV1Request',
          ),
        ),
      ).thenAnswer(
        (_) async => _eventResponse(
          _eventDto(status: api.HealthEventStatus.unknownDefaultOpenApi),
        ),
      );

      final failure = await expectTaskLeft(
        repository.checkIn(
          eventId: 'event-1',
          date: '2026-08-09',
          outcome: HealthEventOutcome.improved,
        ),
      );
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<StateError>());
    });

    test('maps an unknown outcome enum to Left(unknown) keeping the StateError '
        'cause (protocol invariant)', () async {
      when(
        () => healthEventsApi.healthEventsControllerEndV1(
          id: any(named: 'id'),
          healthEventsControllerEndV1Request: any(
            named: 'healthEventsControllerEndV1Request',
          ),
        ),
      ).thenAnswer(
        (_) async => _eventResponse(
          _eventDto(
            checkInOutcome: api.HealthEventOutcome.unknownDefaultOpenApi,
          ),
        ),
      );

      final failure = await expectTaskLeft(
        repository.end(
          eventId: 'event-1',
          outcome: HealthEventOutcome.unchanged,
        ),
      );
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<StateError>());
    });

    test(
      '404 Problem Details on writes keeps code and status as a Left',
      () async {
        final problem = _problemDetails(404, code: 'EVENT_NOT_FOUND');
        when(
          () => healthEventsApi.healthEventsControllerCreateV1(
            healthEventsControllerCreateV1Request: any(
              named: 'healthEventsControllerCreateV1Request',
            ),
          ),
        ).thenThrow(problem);
        when(
          () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
            id: any(named: 'id'),
            date: any(named: 'date'),
            healthEventsControllerUpsertCheckInV1Request: any(
              named: 'healthEventsControllerUpsertCheckInV1Request',
            ),
          ),
        ).thenThrow(problem);
        when(
          () => healthEventsApi.healthEventsControllerEndV1(
            id: any(named: 'id'),
            healthEventsControllerEndV1Request: any(
              named: 'healthEventsControllerEndV1Request',
            ),
          ),
        ).thenThrow(problem);

        for (final task in [
          repository.create(title: 'Cold observation'),
          repository.checkIn(
            eventId: 'event-1',
            date: '2026-08-09',
            outcome: HealthEventOutcome.improved,
          ),
          repository.end(
            eventId: 'event-1',
            outcome: HealthEventOutcome.unchanged,
          ),
        ]) {
          final failure = await expectTaskLeft(task);
          expect(failure.code, 'EVENT_NOT_FOUND');
          expect(failure.statusCode, 404);
          expect(failure.kind, LucentFailureKind.business);
        }
      },
    );

    test('network failure on writes maps to Left(network)', () async {
      when(
        () => healthEventsApi.healthEventsControllerCreateV1(
          healthEventsControllerCreateV1Request: any(
            named: 'healthEventsControllerCreateV1Request',
          ),
        ),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(
        repository.create(title: 'Cold observation'),
      );
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });

    test(
      'non-Problem Details error body propagates FormatException from run()',
      () async {
        when(
          () => healthEventsApi.healthEventsControllerCreateV1(
            healthEventsControllerCreateV1Request: any(
              named: 'healthEventsControllerCreateV1Request',
            ),
          ),
        ).thenThrow(_nonProblemBody400());

        await expectLater(
          repository.create(title: 'Cold observation').run(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

Response<api.HealthEventItemDto> _activeResponse(api.HealthEventItemDto? data) {
  return Response<api.HealthEventItemDto>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events/active'),
    statusCode: 200,
    data: data,
  );
}

Response<api.HealthEventResponseDto> _eventResponse(
  api.HealthEventItemDto data,
) {
  return Response<api.HealthEventResponseDto>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
    data: api.HealthEventResponseDto.fromJson(data.toJson()),
  );
}

Response<api.HealthEventResponseDto> _emptyEventResponse() {
  return Response<api.HealthEventResponseDto>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
  );
}

Response<api.HealthEventListResponseDto> _listResponse(
  List<api.HealthEventItemDto> items,
) {
  return Response<api.HealthEventListResponseDto>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
    data: api.HealthEventListResponseDto(items: items, total: items.length),
  );
}

Response<api.HealthEventListResponseDto> _emptyListResponse() {
  return Response<api.HealthEventListResponseDto>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
  );
}

api.HealthEventItemDto _eventDto({
  String? endedAt,
  String? reasonRecordId,
  api.HealthEventStatus status = api.HealthEventStatus.active,
  api.HealthEventOutcome checkInOutcome = api.HealthEventOutcome.improved,
}) {
  return api.HealthEventItemDto(
    kind: api.HealthEventKind.symptom,
    id: 'event-1',
    title: 'Cold observation',
    status: status,
    startedAt: '2026-08-08T16:00:00.000Z',
    endedAt: endedAt,
    outcome: api.HealthEventOutcome.improved,
    reasonRecordId: reasonRecordId,
    currentMedicineIds: const ['medicine-1'],
    checkIn: api.HealthEventCheckInResponseDto(
      id: 'check-in-1',
      eventId: 'event-1',
      date: '2026-08-09',
      outcome: checkInOutcome,
      createdAt: '2026-08-09T01:00:00.000Z',
      updatedAt: '2026-08-09T01:00:00.000Z',
    ),
    coverage: api.HealthEventCoverageDto(
      checkInCount: 3,
      firstCheckInDate: '2026-08-07',
      lastCheckInDate: '2026-08-09',
    ),
  );
}

DioException _dioException(int statusCode) {
  final request = RequestOptions(path: '/api/v1/user/health-events/active');
  return DioException(
    requestOptions: request,
    response: Response<void>(requestOptions: request, statusCode: statusCode),
  );
}

/// A Problem Details error body served with `application/problem+json`.
DioException _problemDetails(int statusCode, {required String code}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
      statusCode: statusCode,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Not found',
        'detail': '健康事件不存在或不可用',
        'code': code,
      },
    ),
  );
}

/// A network timeout with no HTTP response.
DioException _connectionTimeout() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    type: DioExceptionType.connectionTimeout,
  );
}

/// A 400 body that is not Problem Details (protocol invariant violation).
DioException _nonProblemBody400() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
      statusCode: 400,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/json'],
      }),
      data: {'error': 'oops'},
    ),
  );
}
