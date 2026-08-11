import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:luminous/features/health_data/data/repositories/health_sync.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks/health_data.dart';

class _MockDailyRecordRepository extends Mock
    implements DailyRecordRepository {}

DailyRecordItem _record({
  required String id,
  DailyRecordKind kind = DailyRecordKind.vital,
  String occurredAt = '2026-07-12',
  String? source = 'manual',
  String occurredTime = '08:30',
  String value = '72',
  String unit = 'bpm',
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    source: source,
    value: value,
    unit: unit,
    createdAt: '2026-07-12T00:00:00',
    updatedAt: '2026-07-12T00:00:00',
  );
}

DailyRecordItem _recordWithPayload({
  required String id,
  required DailyRecordKind kind,
  required String source,
  required String value,
  required String unit,
  required Map<String, dynamic> payload,
  String occurredAt = '2026-07-12',
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: occurredAt,
    occurredTime: '08:30',
    source: source,
    value: value,
    unit: unit,
    payload: payload,
    createdAt: '2026-07-12T00:00:00',
    updatedAt: '2026-07-12T00:00:00',
  );
}

HealthMetric _metric({
  HealthMetricType type = HealthMetricType.heartRate,
  double value = 72,
  DateTime? recordedAt,
  String? externalId,
  String unit = 'bpm',
  DateTime? startAt,
  DateTime? endAt,
}) {
  return HealthMetric(
    type: type,
    value: value,
    unit: unit,
    recordedAt: recordedAt ?? DateTime(2026, 7, 12, 8, 30),
    externalId: externalId,
    startAt: startAt,
    endAt: endAt,
  );
}

void main() {
  late FakeHealthPlatformDataSource dataSource;
  late _MockDailyRecordRepository dailyRecordRepo;
  late HealthSyncRepositoryImpl repository;

  setUp(() {
    dataSource = FakeHealthPlatformDataSource();
    dailyRecordRepo = _MockDailyRecordRepository();
    repository = HealthSyncRepositoryImpl(
      dataSource: dataSource,
      mapper: const HealthRecordMapper(),
      dailyRecordRepo: dailyRecordRepo,
    );
    registerFallbackValue(
      const DailyRecordCreateInput(
        kind: DailyRecordKind.vital,
        occurredAt: '2026-07-12',
      ),
    );
  });

  group('platform availability', () {
    test('delegates to the data source', () {
      expect(repository.isPlatformAvailable, isTrue);

      dataSource.available = false;
      expect(repository.isPlatformAvailable, isFalse);
    });

    test('returns empty authorized types when platform unavailable', () async {
      dataSource.available = false;
      expect(await repository.getAuthorizedTypes(), isEmpty);
    });

    test('returns data source authorized types when available', () async {
      dataSource.authorizedResult = {
        HealthMetricType.steps,
        HealthMetricType.sleep,
      };
      final result = await repository.getAuthorizedTypes();
      expect(result, {HealthMetricType.steps, HealthMetricType.sleep});
    });
  });

  group('requestPermissions', () {
    test('delegates to the data source', () async {
      final status = await repository.requestPermissions({
        HealthMetricType.heartRate,
      });
      expect(status, HealthPermissionStatus.granted);

      dataSource.permissionResult = HealthPermissionStatus.denied;
      expect(
        await repository.requestPermissions({HealthMetricType.heartRate}),
        HealthPermissionStatus.denied,
      );
    });
  });

  group('fetchMetrics', () {
    test('maps data points to metrics', () async {
      dataSource.points = [
        HealthDataPoint(
          uuid: 'u1',
          value: NumericHealthValue(numericValue: 88),
          type: HealthDataType.HEART_RATE,
          unit: HealthDataUnit.COUNT,
          dateFrom: DateTime(2026, 7, 12, 8, 0),
          dateTo: DateTime(2026, 7, 12, 8, 0),
          sourcePlatform: HealthPlatformType.appleHealth,
          sourceDeviceId: 'd',
          sourceId: 's',
          sourceName: 'sn',
        ),
      ];

      final metrics = await repository.fetchMetrics(
        types: {HealthMetricType.heartRate},
        start: DateTime(2026, 7, 12),
        end: DateTime(2026, 7, 13),
      );

      expect(metrics, hasLength(1));
      expect(metrics.single.type, HealthMetricType.heartRate);
      expect(metrics.single.value, 88);
      expect(dataSource.lastFetchTypes, {HealthMetricType.heartRate});
      expect(dataSource.lastFetchStart, DateTime(2026, 7, 12));
      expect(dataSource.lastFetchEnd, DateTime(2026, 7, 13));
    });
  });

  group('syncToRecords', () {
    test('returns zero result for empty metrics', () async {
      final result = await repository.syncToRecords([]);

      expect(result.successCount, 0);
      expect(result.skippedCount, 0);
      expect(result.failedCount, 0);
      verifyNever(() => dailyRecordRepo.fetchRecords('2026-07-12', page: 1));
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('creates new records and reports success', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(
        () => dailyRecordRepo.create(any()),
      ).thenAnswer((_) async => _record(id: 'r1'));

      final result = await repository.syncToRecords([_metric()]);

      expect(result.successCount, 1);
      expect(result.skippedCount, 0);
      expect(result.failedCount, 0);
      expect(result.errors, isEmpty);

      final captured = verify(
        () => dailyRecordRepo.create(captureAny()),
      ).captured.cast<DailyRecordCreateInput>().single;
      expect(captured.kind, DailyRecordKind.vital);
      expect(captured.occurredAt, '2026-07-12');
      expect(captured.source, 'health_connect');
    });

    test('skips records whose fingerprint already exists', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _record(
              id: 'existing',
              kind: DailyRecordKind.vital,
              source: 'health_connect',
            ),
          ],
          total: 1,
        ),
      );

      final result = await repository.syncToRecords([
        _metric(recordedAt: DateTime(2026, 7, 12, 8, 30)),
      ]);

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('normalizes integer-valued string fingerprints', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _record(
              id: 'existing-decimal',
              kind: DailyRecordKind.vital,
              source: 'health_connect',
              value: '72.0',
            ),
          ],
          total: 1,
        ),
      );

      final result = await repository.syncToRecords([
        _metric(recordedAt: DateTime(2026, 7, 12, 8, 30)),
      ]);

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('continues after a failed create and collects errors', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(() => dailyRecordRepo.create(any())).thenThrow(Exception('boom'));

      final result = await repository.syncToRecords([_metric()]);

      expect(result.successCount, 0);
      expect(result.failedCount, 1);
      expect(result.errors, hasLength(1));
      expect(result.errors.single, contains('boom'));
    });

    test('deduplicates identical metrics within the same batch', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(
        () => dailyRecordRepo.create(any()),
      ).thenAnswer((_) async => _record(id: 'r1'));

      final result = await repository.syncToRecords([
        _metric(recordedAt: DateTime(2026, 7, 12, 8, 30)),
        _metric(recordedAt: DateTime(2026, 7, 12, 8, 30)),
        _metric(value: 90, recordedAt: DateTime(2026, 7, 12, 8, 30)),
      ]);

      expect(result.successCount, 2);
      expect(result.skippedCount, 1);
    });

    test('keeps same-day water records with different values', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(() => dailyRecordRepo.create(any())).thenAnswer(
        (_) async => _record(id: 'water-created', kind: DailyRecordKind.water),
      );

      final result = await repository.syncToRecords([
        _metric(
          type: HealthMetricType.water,
          value: 250,
          unit: 'ml',
          recordedAt: DateTime(2026, 7, 12, 8),
        ),
        _metric(
          type: HealthMetricType.water,
          value: 500,
          unit: 'ml',
          recordedAt: DateTime(2026, 7, 12, 9),
        ),
      ]);

      expect(result.successCount, 2);
      expect(result.skippedCount, 0);
      verify(() => dailyRecordRepo.create(any())).called(2);
    });

    test('keeps two same-day sleep episodes', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-13', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(() => dailyRecordRepo.create(any())).thenAnswer(
        (_) async => _record(id: 'sleep-created', kind: DailyRecordKind.sleep),
      );

      final result = await repository.syncToRecords([
        _metric(
          type: HealthMetricType.sleep,
          value: 480,
          unit: 'min',
          startAt: DateTime(2026, 7, 12, 22),
          endAt: DateTime(2026, 7, 13, 6),
          recordedAt: DateTime(2026, 7, 13, 6),
        ),
        _metric(
          type: HealthMetricType.sleep,
          value: 60,
          unit: 'min',
          startAt: DateTime(2026, 7, 13, 13),
          endAt: DateTime(2026, 7, 13, 14),
          recordedAt: DateTime(2026, 7, 13, 14),
        ),
      ]);

      expect(result.successCount, 2);
      expect(result.skippedCount, 0);
      verify(() => dailyRecordRepo.create(any())).called(2);
    });

    test('deduplicates a retry by external id', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _recordWithPayload(
              id: 'existing-water',
              kind: DailyRecordKind.water,
              source: 'health_connect',
              value: '250',
              unit: 'ml',
              payload: {'externalId': 'water-ext-1'},
            ),
          ],
          total: 1,
        ),
      );

      final result = await repository.syncToRecords([
        _metric(
          type: HealthMetricType.water,
          value: 250,
          unit: 'ml',
          externalId: 'water-ext-1',
        ),
      ]);

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('deduplicates a cross-midnight sleep retry', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-13', page: 1, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _recordWithPayload(
              id: 'existing-sleep',
              kind: DailyRecordKind.sleep,
              source: 'health_connect',
              value: '480',
              unit: 'min',
              occurredAt: '2026-07-13',
              payload: {
                'externalId': 'sleep-ext-1',
                'startedAt': '2026-07-12T22:00:00.000Z',
                'endedAt': '2026-07-13T06:00:00.000Z',
                'durationMinutes': 480,
              },
            ),
          ],
          total: 1,
        ),
      );

      final result = await repository.syncToRecords([
        _metric(
          type: HealthMetricType.sleep,
          value: 480,
          unit: 'min',
          externalId: 'sleep-ext-1',
          recordedAt: DateTime(2026, 7, 13, 6),
          startAt: DateTime(2026, 7, 12, 22),
          endAt: DateTime(2026, 7, 13, 6),
        ),
      ]);

      expect(result.successCount, 0);
      expect(result.skippedCount, 1);
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('uses value and unit for no-id fingerprints', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer((_) async => const DailyRecordListData(items: [], total: 0));
      when(() => dailyRecordRepo.create(any())).thenAnswer(
        (_) async => _record(id: 'water-created', kind: DailyRecordKind.water),
      );

      final result = await repository.syncToRecords([
        _metric(
          type: HealthMetricType.water,
          value: 250,
          unit: 'ml',
          recordedAt: DateTime(2026, 7, 12, 8),
        ),
        _metric(
          type: HealthMetricType.water,
          value: 500,
          unit: 'ml',
          recordedAt: DateTime(2026, 7, 12, 8),
        ),
      ]);

      expect(result.successCount, 2);
      expect(result.skippedCount, 0);
    });

    test('rethrows when fetching existing records fails', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenThrow(Exception('fetch failed'));

      await expectLater(
        repository.syncToRecords([_metric()]),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => dailyRecordRepo.create(any()));
    });

    test('paginates through existing records', () async {
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 1, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _record(
              id: 'a',
              kind: DailyRecordKind.vital,
              source: 'health_connect',
            ),
          ],
          total: 1500,
        ),
      );
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 2, pageSize: 500),
      ).thenAnswer(
        (_) async => DailyRecordListData(
          items: [
            _record(
              id: 'b',
              kind: DailyRecordKind.vital,
              source: 'health_connect',
            ),
          ],
          total: 1500,
        ),
      );
      when(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 3, pageSize: 500),
      ).thenAnswer(
        (_) async => const DailyRecordListData(items: [], total: 1500),
      );

      final result = await repository.syncToRecords([_metric()]);

      // Fingerprints from pages 1 and 2 match the metric → skipped
      expect(result.skippedCount, 1);
      expect(result.successCount, 0);
      verify(
        () =>
            dailyRecordRepo.fetchRecords('2026-07-12', page: 3, pageSize: 500),
      ).called(1);
    });
  });
}
