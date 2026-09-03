import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/daos/medicine_dose_log.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../helpers/task_either.dart';

class _FakeDoseLogRemote extends DoseLogRemoteDataSource {
  _FakeDoseLogRemote() : super(api: MedicineDoseLogsApi(Dio()), dio: Dio());

  List<DoseLogItem> fetchResult = [];
  Object? fetchError;
  DoseLogItem? createResult;
  DoseLogItem? updateResult;
  DoseLogItem? markResult;
  String? lastDeleteId;
  String? lastDeleteDate;
  String? lastFetchDate;
  String? lastCreateDate;
  String? lastCreateStatus;
  String? lastUpdateId;
  String? lastUpdateStatus;
  String? lastMarkMedicineId;
  String? lastMarkStatus;
  String? lastMarkDate;
  String? lastMarkReminderId;
  String? lastMarkScheduledTime;
  int fetchCallCount = 0;

  /// When true, write operations throw a [DioException].
  bool writeShouldFail = false;

  DioException _networkError(String path, {Map<String, dynamic>? data}) =>
      DioException(
        requestOptions: RequestOptions(path: path, method: 'POST', data: data),
        type: DioExceptionType.connectionError,
      );

  @override
  Future<List<DoseLogItem>> fetchForDate(String date) async {
    lastFetchDate = date;
    fetchCallCount++;
    if (fetchError != null) throw fetchError!;
    return fetchResult;
  }

  @override
  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    if (writeShouldFail) {
      throw _networkError(
        '/api/v1/user/medicine-dose-logs',
        data: {
          'currentMedicineId': currentMedicineId,
          'status': status,
          'scheduledFor': date,
        },
      );
    }
    lastCreateDate = date;
    lastCreateStatus = status;
    return createResult ??
        DoseLogItem(
          id: 'created-1',
          currentMedicineId: currentMedicineId,
          status: DoseLogStatus.taken,
          scheduledFor: date,
          createdAt: '2026-07-10T00:00:00.000Z',
          updatedAt: '2026-07-10T00:00:00.000Z',
        );
  }

  @override
  Future<DoseLogItem> update(String doseLogId, String status) async {
    if (writeShouldFail) {
      throw _networkError(
        '/api/v1/user/medicine-dose-logs/$doseLogId',
        data: {'status': status},
      );
    }
    lastUpdateId = doseLogId;
    lastUpdateStatus = status;
    return updateResult ??
        DoseLogItem(
          id: doseLogId,
          status: DoseLogStatus.taken,
          scheduledFor: '2026-07-10',
          createdAt: '2026-07-10T00:00:00.000Z',
          updatedAt: '2026-07-10T00:00:00.000Z',
        );
  }

  @override
  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    if (writeShouldFail) {
      throw _networkError(
        '/api/v1/user/medicine-dose-logs/mark',
        data: {
          'currentMedicineId': currentMedicineId,
          'status': status,
          'scheduledFor': date,
          if (reminderId != null) 'reminderId': reminderId,
          if (scheduledTime != null) 'scheduledTime': scheduledTime,
        },
      );
    }
    lastMarkMedicineId = currentMedicineId;
    lastMarkStatus = status;
    lastMarkDate = date;
    lastMarkReminderId = reminderId;
    lastMarkScheduledTime = scheduledTime;
    return markResult ??
        DoseLogItem(
          id: 'marked-1',
          currentMedicineId: currentMedicineId,
          reminderId: reminderId,
          status: DoseLogStatus.taken,
          scheduledFor: date,
          scheduledTime: scheduledTime,
          createdAt: '2026-07-10T00:00:00.000Z',
          updatedAt: '2026-07-10T00:00:00.000Z',
        );
  }

  @override
  Future<void> delete(String doseLogId) async {
    if (writeShouldFail) {
      throw _networkError('/api/v1/user/medicine-dose-logs/$doseLogId');
    }
    lastDeleteId = doseLogId;
  }
}

class _MockPendingSyncDao extends Mock implements PendingSyncDao {}

class _FakeSyncWorker extends SyncWorker {
  _FakeSyncWorker({required super.pendingSyncDao})
    : super(dio: Dio(), talker: Talker());

  bool flushCalled = false;

  @override
  Future<void> flush() async {
    flushCalled = true;
  }
}

DoseLogItem _buildItem({
  String id = 'log-1',
  String? currentMedicineId = 'med-1',
  String? reminderId,
  DoseLogStatus status = DoseLogStatus.taken,
  String scheduledFor = '2026-07-10',
  String? scheduledTime = '08:00',
  String? doseText = '1片',
  String? note,
  String createdAt = '2026-07-10T00:00:00.000Z',
  String updatedAt = '2026-07-10T00:00:00.000Z',
}) {
  return DoseLogItem(
    id: id,
    currentMedicineId: currentMedicineId,
    reminderId: reminderId,
    status: status,
    scheduledFor: scheduledFor,
    scheduledTime: scheduledTime,
    doseText: doseText,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

void main() {
  group('CachedDoseLogDataSource', () {
    late _FakeDoseLogRemote remote;
    late AppDatabase db;
    late CachedDoseLogDataSource dataSource;

    setUp(() {
      remote = _FakeDoseLogRemote();
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dataSource = CachedDoseLogDataSource(
        remote: remote,
        dao: db.medicineDoseLogDao,
      );
    });

    tearDown(() => db.close());

    // ─── fetchForDate ────────────────────────────────────────────────
    group('fetchForDate', () {
      test('fetches from network when cache is empty', () async {
        remote.fetchResult = [_buildItem()];

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result, hasLength(1));
        expect(result.first.id, 'log-1');
        expect(remote.lastFetchDate, '2026-07-10');
        expect(remote.fetchCallCount, 1);
      });

      test('returns cached items when cache is populated', () async {
        // Seed cache by fetching once
        remote.fetchResult = [_buildItem()];
        await dataSource.fetchForDate('2026-07-10').run();

        // Reset fetch result to different items to verify cache is used
        remote.fetchResult = [_buildItem(id: 'log-2')];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        // Should return cached items, not new ones
        expect(result, hasLength(1));
        expect(result.first.id, 'log-1');
        // Background refresh should have been triggered, but we can't
        // deterministically test it here without waiting. The important
        // thing is that the immediate return is from cache.
      });

      test('round-trips all DoseLogItem fields through cache', () async {
        final item = _buildItem(
          id: 'full-item',
          currentMedicineId: 'med-full',
          reminderId: 'rem-1',
          status: DoseLogStatus.skipped,
          scheduledFor: '2026-07-11',
          scheduledTime: '14:30',
          doseText: '2片',
          note: '饭后服用',
          createdAt: '2026-07-11T00:00:00.000Z',
          updatedAt: '2026-07-11T01:00:00.000Z',
        );

        remote.fetchResult = [item];
        await dataSource.fetchForDate('2026-07-11').run();

        // Reset to verify cache content
        remote.fetchResult = [];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-11'),
        );

        expect(result, hasLength(1));
        final cached = result.first;
        expect(cached.id, 'full-item');
        expect(cached.currentMedicineId, 'med-full');
        expect(cached.reminderId, 'rem-1');
        expect(cached.status, DoseLogStatus.skipped);
        expect(cached.scheduledFor, '2026-07-11');
        expect(cached.scheduledTime, '14:30');
        expect(cached.doseText, '2片');
        expect(cached.note, '饭后服用');
        expect(cached.createdAt, '2026-07-11T00:00:00.000Z');
        expect(cached.updatedAt, '2026-07-11T01:00:00.000Z');
      });

      test('handles multiple items in cache', () async {
        remote.fetchResult = [
          _buildItem(id: 'log-1'),
          _buildItem(id: 'log-2', status: DoseLogStatus.skipped),
          _buildItem(id: 'log-3', status: DoseLogStatus.missed),
        ];

        await dataSource.fetchForDate('2026-07-10').run();

        remote.fetchResult = [];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result, hasLength(3));
        expect(result[0].id, 'log-1');
        expect(result[0].status, DoseLogStatus.taken);
        expect(result[1].id, 'log-2');
        expect(result[1].status, DoseLogStatus.skipped);
        expect(result[2].id, 'log-3');
        expect(result[2].status, DoseLogStatus.missed);
      });

      test('handles null currentMedicineId', () async {
        remote.fetchResult = [_buildItem(currentMedicineId: null)];

        await dataSource.fetchForDate('2026-07-10').run();

        remote.fetchResult = [];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result, hasLength(1));
        expect(result.first.currentMedicineId, isNull);
      });

      test('handles null optional fields', () async {
        remote.fetchResult = [
          _buildItem(
            reminderId: null,
            scheduledTime: null,
            doseText: null,
            note: null,
          ),
        ];

        await dataSource.fetchForDate('2026-07-10').run();

        remote.fetchResult = [];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result, hasLength(1));
        expect(result.first.reminderId, isNull);
        expect(result.first.scheduledTime, isNull);
        expect(result.first.doseText, isNull);
        expect(result.first.note, isNull);
      });

      test('handles planned status', () async {
        remote.fetchResult = [_buildItem(status: DoseLogStatus.planned)];

        await dataSource.fetchForDate('2026-07-10').run();

        remote.fetchResult = [];
        remote.fetchCallCount = 0;

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result.first.status, DoseLogStatus.planned);
      });

      test('returns empty list when remote returns empty', () async {
        remote.fetchResult = [];

        final result = await expectTaskRight(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(result, isEmpty);
      });

      test(
        'propagates remote fetch errors when cache is empty as a Left',
        () async {
          remote.fetchError = Exception('Network error');

          final failure = await expectTaskLeft(
            dataSource.fetchForDate('2026-07-10'),
          );

          expect(failure.kind, LucentFailureKind.unknown);
        },
      );

      test(
        '404 Problem Details keeps server code and status as a Left',
        () async {
          remote.fetchError = _problemDetails404();

          final failure = await expectTaskLeft(
            dataSource.fetchForDate('2026-07-10'),
          );

          expect(failure.code, 'DOSE_LOG_NOT_FOUND');
          expect(failure.statusCode, 404);
          expect(failure.kind, LucentFailureKind.business);
        },
      );

      test('structural protocol error keeps the StateError cause as a '
          'Left(unknown)', () async {
        // The remote data source throws a protocol StateError for a
        // structurally malformed body (e.g. items not a list); the
        // repository boundary maps it to Left(unknown) without losing the
        // original cause.
        remote.fetchError = StateError('用药记录列表格式异常');

        final failure = await expectTaskLeft(
          dataSource.fetchForDate('2026-07-10'),
        );

        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isA<StateError>());
      });
    });

    // ─── create ──────────────────────────────────────────────────────
    group('create', () {
      test('returns created item from remote', () async {
        final created = _buildItem(id: 'new-log');
        remote.createResult = created;

        final result = await expectTaskRight(
          dataSource.create('med-1', 'taken', '2026-07-10'),
        );

        expect(result.id, 'new-log');
        expect(remote.lastCreateDate, '2026-07-10');
        expect(remote.lastCreateStatus, 'taken');
      });

      test('refreshes cache after create', () async {
        await dataSource.create('med-1', 'taken', '2026-07-10').run();

        // create calls _refreshCache which calls fetchForDate
        expect(remote.fetchCallCount, greaterThanOrEqualTo(1));
        expect(remote.lastFetchDate, '2026-07-10');
      });
    });

    // ─── update ──────────────────────────────────────────────────────
    group('update', () {
      test('returns updated item from remote', () async {
        final updated = _buildItem(id: 'log-1', status: DoseLogStatus.skipped);
        remote.updateResult = updated;

        final result = await expectTaskRight(
          dataSource.update('log-1', 'skipped'),
        );

        expect(result.id, 'log-1');
        expect(result.status, DoseLogStatus.skipped);
        expect(remote.lastUpdateId, 'log-1');
        expect(remote.lastUpdateStatus, 'skipped');
      });

      test('does not refresh cache after update (no date info)', () async {
        await dataSource.update('log-1', 'skipped').run();

        // update should NOT call fetchForDate (no date to target)
        expect(remote.fetchCallCount, 0);
      });
    });

    // ─── mark ────────────────────────────────────────────────────────
    group('mark', () {
      test('returns marked item from remote', () async {
        final marked = _buildItem(id: 'marked-1');
        remote.markResult = marked;

        final result = await expectTaskRight(
          dataSource.mark(
            currentMedicineId: 'med-1',
            status: 'taken',
            date: '2026-07-10',
          ),
        );

        expect(result.id, 'marked-1');
        expect(remote.lastMarkMedicineId, 'med-1');
        expect(remote.lastMarkStatus, 'taken');
        expect(remote.lastMarkDate, '2026-07-10');
      });

      test('passes reminderId and scheduledTime', () async {
        await dataSource
            .mark(
              currentMedicineId: 'med-1',
              status: 'taken',
              date: '2026-07-10',
              reminderId: 'rem-1',
              scheduledTime: '08:00',
            )
            .run();

        expect(remote.lastMarkReminderId, 'rem-1');
        expect(remote.lastMarkScheduledTime, '08:00');
      });

      test(
        'passes null reminderId and scheduledTime when not provided',
        () async {
          await dataSource
              .mark(
                currentMedicineId: 'med-1',
                status: 'taken',
                date: '2026-07-10',
              )
              .run();

          expect(remote.lastMarkReminderId, isNull);
          expect(remote.lastMarkScheduledTime, isNull);
        },
      );

      test('refreshes cache after mark', () async {
        await dataSource
            .mark(
              currentMedicineId: 'med-1',
              status: 'taken',
              date: '2026-07-10',
            )
            .run();

        expect(remote.fetchCallCount, greaterThanOrEqualTo(1));
        expect(remote.lastFetchDate, '2026-07-10');
      });
    });

    // ─── delete ──────────────────────────────────────────────────────
    group('delete', () {
      test(
        'deletes remote dose log and refreshes cache for the date',
        () async {
          await dataSource.delete('log-1', date: '2026-07-10').run();

          expect(remote.lastDeleteId, 'log-1');
          expect(remote.fetchCallCount, greaterThanOrEqualTo(1));
          expect(remote.lastFetchDate, '2026-07-10');
        },
      );
    });

    // ─── JSON serialization round-trip ───────────────────────────────
    group('JSON serialization round-trip', () {
      test('handles all DoseLogStatus values', () async {
        for (final status in DoseLogStatus.values) {
          // Use a unique date per status to avoid cache collision
          final date =
              '2026-07-${(status.index + 1).toString().padLeft(2, '0')}';
          remote.fetchResult = [_buildItem(status: status, scheduledFor: date)];

          await dataSource.fetchForDate(date).run();

          remote.fetchResult = [];
          remote.fetchCallCount = 0;

          final result = await expectTaskRight(dataSource.fetchForDate(date));

          expect(
            result.first.status,
            status,
            reason: 'Failed for status: $status',
          );
        }
      });
    });
    // ─── offline write-path replay ─────────────────────────────────
    group('offline write-path replay', () {
      late _MockPendingSyncDao pendingSyncDao;
      late _FakeSyncWorker syncWorker;

      setUp(() {
        pendingSyncDao = _MockPendingSyncDao();
        syncWorker = _FakeSyncWorker(pendingSyncDao: pendingSyncDao);
        dataSource = CachedDoseLogDataSource(
          remote: remote,
          dao: db.medicineDoseLogDao,
          pendingSyncDao: pendingSyncDao,
          syncWorker: syncWorker,
        );
        when(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            entityId: any(named: 'entityId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        ).thenAnswer((_) async => 'pending-id');
      });

      test('create enqueues pending sync on network failure', () async {
        remote.writeShouldFail = true;

        final failure = await expectTaskLeft(
          dataSource.create('med-1', 'taken', '2026-07-10'),
        );

        expect(failure.kind, LucentFailureKind.network);

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'dose_log',
            operation: 'write',
            payload: any(named: 'payload'),
          ),
        ).called(1);
        expect(syncWorker.flushCalled, isTrue);
      });

      test('mark enqueues pending sync on network failure', () async {
        remote.writeShouldFail = true;

        final failure = await expectTaskLeft(
          dataSource.mark(
            currentMedicineId: 'med-1',
            status: 'taken',
            date: '2026-07-10',
          ),
        );

        expect(failure.kind, LucentFailureKind.network);

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'dose_log',
            operation: 'write',
            payload: any(named: 'payload'),
          ),
        ).called(1);
      });

      test('update enqueues pending sync on network failure', () async {
        remote.writeShouldFail = true;

        final failure = await expectTaskLeft(
          dataSource.update('log-1', 'skipped'),
        );

        expect(failure.kind, LucentFailureKind.network);

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'dose_log',
            operation: 'write',
            payload: any(named: 'payload'),
          ),
        ).called(1);
      });

      test('delete enqueues pending sync on network failure', () async {
        remote.writeShouldFail = true;

        final failure = await expectTaskLeft(
          dataSource.delete('log-1', date: '2026-07-10'),
        );

        expect(failure.kind, LucentFailureKind.network);

        await Future.delayed(Duration.zero);

        verify(
          () => pendingSyncDao.enqueue(
            entityType: 'dose_log',
            operation: 'write',
            payload: any(named: 'payload'),
          ),
        ).called(1);
      });

      test('does not enqueue when pendingSyncDao is null', () async {
        dataSource = CachedDoseLogDataSource(
          remote: remote,
          dao: db.medicineDoseLogDao,
        );
        remote.writeShouldFail = true;

        final failure = await expectTaskLeft(
          dataSource.create('med-1', 'taken', '2026-07-10'),
        );

        expect(failure.kind, LucentFailureKind.network);

        await Future.delayed(Duration.zero);

        verifyNever(
          () => pendingSyncDao.enqueue(
            entityType: any(named: 'entityType'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          ),
        );
      });

      test(
        'enqueue self-failure does not mask the original network failure',
        () async {
          remote.writeShouldFail = true;
          // The local DB enqueue itself throws; the enqueue exception must be
          // only logged — the original network failure kind is still surfaced
          // as the Left (never downgraded to unknown).
          when(
            () => pendingSyncDao.enqueue(
              entityType: any(named: 'entityType'),
              entityId: any(named: 'entityId'),
              operation: any(named: 'operation'),
              payload: any(named: 'payload'),
            ),
          ).thenThrow(StateError('local db write failed'));

          final failure = await expectTaskLeft(
            dataSource.create('med-1', 'taken', '2026-07-10'),
          );

          expect(failure.kind, LucentFailureKind.network);
          expect(failure.isNetworkConnectivityError, isTrue);
          expect(failure.cause, isA<DioException>());
        },
      );
    });

    // ─── cache write failure paths (health_context A/B pattern) ──────
    group('cache write failure paths', () {
      late _MockMedicineDoseLogDao mockDao;

      setUp(() {
        mockDao = _MockMedicineDoseLogDao();
        dataSource = CachedDoseLogDataSource(remote: remote, dao: mockDao);
      });

      test(
        'path A: cache write failure after empty-cache fetch surfaces a Left',
        () async {
          remote.fetchResult = [_buildItem()];
          when(
            () => mockDao.fetchByDate('2026-07-10'),
          ).thenAnswer((_) async => const <String>[]);
          when(
            () => mockDao.replaceByDate('2026-07-10', any()),
          ).thenThrow(Exception('disk full'));

          final failure = await expectTaskLeft(
            dataSource.fetchForDate('2026-07-10'),
          );

          expect(failure.kind, LucentFailureKind.unknown);
          expect(remote.fetchCallCount, 1);
        },
      );

      test(
        'path B: background refresh cache write failure keeps cached items',
        () async {
          when(
            () => mockDao.fetchByDate('2026-07-10'),
          ).thenAnswer((_) async => <String>[_cachedItemJson()]);
          when(
            () => mockDao.replaceByDate('2026-07-10', any()),
          ).thenThrow(Exception('disk full'));

          // Cache hit returns the cached items immediately; the background
          // refresh's cache write fails but is best-effort and only observed.
          final result = await expectTaskRight(
            dataSource.fetchForDate('2026-07-10'),
          );
          await Future.delayed(const Duration(milliseconds: 100));

          expect(result.single.id, 'log-1');
        },
      );

      test(
        'write path B: post-write cache refresh failure keeps the write result',
        () async {
          when(
            () => mockDao.fetchByDate('2026-07-10'),
          ).thenAnswer((_) async => const <String>[]);
          when(
            () => mockDao.replaceByDate('2026-07-10', any()),
          ).thenThrow(Exception('disk full'));

          // The remote write succeeds; the cache refresh (which refetches and
          // rewrites the date) fails but is best-effort — the write result is
          // still a Right and nothing is enqueued for replay.
          final result = await expectTaskRight(
            dataSource.create('med-1', 'taken', '2026-07-10'),
          );

          expect(result.id, 'created-1');
        },
      );
    });
  });
}

String _cachedItemJson() => jsonEncode({
  'id': 'log-1',
  'currentMedicineId': 'med-1',
  'reminderId': null,
  'status': 'taken',
  'scheduledFor': '2026-07-10',
  'scheduledTime': '08:00',
  'doseText': null,
  'note': null,
  'createdAt': '2026-07-10T00:00:00.000Z',
  'updatedAt': '2026-07-10T00:00:00.000Z',
});

/// A 404 RFC 9457 Problem Details body served with
/// `application/problem+json` (server business failure).
DioException _problemDetails404({String code = 'DOSE_LOG_NOT_FOUND'}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/user/medicine-dose-logs'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/user/medicine-dose-logs'),
      statusCode: 404,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Not found',
        'detail': '用药记录不存在',
        'code': code,
      },
    ),
  );
}

class _MockMedicineDoseLogDao extends Mock implements MedicineDoseLogDao {}
