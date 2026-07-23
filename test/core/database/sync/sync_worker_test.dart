import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker_pkg;

// ── Mock ───────────────────────────────────────────────────────

class MockPendingSyncDao extends Mock implements PendingSyncDao {}

// ── Helpers ────────────────────────────────────────────────────

PendingSyncEntry _createEntry({
  String id = 'entry-001',
  String entityType = 'daily_record',
  String? entityId = 'rec-001',
  String operation = 'create',
  String payload = '{}',
  int retryCount = 0,
  int maxRetry = 5,
}) {
  return PendingSyncEntry(
    id: id,
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    createdAt: DateTime(2026, 7, 10),
    retryCount: retryCount,
    maxRetry: maxRetry,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock connectivity_plus platform channel so SyncWorker.start() works in tests
  const eventChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(eventChannel, (call) async {
        if (call.method == 'getAllLocations') {
          return <Map<dynamic, dynamic>>[];
        }
        return null;
      });

  late MockPendingSyncDao mockDao;
  late talker_pkg.Talker talker;
  late SyncWorker worker;

  setUp(() {
    mockDao = MockPendingSyncDao();
    talker = talker_pkg.Talker();
    worker = SyncWorker(pendingSyncDao: mockDao, dio: Dio(), talker: talker);
  });

  group('SyncWorker.registerHandler', () {
    test('registers handler for entity type', () async {
      when(() => mockDao.fetchReady()).thenAnswer((_) async => []);
      bool handlerCalled = false;
      worker.registerHandler('daily_record', (entry) async {
        handlerCalled = true;
      });

      when(
        () => mockDao.fetchReady(),
      ).thenAnswer((_) async => [_createEntry()]);
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      await worker.flush();

      expect(handlerCalled, isTrue);
    });
  });

  group('SyncWorker.flush', () {
    test('does nothing when no pending items', () async {
      when(() => mockDao.fetchReady()).thenAnswer((_) async => []);

      await worker.flush();

      verify(() => mockDao.fetchReady()).called(1);
      verifyNever(() => mockDao.markSyncing(any()));
      verifyNever(() => mockDao.remove(any()));
      verifyNever(() => mockDao.markFailed(any(), any()));
    });

    test('replays entry successfully and removes it', () async {
      final entry = _createEntry(id: 'sync-001');
      when(() => mockDao.fetchReady()).thenAnswer((_) async => [entry]);
      when(() => mockDao.markSyncing('sync-001')).thenAnswer((_) async {});
      when(() => mockDao.remove('sync-001')).thenAnswer((_) async {});

      bool handlerCalled = false;
      worker.registerHandler('daily_record', (e) async {
        handlerCalled = true;
        expect(e.id, 'sync-001');
      });

      await worker.flush();

      expect(handlerCalled, isTrue);
      verify(() => mockDao.markSyncing('sync-001')).called(1);
      verify(() => mockDao.remove('sync-001')).called(1);
      verifyNever(() => mockDao.markFailed(any(), any()));
    });

    test('marks failed on DioException and does not remove', () async {
      final entry = _createEntry(id: 'fail-001');
      when(() => mockDao.fetchReady()).thenAnswer((_) async => [entry]);
      when(() => mockDao.markSyncing('fail-001')).thenAnswer((_) async {});
      when(
        () => mockDao.markFailed('fail-001', any()),
      ).thenAnswer((_) async {});

      worker.registerHandler('daily_record', (e) async {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/v1/test'),
          type: DioExceptionType.connectionError,
        );
      });

      await worker.flush();

      verify(() => mockDao.markSyncing('fail-001')).called(1);
      verify(() => mockDao.markFailed('fail-001', any())).called(1);
      verifyNever(() => mockDao.remove(any()));
    });

    test('marks failed on generic exception and does not remove', () async {
      final entry = _createEntry(id: 'generic-fail');
      when(() => mockDao.fetchReady()).thenAnswer((_) async => [entry]);
      when(() => mockDao.markSyncing('generic-fail')).thenAnswer((_) async {});
      when(
        () => mockDao.markFailed('generic-fail', any()),
      ).thenAnswer((_) async {});

      worker.registerHandler('daily_record', (e) async {
        throw StateError('unexpected error');
      });

      await worker.flush();

      verify(() => mockDao.markFailed('generic-fail', any())).called(1);
      verifyNever(() => mockDao.remove(any()));
    });

    test('skips entry when no handler registered for entity type', () async {
      final entry = _createEntry(id: 'no-handler', entityType: 'unknown_type');
      when(() => mockDao.fetchReady()).thenAnswer((_) async => [entry]);
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      await worker.flush();

      // Should NOT call markSyncing or remove since no handler
      verifyNever(() => mockDao.markSyncing(any()));
      verifyNever(() => mockDao.remove(any()));
    });

    test('replays multiple entries in order', () async {
      final entries = [
        _createEntry(id: 'entry-1', entityId: 'rec-1'),
        _createEntry(id: 'entry-2', entityId: 'rec-2'),
        _createEntry(id: 'entry-3', entityId: 'rec-3'),
      ];
      when(() => mockDao.fetchReady()).thenAnswer((_) async => entries);
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      final processedIds = <String>[];
      worker.registerHandler('daily_record', (e) async {
        processedIds.add(e.entityId!);
      });

      await worker.flush();

      expect(processedIds, ['rec-1', 'rec-2', 'rec-3']);
      verify(() => mockDao.remove('entry-1')).called(1);
      verify(() => mockDao.remove('entry-2')).called(1);
      verify(() => mockDao.remove('entry-3')).called(1);
    });

    test('prevents concurrent flush calls', () async {
      final entry = _createEntry(id: 'concurrent-001');
      when(() => mockDao.fetchReady()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [entry];
      });
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      worker.registerHandler('daily_record', (e) async {});

      // Call flush twice concurrently
      await Future.wait([worker.flush(), worker.flush()]);

      // fetchReady should only be called once due to _isFlushing guard
      verify(() => mockDao.fetchReady()).called(1);
    });

    test('recovers from unexpected error in flush', () async {
      when(
        () => mockDao.fetchReady(),
      ).thenThrow(StateError('database connection lost'));

      // Should not throw — error is caught internally
      await worker.flush();

      verify(() => mockDao.fetchReady()).called(1);
    });
  });

  group('SyncWorker.start / stop', () {
    test('start and stop do not throw', () {
      // start() begins listening to connectivity changes.
      // In test environment without platform channels, this should
      // not throw during start/stop lifecycle.
      worker.start();
      worker.stop();
    });

    test('stop is safe to call without start', () {
      worker.stop();
      // No exception thrown
    });

    test('start can be called multiple times safely', () {
      worker.start();
      worker.start();
      worker.stop();
    });
  });

  group('SyncWorker — handler interaction patterns', () {
    test('handler receives full entry with payload and operation', () async {
      final entry = _createEntry(
        id: 'detail-001',
        entityType: 'daily_record',
        entityId: 'rec-detail',
        operation: 'update',
        payload: '{"value":"500","unit":"ml"}',
      );
      when(() => mockDao.fetchReady()).thenAnswer((_) async => [entry]);
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      PendingSyncEntry? receivedEntry;
      worker.registerHandler('daily_record', (e) async {
        receivedEntry = e;
      });

      await worker.flush();

      expect(receivedEntry, isNotNull);
      expect(receivedEntry!.id, 'detail-001');
      expect(receivedEntry!.entityType, 'daily_record');
      expect(receivedEntry!.entityId, 'rec-detail');
      expect(receivedEntry!.operation, 'update');
      expect(receivedEntry!.payload, '{"value":"500","unit":"ml"}');
    });

    test('different entity types use different handlers', () async {
      final dailyEntry = _createEntry(
        id: 'daily-001',
        entityType: 'daily_record',
      );
      final medicineEntry = _createEntry(
        id: 'med-001',
        entityType: 'medicine_dose_log',
      );
      when(
        () => mockDao.fetchReady(),
      ).thenAnswer((_) async => [dailyEntry, medicineEntry]);
      when(() => mockDao.markSyncing(any())).thenAnswer((_) async {});
      when(() => mockDao.remove(any())).thenAnswer((_) async {});

      final dailyHandlerCalled = <String>[];
      final medicineHandlerCalled = <String>[];

      worker.registerHandler('daily_record', (e) async {
        dailyHandlerCalled.add(e.id);
      });
      worker.registerHandler('medicine_dose_log', (e) async {
        medicineHandlerCalled.add(e.id);
      });

      await worker.flush();

      expect(dailyHandlerCalled, ['daily-001']);
      expect(medicineHandlerCalled, ['med-001']);
    });
  });
}
