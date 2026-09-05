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

class _CreateHealthEventRequestFake extends Fake
    implements api.CreateHealthEventRequest {}

class _UpsertCheckInRequestFake extends Fake
    implements api.UpsertCheckInRequest {}

class _EndRequestFake extends Fake
    implements api.EndRequest {}

void main() {
  late _MockHealthEventsApi healthEventsApi;
  late LucentHealthEventRepository repository;

  setUpAll(() {
    registerFallbackValue(_CreateHealthEventRequestFake());
    registerFallbackValue(_UpsertCheckInRequestFake());
    registerFallbackValue(_EndRequestFake());
  });

  setUp(() {
    healthEventsApi = _MockHealthEventsApi();
    repository = LucentHealthEventRepository(apiClient: healthEventsApi);
  });

  group('fetchActive', () {
    test('maps generated event response into domain data', () async {
      when(
        () => healthEventsApi.active(),
      ).thenAnswer((_) async => _activeResponse(_nullableEvent(_eventJson())));

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
        () => healthEventsApi.active(),
      ).thenAnswer((_) async => _activeResponse(null));

      expect(await expectTaskRight(repository.fetchActive()), isNull);
    });

    test(
      'maps an active 404 to Right(null) — no active event is normal',
      () async {
        when(
          () => healthEventsApi.active(),
        ).thenThrow(_dioException(404));

        expect(await expectTaskRight(repository.fetchActive()), isNull);
      },
    );

    test('maps an active 404 Problem Details to Right(null)', () async {
      when(
        () => healthEventsApi.active(),
      ).thenThrow(_problemDetails(404, code: 'EVENT_NOT_FOUND'));

      expect(await expectTaskRight(repository.fetchActive()), isNull);
    });

    test('maps active network failure to Left(network)', () async {
      when(
        () => healthEventsApi.active(),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(repository.fetchActive());
      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.connectionTimeout);
    });

    test('maps a non-string field in the response to Left(unknown) keeping the '
        'cause (protocol invariant)', () async {
      final malformed = _eventJson()..['endedAt'] = 123;
      when(() => healthEventsApi.active()).thenAnswer(
        (_) async => _activeResponse(
          api.HealthEventNullableResponse.fromJson(malformed),
        ),
      );

      final failure = await expectTaskLeft(repository.fetchActive());
      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<CheckedFromJsonException>());
    });
  });

  group('fetchById', () {
    test('maps detail response into domain data', () async {
      when(
        () => healthEventsApi.getHealthEvent(id: 'event-1'),
      ).thenAnswer((_) async => _eventResponse(_responseEvent(_eventJson())));

      final detail = await expectTaskRight(repository.fetchById('event-1'));
      expect(detail?.title, 'Cold observation');
      expect(detail?.id, 'event-1');
    });

    test('maps a detail 404 to Right(null)', () async {
      when(
        () => healthEventsApi.getHealthEvent(id: 'event-1'),
      ).thenThrow(_dioException(404));

      expect(await expectTaskRight(repository.fetchById('event-1')), isNull);
    });
  });

  group('fetchHistory', () {
    test('maps history response into domain data', () async {
      when(
        () => healthEventsApi.listHealthEvents(),
      ).thenAnswer((_) async => _listResponse([_listEvent(_eventJson())]));

      final history = await expectTaskRight(repository.fetchHistory());
      expect(history.single.id, 'event-1');
    });

    test('keeps a legal empty history as Right', () async {
      when(
        () => healthEventsApi.listHealthEvents(),
      ).thenAnswer((_) async => _listResponse(const []));

      expect(await expectTaskRight(repository.fetchHistory()), isEmpty);
    });

    test(
      'maps empty history success body to Left(network, emptyResponse)',
      () async {
        when(
          () => healthEventsApi.listHealthEvents(),
        ).thenAnswer((_) async => _emptyListResponse());

        final failure = await expectTaskLeft(repository.fetchHistory());
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => healthEventsApi.listHealthEvents(),
      ).thenThrow(_problemDetails(404, code: 'EVENT_NOT_FOUND'));

      final failure = await expectTaskLeft(repository.fetchHistory());
      expect(failure.code, 'EVENT_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test('maps history network failure to Left(network)', () async {
      when(
        () => healthEventsApi.listHealthEvents(),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(repository.fetchHistory());
      expect(failure.kind, LucentFailureKind.network);
    });
  });

  group('writes', () {
    test('maps successful writes, detail, and history responses', () async {
      when(
        () => healthEventsApi.createHealthEvent(
          createHealthEventRequest: any(
            named: 'createHealthEventRequest',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_responseEvent(_eventJson())));
      when(
        () => healthEventsApi.upsertCheckIn(
          id: any(named: 'id'),
          date: any(named: 'date'),
          upsertCheckInRequest: any(
            named: 'upsertCheckInRequest',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_responseEvent(_eventJson())));
      when(
        () => healthEventsApi.end(
          id: any(named: 'id'),
          endRequest: any(
            named: 'endRequest',
          ),
        ),
      ).thenAnswer((_) async => _eventResponse(_responseEvent(_eventJson())));

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
                () => healthEventsApi.createHealthEvent(
                  createHealthEventRequest: captureAny(
                    named: 'createHealthEventRequest',
                  ),
                ),
              ).captured.single
              as api.CreateHealthEventRequest;
      expect(createCall.title, 'Cold observation');
      expect(createCall.reasonRecordId, 'record-1');
      expect(createCall.currentMedicineIds, ['medicine-1']);

      final checkInCall =
          verify(
                () => healthEventsApi.upsertCheckIn(
                  id: 'event-1',
                  date: '2026-08-09',
                  upsertCheckInRequest: captureAny(
                    named: 'upsertCheckInRequest',
                  ),
                ),
              ).captured.single
              as api.UpsertCheckInRequest;
      expect(
        checkInCall.outcome,
        api.UpsertCheckInRequestOutcomeEnum.improved,
      );

      final endCall =
          verify(
                () => healthEventsApi.end(
                  id: 'event-1',
                  endRequest: captureAny(
                    named: 'endRequest',
                  ),
                ),
              ).captured.single
              as api.EndRequest;
      expect(
        endCall.outcome,
        api.EndRequestOutcomeEnum.unchanged,
      );
    });

    test('rejects missing write response data as Left(unknown) keeping the '
        'StateError cause (protocol invariant)', () async {
      when(
        () => healthEventsApi.createHealthEvent(
          createHealthEventRequest: any(
            named: 'createHealthEventRequest',
          ),
        ),
      ).thenAnswer((_) async => _emptyEventResponse());
      when(
        () => healthEventsApi.upsertCheckIn(
          id: any(named: 'id'),
          date: any(named: 'date'),
          upsertCheckInRequest: any(
            named: 'upsertCheckInRequest',
          ),
        ),
      ).thenAnswer((_) async => _emptyEventResponse());
      when(
        () => healthEventsApi.end(
          id: any(named: 'id'),
          endRequest: any(
            named: 'endRequest',
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
        () => healthEventsApi.upsertCheckIn(
          id: any(named: 'id'),
          date: any(named: 'date'),
          upsertCheckInRequest: any(
            named: 'upsertCheckInRequest',
          ),
        ),
      ).thenAnswer(
        (_) async => _eventResponse(
          _responseEvent(_eventJson(status: 'unknown-status')),
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
        () => healthEventsApi.end(
          id: any(named: 'id'),
          endRequest: any(
            named: 'endRequest',
          ),
        ),
      ).thenAnswer(
        (_) async => _eventResponse(
          _responseEvent(_eventJson(checkInOutcome: 'unknown-outcome')),
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
          () => healthEventsApi.createHealthEvent(
            createHealthEventRequest: any(
              named: 'createHealthEventRequest',
            ),
          ),
        ).thenThrow(problem);
        when(
          () => healthEventsApi.upsertCheckIn(
            id: any(named: 'id'),
            date: any(named: 'date'),
            upsertCheckInRequest: any(
              named: 'upsertCheckInRequest',
            ),
          ),
        ).thenThrow(problem);
        when(
          () => healthEventsApi.end(
            id: any(named: 'id'),
            endRequest: any(
              named: 'endRequest',
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
        () => healthEventsApi.createHealthEvent(
          createHealthEventRequest: any(
            named: 'createHealthEventRequest',
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
          () => healthEventsApi.createHealthEvent(
            createHealthEventRequest: any(
              named: 'createHealthEventRequest',
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

Response<api.HealthEventNullableResponse> _activeResponse(
  api.HealthEventNullableResponse? data,
) {
  return Response<api.HealthEventNullableResponse>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events/active'),
    statusCode: 200,
    data: data,
  );
}

Response<api.HealthEventResponse> _eventResponse(
  api.HealthEventResponse data,
) {
  return Response<api.HealthEventResponse>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
    data: data,
  );
}

Response<api.HealthEventResponse> _emptyEventResponse() {
  return Response<api.HealthEventResponse>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
  );
}

Response<api.HealthEventListResponse> _listResponse(
  List<api.HealthEventListResponseItems> items,
) {
  return Response<api.HealthEventListResponse>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
    data: api.HealthEventListResponse(items: items, total: items.length),
  );
}

Response<api.HealthEventListResponse> _emptyListResponse() {
  return Response<api.HealthEventListResponse>(
    requestOptions: RequestOptions(path: '/api/v1/user/health-events'),
    statusCode: 200,
  );
}

api.HealthEventNullableResponse _nullableEvent(Map<String, Object?> json) {
  return api.HealthEventNullableResponse.fromJson(json);
}

api.HealthEventResponse _responseEvent(Map<String, Object?> json) {
  return api.HealthEventResponse.fromJson(json);
}

api.HealthEventListResponseItems _listEvent(Map<String, Object?> json) {
  return api.HealthEventListResponseItems.fromJson(json);
}

Map<String, Object?> _eventJson({
  String? endedAt,
  String? reasonRecordId,
  String status = 'active',
  String checkInOutcome = 'improved',
}) {
  return <String, Object?>{
    'kind': 'symptom',
    'id': 'event-1',
    'title': 'Cold observation',
    'status': status,
    'startedAt': '2026-08-08T16:00:00.000Z',
    'endedAt': endedAt,
    'outcome': 'improved',
    'reasonRecordId': reasonRecordId,
    'currentMedicineIds': <String>['medicine-1'],
    'checkIn': <String, Object?>{
      'id': 'check-in-1',
      'eventId': 'event-1',
      'date': '2026-08-09',
      'outcome': checkInOutcome,
      'createdAt': '2026-08-09T01:00:00.000Z',
      'updatedAt': '2026-08-09T01:00:00.000Z',
    },
    'coverage': <String, Object?>{
      'checkInCount': 3,
      'firstCheckInDate': '2026-08-07',
      'lastCheckInDate': '2026-08-09',
    },
  };
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
