import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as api;
import 'package:luminous/features/health_event/data/repositories/lucent.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:mocktail/mocktail.dart';

class _MockHealthEventsApi extends Mock implements api.HealthEventsApi {}

class _CreateHealthEventDtoFake extends Fake
    implements api.CreateHealthEventDto {}

class _UpsertHealthEventCheckInDtoFake extends Fake
    implements api.UpsertHealthEventCheckInDto {}

class _EndHealthEventDtoFake extends Fake implements api.EndHealthEventDto {}

void main() {
  late _MockHealthEventsApi healthEventsApi;
  late LucentHealthEventRepository repository;

  setUpAll(() {
    registerFallbackValue(_CreateHealthEventDtoFake());
    registerFallbackValue(_UpsertHealthEventCheckInDtoFake());
    registerFallbackValue(_EndHealthEventDtoFake());
  });

  setUp(() {
    healthEventsApi = _MockHealthEventsApi();
    repository = LucentHealthEventRepository(apiClient: healthEventsApi);
  });

  test('maps generated event response into domain data', () async {
    when(
      () => healthEventsApi.healthEventsControllerActiveV1(),
    ).thenAnswer((_) async => _activeResponse(_eventDto()));

    final event = await repository.fetchActive();

    expect(event, isNotNull);
    expect(event!.id, 'event-1');
    expect(event.status, HealthEventStatus.active);
    expect(event.outcome, HealthEventOutcome.improved);
    expect(event.checkIn?.date, '2026-08-09');
    expect(event.coverage.checkInCount, 3);
  });

  test('maps an empty active response to null', () async {
    when(
      () => healthEventsApi.healthEventsControllerActiveV1(),
    ).thenAnswer((_) async => _activeResponse(null));

    expect(await repository.fetchActive(), isNull);
  });

  test('maps an active 404 to null', () async {
    when(
      () => healthEventsApi.healthEventsControllerActiveV1(),
    ).thenThrow(_dioException(404));

    expect(await repository.fetchActive(), isNull);
  });

  test('maps successful writes, detail, and history responses', () async {
    when(
      () => healthEventsApi.healthEventsControllerCreateV1(
        createHealthEventDto: any(named: 'createHealthEventDto'),
      ),
    ).thenAnswer((_) async => _eventResponse(_eventDto()));
    when(
      () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
        id: any(named: 'id'),
        date: any(named: 'date'),
        upsertHealthEventCheckInDto: any(named: 'upsertHealthEventCheckInDto'),
      ),
    ).thenAnswer((_) async => _eventResponse(_eventDto()));
    when(
      () => healthEventsApi.healthEventsControllerEndV1(
        id: any(named: 'id'),
        endHealthEventDto: any(named: 'endHealthEventDto'),
      ),
    ).thenAnswer((_) async => _eventResponse(_eventDto()));
    when(
      () => healthEventsApi.healthEventsControllerGetV1(id: 'event-1'),
    ).thenAnswer((_) async => _eventResponse(_eventDto()));
    when(
      () => healthEventsApi.healthEventsControllerListV1(),
    ).thenAnswer((_) async => _listResponse([_eventDto()]));

    final created = await repository.create(
      title: 'Cold observation',
      reasonRecordId: 'record-1',
      currentMedicineIds: const ['medicine-1'],
    );
    final checkedIn = await repository.checkIn(
      eventId: 'event-1',
      date: '2026-08-09',
      outcome: HealthEventOutcome.improved,
    );
    final ended = await repository.end(
      eventId: 'event-1',
      outcome: HealthEventOutcome.unchanged,
    );
    final detail = await repository.fetchById('event-1');
    final history = await repository.fetchHistory();

    expect(created.id, 'event-1');
    expect(checkedIn.checkIn?.outcome, HealthEventOutcome.improved);
    expect(ended.coverage.checkInCount, 3);
    expect(detail?.title, 'Cold observation');
    expect(history.single.id, 'event-1');

    final createCall =
        verify(
              () => healthEventsApi.healthEventsControllerCreateV1(
                createHealthEventDto: captureAny(named: 'createHealthEventDto'),
              ),
            ).captured.single
            as api.CreateHealthEventDto;
    expect(createCall.title, 'Cold observation');
    expect(createCall.reasonRecordId, 'record-1');
    expect(createCall.currentMedicineIds, ['medicine-1']);
    verify(
      () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
        id: 'event-1',
        date: '2026-08-09',
        upsertHealthEventCheckInDto: captureAny(
          named: 'upsertHealthEventCheckInDto',
        ),
      ),
    ).called(1);
    verify(
      () => healthEventsApi.healthEventsControllerEndV1(
        id: 'event-1',
        endHealthEventDto: captureAny(named: 'endHealthEventDto'),
      ),
    ).called(1);
  });

  test('rejects missing write response data', () async {
    when(
      () => healthEventsApi.healthEventsControllerCreateV1(
        createHealthEventDto: any(named: 'createHealthEventDto'),
      ),
    ).thenAnswer((_) async => _emptyEventResponse());
    when(
      () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
        id: any(named: 'id'),
        date: any(named: 'date'),
        upsertHealthEventCheckInDto: any(named: 'upsertHealthEventCheckInDto'),
      ),
    ).thenAnswer((_) async => _emptyEventResponse());
    when(
      () => healthEventsApi.healthEventsControllerEndV1(
        id: any(named: 'id'),
        endHealthEventDto: any(named: 'endHealthEventDto'),
      ),
    ).thenAnswer((_) async => _emptyEventResponse());

    await expectLater(
      repository.create(title: 'Cold observation'),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.checkIn(
        eventId: 'event-1',
        date: '2026-08-09',
        outcome: HealthEventOutcome.improved,
      ),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.end(eventId: 'event-1', outcome: HealthEventOutcome.unchanged),
      throwsA(isA<StateError>()),
    );
  });

  test('propagates create, check-in, and end failures', () async {
    final error = StateError('request failed');
    when(
      () => healthEventsApi.healthEventsControllerCreateV1(
        createHealthEventDto: any(named: 'createHealthEventDto'),
      ),
    ).thenThrow(error);
    when(
      () => healthEventsApi.healthEventsControllerUpsertCheckInV1(
        id: any(named: 'id'),
        date: any(named: 'date'),
        upsertHealthEventCheckInDto: any(named: 'upsertHealthEventCheckInDto'),
      ),
    ).thenThrow(error);
    when(
      () => healthEventsApi.healthEventsControllerEndV1(
        id: any(named: 'id'),
        endHealthEventDto: any(named: 'endHealthEventDto'),
      ),
    ).thenThrow(error);

    await expectLater(
      repository.create(title: 'Cold observation'),
      throwsA(same(error)),
    );
    await expectLater(
      repository.checkIn(
        eventId: 'event-1',
        date: '2026-08-09',
        outcome: HealthEventOutcome.improved,
      ),
      throwsA(same(error)),
    );
    await expectLater(
      repository.end(eventId: 'event-1', outcome: HealthEventOutcome.unchanged),
      throwsA(same(error)),
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

api.HealthEventItemDto _eventDto({String? endedAt, String? reasonRecordId}) {
  return api.HealthEventItemDto(
    kind: api.HealthEventKind.symptom,
    id: 'event-1',
    title: 'Cold observation',
    status: api.HealthEventStatus.active,
    startedAt: '2026-08-08T16:00:00.000Z',
    endedAt: endedAt,
    outcome: api.HealthEventOutcome.improved,
    reasonRecordId: reasonRecordId,
    currentMedicineIds: const ['medicine-1'],
    checkIn: api.HealthEventCheckInResponseDto(
      id: 'check-in-1',
      eventId: 'event-1',
      date: '2026-08-09',
      outcome: api.HealthEventOutcome.improved,
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
