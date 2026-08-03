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
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: occurredAt,
    source: source,
    createdAt: '2026-07-12T00:00:00',
    updatedAt: '2026-07-12T00:00:00',
  );
}

HealthMetric _metric({
  HealthMetricType type = HealthMetricType.heartRate,
  double value = 72,
  DateTime? recordedAt,
}) {
  return HealthMetric(
    type: type,
    value: value,
    unit: 'bpm',
    recordedAt: recordedAt ?? DateTime(2026, 7, 12, 8, 30),
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

      expect(result.successCount, 1);
      expect(result.skippedCount, 2);
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
