import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/medicine_dose_log_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dose_log_cached.g.dart';

/// Cache-first wrapper around [DoseLogRemoteDataSource], implementing the
/// [DoseLogRepository] boundary.
///
/// Repository boundary: every expected recoverable failure is a `TaskEither`
/// Left produced via `LucentErrorMapper.fromObject`.
///
/// Read: returns cached dose logs for a date immediately, then background
/// refreshes (path B — best-effort, failures are logged and the cached value
/// is still returned). If the cache is empty, fetches from the network and
/// populates the cache; populating the cache is part of the request contract
/// (path A), so a cache read/write failure on this path is a Left. A corrupt
/// cache entry is likewise a Left — it is never silently converted into an
/// unconditional success.
///
/// Write: attempts the remote mutation; on success, refreshes the cache for
/// the affected date as best-effort (path B — the write itself succeeded, a
/// cache refresh failure is only observed). On network failure
/// ([DioException]), enqueues the HTTP request into the pending sync queue
/// for later replay by [SyncWorker], then surfaces a Left so the UI can show
/// an error.
class CachedDoseLogDataSource implements DoseLogRepository {
  CachedDoseLogDataSource({
    required this.remote,
    required this.dao,
    this.pendingSyncDao,
    this.syncWorker,
  });

  final DoseLogRemoteDataSource remote;
  final MedicineDoseLogDao dao;
  final PendingSyncDao? pendingSyncDao;
  final SyncWorker? syncWorker;

  DateTime? _lastRefreshAttempt;

  @override
  TaskEither<LucentFailure, List<DoseLogItem>> fetchForDate(String date) {
    return TaskEither.tryCatch(() async {
      // 1. Check cache
      final cachedJson = await dao.fetchByDate(date);
      if (cachedJson.isNotEmpty) {
        final cached = cachedJson.map(_itemFromJson).toList();
        // Background refresh (throttled 60s for dose logs — TTL is 1h),
        // best-effort cache write (path B).
        _refreshInBackground(date);
        return cached;
      }

      // 2. Cache empty → fetch from network. Populating the cache is part of
      // the request contract (path A): a cache write failure is a Left.
      final remoteItems = await remote.fetchForDate(date);
      final jsonItems = remoteItems.map(_itemToJson).toList();
      await dao.replaceByDate(date, jsonItems);
      return remoteItems;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) {
    return _write(
      () => remote.create(currentMedicineId, status, date),
      date: date,
    );
  }

  @override
  TaskEither<LucentFailure, DoseLogItem> update(
    String doseLogId,
    String status,
  ) {
    // No date to target, so no targeted cache refresh (existing contract).
    return _write(() => remote.update(doseLogId, status));
  }

  @override
  TaskEither<LucentFailure, void> delete(
    String doseLogId, {
    required String date,
  }) {
    return TaskEither.tryCatch(() async {
      try {
        await remote.delete(doseLogId);
        await _refreshCacheBestEffort(date);
      } on DioException catch (e) {
        await _enqueueWriteFailure(e, dateOverride: date);
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) {
    return _write(
      () => remote.mark(
        currentMedicineId: currentMedicineId,
        status: status,
        date: date,
        reminderId: reminderId,
        scheduledTime: scheduledTime,
      ),
      date: date,
    );
  }

  /// Runs a remote mutation and maps every failure to a [LucentFailure] Left.
  ///
  /// Network failures ([DioException]) are first enqueued into the pending
  /// sync queue (existing offline contract), then surfaced as a Left. After a
  /// successful remote write the cache refresh for [date] is best-effort
  /// (path B): a refresh failure — network or cache write — is only logged,
  /// never turned into a write failure, and never enqueued as a replay.
  TaskEither<LucentFailure, DoseLogItem> _write(
    Future<DoseLogItem> Function() remoteCall, {
    String? date,
  }) {
    return TaskEither.tryCatch(() async {
      try {
        final result = await remoteCall();
        if (date != null) {
          await _refreshCacheBestEffort(date);
        }
        return result;
      } on DioException catch (e) {
        await _enqueueWriteFailure(e);
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Enqueues a failed write operation into the pending sync queue.
  ///
  /// The HTTP method, path, and request body are serialized from the
  /// [DioException]'s [RequestOptions]. If the request body contains a
  /// `scheduledFor` field, it is also stored so the replay handler can
  /// refresh the cache for that date after a successful replay.
  ///
  /// Enqueueing is best-effort: if the local DB write fails, the failure is
  /// only logged and the original network failure is still surfaced as a Left.
  Future<void> _enqueueWriteFailure(
    DioException e, {
    String? dateOverride,
  }) async {
    appTalker.warning('DoseLog write failed, queuing for sync: $e');

    final psq = pendingSyncDao;
    if (psq == null) return;

    try {
      await psq.enqueue(
        entityType: 'dose_log',
        operation: 'write',
        payload: _serializeHttpRequest(
          e.requestOptions,
          dateOverride: dateOverride,
        ),
      );
      unawaited(syncWorker?.flush());
    } catch (error, stackTrace) {
      // 入队（本地 DB 写）失败不得掩盖原始网络失败：仅记录日志，仍按原
      // 网络失败映射 Left。
      appTalker.error(
        'DoseLog write enqueue failed, keeping the original network '
        'failure: $error',
        stackTrace,
      );
    }
  }

  /// Serializes a [RequestOptions] into a JSON string for the pending sync
  /// queue payload. Extracts `scheduledFor` from the body (if present) for
  /// targeted cache refresh after replay.
  static String _serializeHttpRequest(
    RequestOptions options, {
    String? dateOverride,
  }) {
    final body = options.data;
    String? date = dateOverride;
    if (body is Map<String, dynamic>) {
      date ??= body['scheduledFor'] as String?;
    }
    return jsonEncode({
      'method': options.method,
      'path': options.path,
      if (body is Map<String, dynamic>) 'body': body,
      if (date != null) 'date': date,
    });
  }

  void _refreshInBackground(String date) {
    final now = DateTime.now();
    if (_lastRefreshAttempt != null &&
        now.difference(_lastRefreshAttempt!) < const Duration(seconds: 60)) {
      return;
    }
    _lastRefreshAttempt = now;

    unawaited(
      Future(() async {
        try {
          await _refreshCache(date);
        } catch (e) {
          appTalker.warning('DoseLog background refresh failed: $e');
        }
      }),
    );
  }

  /// Best-effort cache refresh after a successful write (path B): failures —
  /// network or cache write — are only observed, never surfaced.
  Future<void> _refreshCacheBestEffort(String date) async {
    try {
      await _refreshCache(date);
    } catch (e) {
      appTalker.warning('DoseLog post-write cache refresh failed: $e');
    }
  }

  Future<void> _refreshCache(String date) async {
    final items = await remote.fetchForDate(date);
    final jsonItems = items.map(_itemToJson).toList();
    await dao.replaceByDate(date, jsonItems);
  }

  static String _itemToJson(DoseLogItem item) {
    return jsonEncode({
      'id': item.id,
      'currentMedicineId': item.currentMedicineId,
      'reminderId': item.reminderId,
      'status': item.status.name,
      'scheduledFor': item.scheduledFor,
      'scheduledTime': item.scheduledTime,
      'doseText': item.doseText,
      'note': item.note,
      'createdAt': item.createdAt,
      'updatedAt': item.updatedAt,
    });
  }

  static DoseLogItem _itemFromJson(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return DoseLogItem(
      id: m['id'] as String,
      currentMedicineId: m['currentMedicineId'] as String?,
      reminderId: m['reminderId'] as String?,
      status: DoseLogStatus.values.firstWhere(
        (e) => e.name == m['status'],
        orElse: () => DoseLogStatus.planned,
      ),
      scheduledFor: m['scheduledFor'] as String,
      scheduledTime: m['scheduledTime'] as String?,
      doseText: m['doseText'] as String?,
      note: m['note'] as String?,
      createdAt: m['createdAt'] as String,
      updatedAt: m['updatedAt'] as String,
    );
  }
}

/// Provider for [DoseLogRepository] — returns the cache-first
/// [CachedDoseLogDataSource] implementation.
@riverpod
DoseLogRepository doseLogRepository(Ref ref) {
  return ref.watch(cachedDoseLogDataSourceProvider);
}

@riverpod
CachedDoseLogDataSource cachedDoseLogDataSource(Ref ref) {
  final remote = ref.watch(doseLogRemoteDataSourceProvider);
  final dao = ref.watch(medicineDoseLogDaoProvider);
  final pendingSyncDao = ref.watch(pendingSyncDaoProvider);
  final syncWorker = ref.watch(syncWorkerProvider);
  final dio = ref.watch(lucentDioClientProvider).dio;

  // Register replay handler for dose_log entity type.
  // Replays the original HTTP request, then refreshes the cache for
  // the affected date (if available).
  syncWorker.registerHandler('dose_log', (entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    final method = payload['method'] as String;
    final path = payload['path'] as String;
    final body = payload['body'] as Map<String, dynamic>?;
    final date = payload['date'] as String?;

    await dio.request<Object>(
      path,
      data: body,
      options: Options(method: method, contentType: Headers.jsonContentType),
    );

    // After successful replay, refresh the cache for the date if available.
    if (date != null) {
      try {
        final items = await remote.fetchForDate(date);
        final jsonItems = items
            .map(CachedDoseLogDataSource._itemToJson)
            .toList();
        await dao.replaceByDate(date, jsonItems);
      } catch (e) {
        appTalker.warning(
          'DoseLog sync replay: cache refresh failed for date $date: $e',
        );
      }
    }
  });

  return CachedDoseLogDataSource(
    remote: remote,
    dao: dao,
    pendingSyncDao: pendingSyncDao,
    syncWorker: syncWorker,
  );
}
