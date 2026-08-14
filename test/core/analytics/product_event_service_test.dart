import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductEventsApi extends Mock implements ProductEventsApi {}

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

/// Allowed attribute keys — the ONLY keys a queued product event payload may
/// carry (mirrors the server-side DTO whitelist).
const _allowedKeys = <String>{
  'name',
  'surface',
  'result',
  'suggestionRuleCode',
  'appVersion',
  'platform',
  'occurredAt',
  'clientEventId',
};

ProductEventService _service({
  required _MockProductEventsApi api,
  _MockPendingSyncDao? dao,
  String version = '1.2.3',
  String eventId = 'pe-fixed-001',
  UserDevicePlatform platform = UserDevicePlatform.android,
}) {
  return ProductEventService(
    api: api,
    pendingSyncDao: dao,
    versionLoader: () async => version,
    eventIdGenerator: () => eventId,
    platformResolver: () => platform,
    clock: () => DateTime.utc(2026, 8, 14, 8, 0, 0),
  );
}

DioException _networkError() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/user/product-events'),
    type: DioExceptionType.connectionError,
  );
}

void main() {
  late _MockProductEventsApi api;
  late _MockPendingSyncDao dao;

  setUpAll(() {
    registerFallbackValue(CreateProductEventBatchDto(events: const []));
  });

  setUp(() {
    api = _MockProductEventsApi();
    dao = _MockPendingSyncDao();
    when(
      () => dao.enqueue(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        operation: any(named: 'operation'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async => 'pending-001');
    // Default: the server accepts the batch. Throwing tests override this.
    when(
      () => api.productEventsControllerRecordBatchV1(
        createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
      ),
    ).thenAnswer(
      (_) async => Response<void>(
        requestOptions: RequestOptions(path: '/api/v1/user/product-events'),
        statusCode: 200,
      ),
    );
  });

  group('suggestion impression', () {
    test('records once and dedupes per rule code within a session', () async {
      final service = _service(api: api, dao: dao);

      expect(service.trackSuggestionImpression('missed_dose_pending'), isTrue);
      expect(service.trackSuggestionImpression('missed_dose_pending'), isFalse);
      // A different rule code is a different impression key.
      expect(service.trackSuggestionImpression('water_behind_target'), isTrue);

      await Future<void>.delayed(Duration.zero);

      verify(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      ).called(2);
    });

    test('drops non-allowlisted rule codes without recording', () async {
      final service = _service(api: api, dao: dao);

      expect(service.trackSuggestionImpression('free_text_rule'), isFalse);

      await Future<void>.delayed(Duration.zero);

      verifyNever(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      );
      verifyNever(
        () => dao.enqueue(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('sends the typed DTO with allowlisted attributes only', () async {
      final service = _service(
        api: api,
        dao: dao,
        version: '2.0.1',
        eventId: 'pe-abc',
        platform: UserDevicePlatform.ios,
      );

      service.trackSuggestionImpression('sleep_shortfall');

      await Future<void>.delayed(Duration.zero);

      final captured =
          verify(
                () => api.productEventsControllerRecordBatchV1(
                  createProductEventBatchDto: captureAny(
                    named: 'createProductEventBatchDto',
                  ),
                ),
              ).captured.single
              as CreateProductEventBatchDto;

      final dto = captured.events.single;
      expect(dto.name, ProductEventName.suggestionImpression);
      expect(dto.surface, ProductEventSurface.today);
      expect(dto.result, ProductEventResult.success);
      expect(dto.suggestionRuleCode, 'sleep_shortfall');
      expect(dto.appVersion, '2.0.1');
      expect(dto.platform, UserDevicePlatform.ios);
      expect(dto.occurredAt, '2026-08-14T08:00:00.000Z');
      expect(dto.clientEventId, 'pe-abc');
      expect(dto.eventStatus, isNull);

      // The DTO serializes to exactly the allowlisted key set.
      final json = dto.toJson();
      expect(json.keys.toSet(), _allowedKeys);
      expect(json.containsKey('eventStatus'), isFalse);
    });
  });

  group('review_opened', () {
    test('records at most once per session', () async {
      final service = _service(api: api, dao: dao);

      await service.trackReviewOpened();
      await service.trackReviewOpened();

      final calls = verify(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: captureAny(
            named: 'createProductEventBatchDto',
          ),
        ),
      ).captured;
      expect(calls, hasLength(1));

      final dto = (calls.single as CreateProductEventBatchDto).events.single;
      expect(dto.name, ProductEventName.reviewOpened);
      expect(dto.surface, ProductEventSurface.review);
      expect(dto.result, ProductEventResult.success);
      expect(dto.suggestionRuleCode, isNull);
    });
  });

  group('visit summary preview / export', () {
    test(
      'preview and export are not deduped — one event per attempt',
      () async {
        final service = _service(api: api, dao: dao);

        await service.trackVisitSummaryPreviewed(ProductEventResult.success);
        await service.trackVisitSummaryPreviewed(ProductEventResult.success);
        await service.trackVisitSummaryExported(ProductEventResult.failure);
        await service.trackVisitSummaryExported(ProductEventResult.failure);

        verify(
          () => api.productEventsControllerRecordBatchV1(
            createProductEventBatchDto: any(
              named: 'createProductEventBatchDto',
            ),
          ),
        ).called(4);
      },
    );

    test('previewed carries surface more and the caller result', () async {
      final service = _service(api: api, dao: dao);

      await service.trackVisitSummaryPreviewed(ProductEventResult.failure);

      final captured =
          verify(
                () => api.productEventsControllerRecordBatchV1(
                  createProductEventBatchDto: captureAny(
                    named: 'createProductEventBatchDto',
                  ),
                ),
              ).captured.single
              as CreateProductEventBatchDto;
      final dto = captured.events.single;
      expect(dto.name, ProductEventName.visitSummaryPreviewed);
      expect(dto.surface, ProductEventSurface.more);
      expect(dto.result, ProductEventResult.failure);
    });

    test('exported carries surface more and the caller result', () async {
      final service = _service(api: api, dao: dao);

      await service.trackVisitSummaryExported(ProductEventResult.success);

      final captured =
          verify(
                () => api.productEventsControllerRecordBatchV1(
                  createProductEventBatchDto: captureAny(
                    named: 'createProductEventBatchDto',
                  ),
                ),
              ).captured.single
              as CreateProductEventBatchDto;
      final dto = captured.events.single;
      expect(dto.name, ProductEventName.visitSummaryExported);
      expect(dto.surface, ProductEventSurface.more);
      expect(dto.result, ProductEventResult.success);
    });
  });

  group('offline queue', () {
    test('enqueues into the pending-sync queue on DioException', () async {
      final service = _service(api: api, dao: dao);
      when(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      ).thenThrow(_networkError());

      service.trackSuggestionImpression('missed_dose_pending');

      await Future<void>.delayed(Duration.zero);

      verify(
        () => dao.enqueue(
          entityType: 'product_event',
          entityId: any(named: 'entityId'),
          operation: 'create',
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });

    test(
      'queued payload contains ONLY the allowlisted attribute keys',
      () async {
        final service = _service(api: api, dao: dao, eventId: 'pe-queue-001');
        when(
          () => api.productEventsControllerRecordBatchV1(
            createProductEventBatchDto: any(
              named: 'createProductEventBatchDto',
            ),
          ),
        ).thenThrow(_networkError());

        service.trackSuggestionImpression('caffeine_sleep_correlation');

        await Future<void>.delayed(Duration.zero);

        final captured =
            verify(
                  () => dao.enqueue(
                    entityType: 'product_event',
                    entityId: any(named: 'entityId'),
                    operation: 'create',
                    payload: captureAny(named: 'payload'),
                  ),
                ).captured.single
                as String;

        final payload = jsonDecode(captured) as Map<String, dynamic>;
        // Exact key set — no free text, no record values, no metadata.
        expect(payload.keys.toSet(), _allowedKeys);
        expect(payload['name'], 'suggestion_impression');
        expect(payload['surface'], 'today');
        expect(payload['result'], 'success');
        expect(payload['suggestionRuleCode'], 'caffeine_sleep_correlation');
        expect(payload['appVersion'], '1.2.3');
        expect(payload['platform'], 'android');
        expect(payload['occurredAt'], '2026-08-14T08:00:00.000Z');
        expect(payload['clientEventId'], 'pe-queue-001');
        for (final forbidden in const [
          'eventStatus',
          'metadata',
          'title',
          'note',
          'symptom',
          'medicineName',
          'pdfUrl',
          'shareToken',
          'deviceAdId',
        ]) {
          expect(
            payload.containsKey(forbidden),
            isFalse,
            reason: 'payload must not contain $forbidden',
          );
        }
      },
    );

    test('retry reuses the same clientEventId (idempotent replay)', () async {
      final service = _service(api: api, dao: dao, eventId: 'pe-retry-42');
      when(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      ).thenThrow(_networkError());

      await service.trackVisitSummaryExported(ProductEventResult.success);

      final captured =
          verify(
                () => dao.enqueue(
                  entityType: 'product_event',
                  entityId: any(named: 'entityId'),
                  operation: 'create',
                  payload: captureAny(named: 'payload'),
                ),
              ).captured.single
              as String;

      // The sync worker replays the same payload: decoding round-trips the
      // DTO and preserves the clientEventId — the server unique constraint
      // then makes retries idempotent.
      final decoded = jsonDecode(captured) as Map<String, dynamic>;
      expect(decoded['clientEventId'], 'pe-retry-42');

      final replayed = CreateProductEventDto.fromJson(decoded).toJson();
      expect(replayed, decoded);
      expect(replayed['clientEventId'], 'pe-retry-42');
    });

    test('enqueued event keeps the typed event fields on replay', () async {
      final service = _service(api: api, dao: dao);
      when(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      ).thenThrow(_networkError());

      await service.trackReviewOpened();

      final captured =
          verify(
                () => dao.enqueue(
                  entityType: 'product_event',
                  entityId: any(named: 'entityId'),
                  operation: 'create',
                  payload: captureAny(named: 'payload'),
                ),
              ).captured.single
              as String;

      final payload = jsonDecode(captured) as Map<String, dynamic>;
      // No suggestionRuleCode for review_opened — the exact key set is the
      // allowlisted base attributes minus the suggestion-only field.
      expect(
        payload.keys.toSet(),
        _allowedKeys.difference({'suggestionRuleCode'}),
      );
      expect(payload['name'], 'review_opened');
      expect(payload['surface'], 'review');
      expect(payload['suggestionRuleCode'], isNull);
    });

    test('non-Dio failures are swallowed and never enqueued', () async {
      final service = _service(api: api, dao: dao);
      when(
        () => api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: any(named: 'createProductEventBatchDto'),
        ),
      ).thenThrow(StateError('unexpected'));

      // Must not throw and must not enqueue.
      await service.trackVisitSummaryPreviewed(ProductEventResult.success);

      verifyNever(
        () => dao.enqueue(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          operation: any(named: 'operation'),
          payload: any(named: 'payload'),
        ),
      );
    });
  });
}
