import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/daos/daily_record_dao.dart';
import 'package:luminous/core/database/daos/medicine_dose_log_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/database.dart';

/// Creates an in-memory [AppDatabase] for testing.
AppDatabase _createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

const _dailyRecordJson =
    '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"500","unit":"ml","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

const _doseLogJson =
    '{"id":"log1","currentMedicineId":"med1","reminderId":"rem1","status":"taken","scheduledFor":"2026-07-10","scheduledTime":"08:00","doseText":"1片","note":null,"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

void main() {
  // ─── MedicineDoseLogDao ──────────────────────────────────────────────
  group('MedicineDoseLogDao', () {
    late AppDatabase db;
    late MedicineDoseLogDao dao;

    setUp(() {
      db = _createTestDatabase();
      dao = db.medicineDoseLogDao;
    });

    tearDown(() => db.close());

    test('fetchByDate returns empty when cache is empty', () async {
      expect(await dao.fetchByDate('2026-07-10'), isEmpty);
    });

    test('replaceByDate inserts items and fetchByDate returns them', () async {
      await dao.replaceByDate('2026-07-10', [_doseLogJson]);
      final result = await dao.fetchByDate('2026-07-10');
      expect(result, hasLength(1));
      expect(result.first, contains('"id":"log1"'));
    });

    test('replaceByDate with empty list clears existing rows', () async {
      await dao.replaceByDate('2026-07-10', [_doseLogJson]);
      expect(await dao.fetchByDate('2026-07-10'), hasLength(1));

      await dao.replaceByDate('2026-07-10', []);
      expect(await dao.fetchByDate('2026-07-10'), isEmpty);
    });

    test('replaceByDate replaces existing items for same date', () async {
      const newJson =
          '{"id":"log2","currentMedicineId":"med2","reminderId":null,"status":"skipped","scheduledFor":"2026-07-10","scheduledTime":null,"doseText":null,"note":null,"createdAt":"2026-07-10T01:00:00.000Z","updatedAt":"2026-07-10T01:00:00.000Z"}';

      await dao.replaceByDate('2026-07-10', [_doseLogJson]);
      await dao.replaceByDate('2026-07-10', [newJson]);

      final result = await dao.fetchByDate('2026-07-10');
      expect(result, hasLength(1));
      expect(result.first, contains('"id":"log2"'));
    });

    test('replaceByDate only affects the specified date', () async {
      const otherDateJson =
          '{"id":"log0","currentMedicineId":"med0","reminderId":null,"status":"taken","scheduledFor":"2026-07-09","scheduledTime":null,"doseText":null,"note":null,"createdAt":"2026-07-09T00:00:00.000Z","updatedAt":"2026-07-09T00:00:00.000Z"}';

      await dao.replaceByDate('2026-07-09', [otherDateJson]);
      await dao.replaceByDate('2026-07-10', [_doseLogJson]);

      expect(await dao.fetchByDate('2026-07-09'), hasLength(1));
      expect(await dao.fetchByDate('2026-07-10'), hasLength(1));
    });

    test('insertOptimistic inserts with pending syncStatus', () async {
      final id = await dao.insertOptimistic('2026-07-10', _doseLogJson);
      expect(id, 'log1');

      final result = await dao.fetchByDate('2026-07-10');
      expect(result, hasLength(1));
    });

    test('confirmSync replaces optimistic copy with server response', () async {
      const serverJson =
          '{"id":"server_log1","currentMedicineId":"med1","reminderId":"rem1","status":"taken","scheduledFor":"2026-07-10","scheduledTime":"08:00","doseText":"1片","note":null,"createdAt":"2026-07-10T00:00:01.000Z","updatedAt":"2026-07-10T00:00:01.000Z"}';

      await dao.insertOptimistic('2026-07-10', _doseLogJson);
      await dao.confirmSync('log1', serverJson);

      // confirmSync updates the row ID, so the old ID no longer exists.
      // The row should now have the new server ID.
      final result = await dao.fetchByDate('2026-07-10');
      expect(result, hasLength(1));
    });

    test('cleanup removes old synced rows but preserves pending', () async {
      const syncedJson =
          '{"id":"log_synced","currentMedicineId":"med1","reminderId":"rem1","status":"taken","scheduledFor":"2026-07-10","scheduledTime":"08:00","doseText":"1片","note":null,"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';
      const pendingJson =
          '{"id":"log_pending","currentMedicineId":"med2","reminderId":null,"status":"planned","scheduledFor":"2026-07-10","scheduledTime":null,"doseText":null,"note":null,"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.replaceByDate('2026-07-10', [syncedJson]);
      await dao.insertOptimistic('2026-07-10', pendingJson);

      final deleted = await dao.cleanup(
        DateTime.now().add(const Duration(hours: 1)),
      );
      expect(deleted, 1); // Only the synced row from replaceByDate

      final remaining = await dao.fetchByDate('2026-07-10');
      expect(remaining, hasLength(1));
      expect(remaining.first, contains('"id":"log_pending"'));
    });

    test('cleanup returns 0 when nothing to delete', () async {
      final deleted = await dao.cleanup(DateTime.now());
      expect(deleted, 0);
    });

    test('watchByDate emits updates reactively', () async {
      final stream = dao.watchByDate('2026-07-10');
      final firstEmission = await stream.first;
      expect(firstEmission, isEmpty);

      await dao.replaceByDate('2026-07-10', [_doseLogJson]);

      final secondEmission = await stream.first;
      expect(secondEmission, hasLength(1));
    });
  });

  // ─── DailyRecordDao — additional methods ─────────────────────────────
  group('DailyRecordDao — additional methods', () {
    late AppDatabase db;
    late DailyRecordDao dao;

    setUp(() {
      db = _createTestDatabase();
      dao = db.dailyRecordDao;
    });

    tearDown(() => db.close());

    test('markPendingSync sets syncStatus to pending', () async {
      const date = '2026-07-10';
      await dao.replaceByDate(date, jsonItems: [_dailyRecordJson]);

      // markPendingSync should not throw
      await dao.markPendingSync('rec1');

      // After marking as pending, cleanup should preserve this row
      final deleted = await dao.cleanup(
        DateTime.now().add(const Duration(hours: 1)),
      );
      expect(deleted, 0); // pending row is preserved
    });

    test('updateData updates record data and cachedAt', () async {
      const date = '2026-07-10';
      await dao.replaceByDate(date, jsonItems: [_dailyRecordJson]);

      const updatedJson =
          '{"id":"rec1","kind":"water","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"750","unit":"ml","note":"updated","source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.updateData('rec1', updatedJson);

      final result = await dao.fetchByDate(date);
      expect(result, hasLength(1));
      expect(result.first, contains('"value":"750"'));
      expect(result.first, contains('"note":"updated"'));
    });

    test('updateData on non-existent row does not throw', () async {
      // No row exists with this ID — update should be a no-op
      await dao.updateData('nonexistent', _dailyRecordJson);
      // Should not throw
    });

    test('fetchByDate with kind filter returns only matching records', () async {
      const date = '2026-07-10';
      const sleepJson =
          '{"id":"rec2","kind":"sleep","occurredAt":"2026-07-10","occurredTime":null,"title":null,"value":"8","unit":"h","note":null,"source":null,"payload":null,"mealAnalysisStatus":null,"mealAnalysisCoverage":null,"mealAnalysisUpdatedAt":null,"mealAnalysisFailureReason":null,"mealShortDescription":null,"mealTopFoods":[],"attachments":[],"createdAt":"2026-07-10T00:00:00.000Z","updatedAt":"2026-07-10T00:00:00.000Z"}';

      await dao.replaceByDate(date, jsonItems: [_dailyRecordJson, sleepJson]);

      final waterOnly = await dao.fetchByDate(date, kind: 'water');
      expect(waterOnly, hasLength(1));
      expect(waterOnly.first, contains('"id":"rec1"'));

      final sleepOnly = await dao.fetchByDate(date, kind: 'sleep');
      expect(sleepOnly, hasLength(1));
      expect(sleepOnly.first, contains('"id":"rec2"'));

      final all = await dao.fetchByDate(date);
      expect(all, hasLength(2));
    });
  });

  // ─── CurrentMedicineDao — clear ──────────────────────────────────────
  group('CurrentMedicineDao — clear', () {
    late AppDatabase db;

    setUp(() {
      db = _createTestDatabase();
    });

    tearDown(() => db.close());

    test('clear removes cached snapshot', () async {
      const json = '[{"id":"med1","name":"Aspirin"}]';
      await db.currentMedicineDao.replace(json);
      expect(await db.currentMedicineDao.fetch(), isNotNull);

      await db.currentMedicineDao.clear();
      expect(await db.currentMedicineDao.fetch(), isNull);
    });

    test('replace overwrites previous snapshot', () async {
      await db.currentMedicineDao.replace('[{"id":"med1"}]');
      await db.currentMedicineDao.replace('[{"id":"med2"}]');

      final result = await db.currentMedicineDao.fetch();
      expect(result, contains('"med2"'));
      expect(result, isNot(contains('"med1"')));
    });
  });

  // ─── HealthContextDao — clear ────────────────────────────────────────
  group('HealthContextDao — clear', () {
    late AppDatabase db;

    setUp(() {
      db = _createTestDatabase();
    });

    tearDown(() => db.close());

    test('clear removes cached snapshot', () async {
      const json = '{"test":true}';
      await db.healthContextDao.replace(json);
      expect(await db.healthContextDao.fetch(), isNotNull);

      await db.healthContextDao.clear();
      expect(await db.healthContextDao.fetch(), isNull);
    });

    test('replace overwrites previous snapshot', () async {
      await db.healthContextDao.replace('{"v":1}');
      await db.healthContextDao.replace('{"v":2}');

      final result = await db.healthContextDao.fetch();
      expect(result, contains('"v":2'));
    });
  });

  // ─── TodaySuggestionDao — clear ──────────────────────────────────────
  group('TodaySuggestionDao — clear', () {
    late AppDatabase db;

    setUp(() {
      db = _createTestDatabase();
    });

    tearDown(() => db.close());

    test('clear removes cached snapshot', () async {
      const json =
          '{"generatedAt":"2026-07-10T00:00:00Z","primary":null,"secondary":[],"observations":[]}';
      await db.todaySuggestionDao.replace(json);
      expect(await db.todaySuggestionDao.fetch(), isNotNull);

      await db.todaySuggestionDao.clear();
      expect(await db.todaySuggestionDao.fetch(), isNull);
    });

    test('replace overwrites previous snapshot', () async {
      await db.todaySuggestionDao.replace('{"v":1}');
      await db.todaySuggestionDao.replace('{"v":2}');

      final result = await db.todaySuggestionDao.fetch();
      expect(result, contains('"v":2'));
    });
  });

  // ─── PendingSyncDao — additional coverage ────────────────────────────
  group('PendingSyncDao — additional coverage', () {
    late AppDatabase db;
    late PendingSyncDao dao;

    setUp(() {
      db = _createTestDatabase();
      dao = db.pendingSyncDao;
    });

    tearDown(() => db.close());

    test('pendingCount returns 0 when queue is empty', () async {
      expect(await dao.pendingCount(), 0);
    });

    test('pendingCount counts non-syncing items', () async {
      await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );
      await dao.enqueue(
        entityType: 'daily_record',
        operation: 'update',
        payload: '{}',
      );

      expect(await dao.pendingCount(), 2);
    });

    test('pendingCount excludes items currently syncing', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );
      await dao.enqueue(
        entityType: 'daily_record',
        operation: 'update',
        payload: '{}',
      );

      await dao.markSyncing(id);
      expect(await dao.pendingCount(), 1);
    });

    test('markFailed on non-existent row is a no-op', () async {
      await dao.markFailed('nonexistent', 'error');
      expect(await dao.pendingCount(), 0);
    });

    test(
      'PendingSyncEntry.isPermanentlyFailed when retryCount >= maxRetry',
      () async {
        final id = await dao.enqueue(
          entityType: 'daily_record',
          operation: 'create',
          payload: '{}',
        );

        // Exhaust all retries (default maxRetry = 5)
        for (var i = 0; i < 5; i++) {
          await dao.markSyncing(id);
          await dao.markFailed(id, 'error $i');
        }

        final ready = await dao.fetchReady();
        expect(ready, isEmpty);
      },
    );

    test(
      'fetchReady returns items with no lastAttemptAt immediately',
      () async {
        await dao.enqueue(
          entityType: 'daily_record',
          entityId: 'item1',
          operation: 'create',
          payload: '{}',
        );

        final ready = await dao.fetchReady();
        expect(ready, hasLength(1));
        expect(ready.first.entityId, 'item1');
        expect(ready.first.retryCount, 0);
        expect(ready.first.maxRetry, 5);
      },
    );

    test('fetchReady excludes items currently syncing', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );

      await dao.markSyncing(id);
      expect(await dao.fetchReady(), isEmpty);
    });

    test('enqueue generates unique IDs for concurrent inserts', () async {
      final id1 = await dao.enqueue(
        entityType: 'type_a',
        operation: 'create',
        payload: '{}',
      );
      final id2 = await dao.enqueue(
        entityType: 'type_b',
        operation: 'create',
        payload: '{}',
      );

      expect(id1, isNot(equals(id2)));
      expect(await dao.pendingCount(), 2);
    });

    test('remove on non-existent id is a no-op', () async {
      await dao.remove('nonexistent');
      expect(await dao.pendingCount(), 0);
    });

    test('permanentlyFailedCount returns 0 when nothing failed', () async {
      await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );
      expect(await dao.permanentlyFailedCount(), 0);
    });

    test('permanentlyFailedCount counts items exceeding maxRetry', () async {
      final id = await dao.enqueue(
        entityType: 'daily_record',
        entityId: 'rec1',
        operation: 'update',
        payload: '{"id":"rec1"}',
      );

      // Exhaust all retries (default maxRetry = 5)
      for (var i = 0; i < 5; i++) {
        await dao.markSyncing(id);
        await dao.markFailed(id, 'error $i');
      }

      expect(await dao.permanentlyFailedCount(), 1);

      // A healthy pending item is not counted
      await dao.enqueue(
        entityType: 'daily_record',
        operation: 'create',
        payload: '{}',
      );
      expect(await dao.permanentlyFailedCount(), 1);
    });

    test(
      'permanentlyFailedCount excludes items that were reset for retry',
      () async {
        final id = await dao.enqueue(
          entityType: 'daily_record',
          operation: 'create',
          payload: '{}',
        );

        for (var i = 0; i < 5; i++) {
          await dao.markSyncing(id);
          await dao.markFailed(id, 'error');
        }
        expect(await dao.permanentlyFailedCount(), 1);

        await dao.resetForRetry(id);
        expect(await dao.permanentlyFailedCount(), 0);
      },
    );
  });

  // ─── PendingSyncEntry — unit properties ──────────────────────────────
  group('PendingSyncEntry', () {
    test('isPermanentlyFailed is true when retryCount >= maxRetry', () {
      final entry = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 5,
        maxRetry: 5,
      );
      expect(entry.isPermanentlyFailed, isTrue);
    });

    test('isPermanentlyFailed is false when retryCount < maxRetry', () {
      final entry = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 4,
        maxRetry: 5,
      );
      expect(entry.isPermanentlyFailed, isFalse);
    });

    test('backoffDelay doubles with each retry', () {
      final base = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 0,
        maxRetry: 5,
      );

      expect(base.backoffDelay, const Duration(seconds: 30));

      final retry1 = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 1,
        maxRetry: 5,
      );
      expect(retry1.backoffDelay, const Duration(seconds: 60));

      final retry2 = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 2,
        maxRetry: 5,
      );
      expect(retry2.backoffDelay, const Duration(seconds: 120));
    });

    test('backoffDelay caps at 30 minutes', () {
      final entry = PendingSyncEntry(
        id: 'test',
        entityType: 'daily_record',
        entityId: null,
        operation: 'create',
        payload: '{}',
        createdAt: DateTime.now(),
        retryCount: 10,
        maxRetry: 15,
      );
      expect(entry.backoffDelay, const Duration(minutes: 30));
    });
  });
}
