import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/daos/daily_record_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/database.dart';

/// Creates an in-memory [AppDatabase] for testing.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  group('DailyRecordDao', () {
    late AppDatabase db;
    late DailyRecordDao dao;

    setUp(() {
      db = createTestDatabase();
      dao = db.dailyRecordDao;
    });

    tearDown(() => db.close());

    test('fetchByDate returns empty when cache is empty', () async {
      final result = await dao.fetchByDate('2026-07-10');
      expect(result, isEmpty);
    });

    test('replaceByDate inserts and fetchByDate returns items', () async {
      const date = '2026-07-10';
      const jsonItem =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.replaceByDate(date, jsonItems: [jsonItem]);

      final result = await dao.fetchByDate(date);
      expect(result, hasLength(1));
      expect(result.first, contains('"id":"rec1"'));
    });

    test('replaceByDate with kind filter only replaces matching rows', () async {
      const date = '2026-07-10';
      const waterItem =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';
      const sleepItem =
          '{"id":"rec2","kind":"sleep","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"8","unit":"h","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      // Insert both items
      await dao.replaceByDate(date, jsonItems: [waterItem, sleepItem]);
      expect(await dao.fetchByDate(date), hasLength(2));

      // Replace only water items
      const newWaterItem =
          '{"id":"rec3","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"750","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';
      await dao.replaceByDate(date, kind: 'water', jsonItems: [newWaterItem]);

      // Sleep item should still be there
      final all = await dao.fetchByDate(date);
      expect(all, hasLength(2));

      // Water items should only have the new one
      final waterOnly = await dao.fetchByDate(date, kind: 'water');
      expect(waterOnly, hasLength(1));
      expect(waterOnly.first, contains('"id":"rec3"'));
    });

    test(
      'replaceByDate clears existing items for the date when empty list',
      () async {
        const date = '2026-07-10';
        const jsonItem =
            '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

        await dao.replaceByDate(date, jsonItems: [jsonItem]);
        expect(await dao.fetchByDate(date), hasLength(1));

        await dao.replaceByDate(date, jsonItems: []);
        expect(await dao.fetchByDate(date), isEmpty);
      },
    );

    test('insertOptimistic inserts with pending syncStatus', () async {
      const date = '2026-07-10';
      const jsonItem =
          '{"id":"local_123","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":"local","payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      final id = await dao.insertOptimistic(date, jsonItem);
      expect(id, 'local_123');

      final result = await dao.fetchByDate(date);
      expect(result, hasLength(1));
    });

    test('confirmSync replaces optimistic copy with server response', () async {
      const date = '2026-07-10';
      const localJson =
          '{"id":"local_123","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":"local","payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';
      const serverJson =
          '{"id":"server_456","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":"api","payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:01.000Z","updatedAt":"2026-07-10T00:00:01.000Z"}';

      await dao.insertOptimistic(date, localJson);
      await dao.confirmSync('local_123', serverJson);

      final result = await dao.fetchByDate(date);
      expect(result, hasLength(1));
      expect(result.first, contains('"id":"server_456"'));
    });

    test('deleteById removes cached record', () async {
      const date = '2026-07-10';
      const jsonItem =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.replaceByDate(date, jsonItems: [jsonItem]);
      expect(await dao.fetchByDate(date), hasLength(1));

      await dao.deleteById('rec1');
      expect(await dao.fetchByDate(date), isEmpty);
    });

    test('cleanup removes old synced rows but preserves pending', () async {
      const date = '2026-07-10';
      const syncedJson =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';
      const pendingJson =
          '{"id":"local_123","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":"local","payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.replaceByDate(date, jsonItems: [syncedJson]);
      await dao.insertOptimistic(date, pendingJson);

      // Cleanup rows older than a future timestamp (all rows)
      final deleted = await dao.cleanup(
        DateTime.now().add(const Duration(hours: 1)),
      );
      expect(deleted, 1); // Only the synced row should be deleted

      // The pending row should still exist
      final remaining = await dao.fetchByDate(date);
      expect(remaining, hasLength(1));
      expect(remaining.first, contains('"id":"local_123"'));
    });

    test('watchByDate emits updates reactively', () async {
      const date = '2026-07-10';
      const jsonItem =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      final stream = dao.watchByDate(date);
      final firstEmission = await stream.first;
      expect(firstEmission, isEmpty);

      await dao.replaceByDate(date, jsonItems: [jsonItem]);

      final secondEmission = await stream.first;
      expect(secondEmission, hasLength(1));
    });
  });

  group('PendingSyncDao', () {
    late AppDatabase db;
    late PendingSyncDao dao;

    setUp(() {
      db = createTestDatabase();
      dao = db.pendingSyncDao;
    });

    tearDown(() => db.close());

    test('enqueue and fetchReady returns item', () async {
      await dao.enqueue(
        entityType: 'daily_record',
        entityId: 'rec1',
        operation: 'create',
        payload: '{"test":true}',
      );

      final ready = await dao.fetchReady();
      expect(ready, hasLength(1));
      expect(ready.first.entityType, 'daily_record');
      expect(ready.first.operation, 'create');
      expect(ready.first.payload, '{"test":true}');
    });

    test('remove deletes synced item', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      expect(await dao.pendingCount(), 1);

      await dao.remove(id);
      expect(await dao.pendingCount(), 0);
    });

    test('markSyncing prevents item from being fetched as ready', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      await dao.markSyncing(id);

      final ready = await dao.fetchReady();
      expect(ready, isEmpty);
    });

    test('markFailed increments retryCount and records error', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      await dao.markSyncing(id);
      await dao.markFailed(id, raw: 'network error');

      final ready = await dao.fetchReady();
      // Item should not be ready immediately (backoff not elapsed)
      expect(ready, isEmpty);
    });

    test('fetchReady respects maxRetry', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      // Exhaust all retries
      for (var i = 0; i < 5; i++) {
        await dao.markSyncing(id);
        await dao.markFailed(id, raw: 'error $i');
      }

      final ready = await dao.fetchReady();
      expect(ready, isEmpty); // Exceeded maxRetry (default 5)
    });

    test('fetchPermanentlyFailed returns diagnostic details', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        entityId: 'rec1',
        operation: 'update',
        payload: '{"id":"rec1"}',
      );

      for (var i = 0; i < 5; i++) {
        await dao.markSyncing(id);
        await dao.markFailed(id, raw: 'network error $i');
      }

      final failed = await dao.fetchPermanentlyFailed();

      expect(failed, hasLength(1));
      expect(failed.first.id, id);
      expect(failed.first.entityType, 'daily_record');
      expect(failed.first.entityId, 'rec1');
      expect(failed.first.operation, 'update');
      expect(failed.first.retryCount, 5);
      expect(failed.first.maxRetry, 5);
      expect(failed.first.lastError, 'network error 4');
    });

    test('resetForRetry makes a permanently failed item ready again', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      for (var i = 0; i < 5; i++) {
        await dao.markSyncing(id);
        await dao.markFailed(id, raw: 'network error');
      }

      await dao.resetForRetry(id);

      final ready = await dao.fetchReady();
      expect(ready, hasLength(1));
      expect(ready.first.id, id);
      expect(ready.first.retryCount, 0);
      expect(ready.first.lastError, isNull);
    });

    test('fetchReady orders by createdAt ascending', () async {
      await dao.enqueue(
        entityType: 'daily_record',
        entityId: 'first',
        operation: 'create',
        payload: '{}',
      );

      // Small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));

      await dao.enqueue(
        entityType: 'daily_record',
        entityId: 'second',
        operation: 'create',
        payload: '{}',
      );

      final ready = await dao.fetchReady();
      expect(ready, hasLength(2));
      expect(ready.first.entityId, 'first');
      expect(ready.last.entityId, 'second');
    });
  });

  group('HealthContextDao', () {
    late AppDatabase db;

    setUp(() {
      db = createTestDatabase();
    });

    tearDown(() => db.close());

    test('fetch returns null when empty', () async {
      final result = await db.healthContextDao.fetch();
      expect(result, isNull);
    });

    test('replace and fetch round-trips', () async {
      const json =
          '{"summary":{},"profile":{},"allergies":[],"conditions":[],"currentMedicines":[]}';

      await db.healthContextDao.replace(json);
      final result = await db.healthContextDao.fetch();
      expect(result, json);
    });

    test('clear removes cached snapshot', () async {
      const json = '{"test":true}';

      await db.healthContextDao.replace(json);
      expect(await db.healthContextDao.fetch(), isNotNull);

      await db.healthContextDao.clear();
      expect(await db.healthContextDao.fetch(), isNull);
    });
  });

  group('TodaySuggestionDao', () {
    late AppDatabase db;

    setUp(() {
      db = createTestDatabase();
    });

    tearDown(() => db.close());

    test('fetch returns null when empty', () async {
      final result = await db.todaySuggestionDao.fetch();
      expect(result, isNull);
    });

    test('replace and fetch round-trips', () async {
      const json =
          '{"generatedAt":"2026-07-10T00:00:00Z","primary":null,"secondary":[],"observations":[]}';

      await db.todaySuggestionDao.replace(json);
      final result = await db.todaySuggestionDao.fetch();
      expect(result, json);
    });
  });

  group('CurrentMedicineDao', () {
    late AppDatabase db;

    setUp(() {
      db = createTestDatabase();
    });

    tearDown(() => db.close());

    test('fetch returns null when empty', () async {
      final result = await db.currentMedicineDao.fetch();
      expect(result, isNull);
    });

    test('replace and fetch round-trips', () async {
      const json = '[{"id":"med1","name":"Aspirin"}]';

      await db.currentMedicineDao.replace(json);
      final result = await db.currentMedicineDao.fetch();
      expect(result, json);
    });
  });
}
