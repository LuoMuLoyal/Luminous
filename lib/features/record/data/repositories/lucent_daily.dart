import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/records/daily_record.dart';
import 'package:luminous/core/database/daos/records/daily_record_summary.dart';
import 'package:luminous/core/database/daos/sync/pending_sync.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/record/data/datasources/record.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';

/// Cache-first implementation of [DailyRecordRepository].
///
/// Repository boundary: every expected recoverable failure is a `TaskEither`
/// Left produced via `LucentErrorMapper.fromObject`; a legal empty page stays
/// a Right.
///
/// Read operations:
/// 1. Return cached data immediately if available.
/// 2. Trigger a background refresh (throttled to 30s) — best-effort (path B):
///    refresh failures are logged, never surfaced.
/// 3. If cache is empty, fetch from network and populate cache — populating
///    the cache is part of the request contract (path A): a cache read/write
///    failure on this path is a Left.
///
/// Write operations:
/// 1. Insert optimistic local copy with syncStatus = 'pending'.
/// 2. Attempt remote write.
/// 3. On success: replace optimistic copy with confirmed server response.
/// 4. On network failure: enqueue pending sync item (best-effort — an enqueue
///    failure is only logged, never masks the original network failure), then
///    surface a Left so the UI can show an error. The optimistic copy stays in
///    the local cache for offline display and later replay by [SyncWorker].
class LucentDailyRecordRepository implements DailyRecordRepository {
  LucentDailyRecordRepository({
    required this.dataSource,
    required this.dao,
    required this.summaryDao,
    this.pendingSyncDao,
    this.syncWorker,
  });

  final DailyRecordRemoteDataSource dataSource;
  final DailyRecordDao dao;
  final DailyRecordSummaryDao summaryDao;
  final PendingSyncDao? pendingSyncDao;
  final SyncWorker? syncWorker;

  /// Background refresh throttle: 30 seconds per date.
  final Map<String, DateTime> _lastRefreshAttempt = {};

  /// Consecutive background refresh failures per date/kind key.
  /// Escalates to error level after [kBackgroundRefreshFailuresBeforeError]
  /// so silent stale-cache problems are not hidden behind warnings.
  final Map<String, int> _backgroundRefreshFailures = {};

  static const int _kBackgroundRefreshFailuresBeforeError = 3;

  /// Maximum number of tracked keys to prevent unbounded growth when the user
  /// browses many different dates. Excess entries are pruned oldest-first.
  static const int _kMaxTrackedRefreshKeys = 50;

  @override
  TaskEither<LucentFailure, DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    return TaskEither.tryCatch(() async {
      // 1. Check cache
      final cachedJson = await dao.fetchByDate(date, kind: kind);
      if (cachedJson.isNotEmpty) {
        final cachedItems = cachedJson
            .map((json) => DailyRecordItem.fromJson(jsonDecode(json)))
            .toList(growable: false);

        // Background refresh (non-blocking, throttled, best-effort path B).
        _refreshInBackground(date, kind: kind, page: page, pageSize: pageSize);

        return DailyRecordListData(
          items: cachedItems,
          total: cachedItems.length,
        );
      }

      // 2. Cache empty → fetch from network. Writing to cache is part of the
      // request contract (path A): a cache write failure is a Left.
      final remote = await dataSource.fetchRecords(
        date,
        kind: kind,
        page: page,
        pageSize: pageSize,
      );

      final jsonItems = remote.items
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await dao.replaceByDate(date, kind: kind, jsonItems: jsonItems);

      return remote;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, DailyRecordSummaryData> fetchSummary(String date) {
    return TaskEither.tryCatch(() async {
      // Cache-first: the dashboard cards render from the summary, so skipping
      // the cache here stalled the whole first frame on the network even when
      // the records themselves were already cached locally.
      final cached = await summaryDao.fetchByDate(date);
      if (cached != null) {
        _refreshSummaryInBackground(date);
        return DailyRecordSummaryData.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }

      // Cache miss → network, and write through so the next read is local.
      final remote = await dataSource.fetchSummary(date);
      await summaryDao.replaceByDate(date, jsonEncode(remote.toJson()));
      return remote;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Best-effort summary refresh: throttled, failures only logged.
  void _refreshSummaryInBackground(String date) {
    final key = 'summary:$date';
    final now = DateTime.now();
    final lastAttempt = _lastRefreshAttempt[key];
    if (lastAttempt != null &&
        now.difference(lastAttempt) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefreshAttempt[key] = now;
    if (_lastRefreshAttempt.length > _kMaxTrackedRefreshKeys) {
      _lastRefreshAttempt.remove(_lastRefreshAttempt.keys.first);
    }

    unawaited(
      Future(() async {
        try {
          final remote = await dataSource.fetchSummary(date);
          await summaryDao.replaceByDate(date, jsonEncode(remote.toJson()));
          _backgroundRefreshFailures.remove(key);
        } catch (e, st) {
          final failures = (_backgroundRefreshFailures[key] ?? 0) + 1;
          _backgroundRefreshFailures[key] = failures;
          if (_backgroundRefreshFailures.length > _kMaxTrackedRefreshKeys) {
            _backgroundRefreshFailures.remove(
              _backgroundRefreshFailures.keys.first,
            );
          }
          final message = 'DailyRecord summary refresh failed: $e';
          if (failures >= _kBackgroundRefreshFailuresBeforeError) {
            appLog.error(message, st);
          } else {
            appLog.warning(message);
          }
        }
      }),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordItem> get(String id) {
    // For detail view, just fetch from network.
    // Cache lookup by ID would require an index; the list cache
    // already covers the common case (browsing a date).
    return TaskEither.tryCatch(
      () => dataSource.get(id),
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) {
    // Image upload is a prerequisite for create/update; no caching.
    return TaskEither.tryCatch(
      () => dataSource.uploadImage(input),
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) {
    // AI-generated candidates; not cached.
    return TaskEither.tryCatch(
      () => dataSource.generateCandidates(text: text, occurredAt: occurredAt),
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, DailyRecordItem> create(
    DailyRecordCreateInput input,
  ) {
    return TaskEither.tryCatch(() async {
      // Build a local optimistic item
      final now = DateTime.now();
      final tempId = 'local_${now.millisecondsSinceEpoch}';
      final optimisticItem = DailyRecordItem(
        id: tempId,
        kind: input.kind,
        occurredAt: input.occurredAt,
        occurredTime: input.occurredTime,
        title: input.title,
        value: input.value,
        unit: input.unit,
        note: input.note,
        source: 'local',
        payload: input.payload,
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
      );

      // Insert optimistic copy into cache
      await dao.insertOptimistic(
        input.occurredAt.substring(0, 10),
        jsonEncode(optimisticItem.toJson()),
      );

      try {
        // Attempt remote create
        final remote = await dataSource.create(input);

        // Replace optimistic copy with confirmed server response
        await dao.confirmSync(tempId, jsonEncode(remote.toJson()));

        return remote;
      } on DioException catch (e) {
        // Network failed — enqueue pending sync (best-effort) then Left. The
        // optimistic copy stays in the cache for offline display.
        await _enqueueWriteFailure(
          e,
          operation: 'create',
          entityId: tempId,
          payload: jsonEncode(optimisticItem.toJson()),
        );
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) {
    return TaskEither.tryCatch(() async {
      try {
        final remote = await dataSource.update(id, input);
        // Update cache with the confirmed response
        await dao.updateData(id, jsonEncode(remote.toJson()));
        return remote;
      } on DioException catch (e) {
        await _enqueueWriteFailure(e, operation: 'update', entityId: id);
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> delete(String id) {
    return TaskEither.tryCatch(() async {
      try {
        await dataSource.delete(id);
        await dao.deleteById(id);
      } on DioException catch (e) {
        await _enqueueWriteFailure(e, operation: 'delete', entityId: id);
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Enqueues a failed write operation into the pending sync queue.
  ///
  /// Enqueueing is best-effort: if the local DB write fails, the failure is
  /// only logged and the original network failure is still surfaced as a Left.
  Future<void> _enqueueWriteFailure(
    DioException e, {
    required String operation,
    required String entityId,
    String? payload,
  }) async {
    appLog.warning(
      'DailyRecord.$operation: network failed, queuing for sync: $e',
    );

    final psq = pendingSyncDao;
    if (psq == null) return;

    try {
      await psq.enqueue(
        entityType: 'daily_record',
        entityId: entityId,
        operation: operation,
        payload: payload ?? '{"id": "$entityId"}',
      );
      // Trigger a flush attempt (will be a no-op if still offline)
      unawaited(syncWorker?.flush());
    } catch (error, stackTrace) {
      // 入队（本地 DB 写）失败不得掩盖原始网络失败：仅记录日志，仍按原
      // 网络失败映射 Left。
      appLog.error(
        'DailyRecord.$operation enqueue failed, keeping the original network '
        'failure: $error',
        stackTrace,
      );
    }
  }

  void _refreshInBackground(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) {
    final key = '$date:${kind ?? 'all'}';
    final now = DateTime.now();
    final lastAttempt = _lastRefreshAttempt[key];
    if (lastAttempt != null &&
        now.difference(lastAttempt) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefreshAttempt[key] = now;
    // Prune oldest entries to prevent unbounded growth.
    if (_lastRefreshAttempt.length > _kMaxTrackedRefreshKeys) {
      _lastRefreshAttempt.remove(_lastRefreshAttempt.keys.first);
    }

    // Fire and forget — errors are logged, not propagated.
    unawaited(
      Future(() async {
        try {
          final remote = await dataSource.fetchRecords(
            date,
            kind: kind,
            page: page,
            pageSize: pageSize,
          );
          final jsonItems = remote.items
              .map((item) => jsonEncode(item.toJson()))
              .toList();
          await dao.replaceByDate(date, kind: kind, jsonItems: jsonItems);
          // Clear failure counter on success.
          _backgroundRefreshFailures.remove(key);
        } catch (e, st) {
          final failures = (_backgroundRefreshFailures[key] ?? 0) + 1;
          _backgroundRefreshFailures[key] = failures;
          // Prune oldest entries to prevent unbounded growth.
          if (_backgroundRefreshFailures.length > _kMaxTrackedRefreshKeys) {
            _backgroundRefreshFailures.remove(
              _backgroundRefreshFailures.keys.first,
            );
          }
          final message = 'DailyRecord background refresh failed: $e';
          if (failures >= _kBackgroundRefreshFailuresBeforeError) {
            appLog.error(message, st);
          } else {
            appLog.warning(message);
          }
        }
      }),
    );
  }
}
