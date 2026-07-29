import 'dart:async';

import 'package:dio/dio.dart';
import 'package:luminous/core/database/daos/daily_record_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/record/data/datasources/record.dart';
import 'package:luminous/features/record/data/utils/daily_record_json_codec.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';

/// Cache-first implementation of [DailyRecordRepository].
///
/// Read operations:
/// 1. Return cached data immediately if available.
/// 2. Trigger a background refresh (throttled to 30s).
/// 3. If cache is empty, fetch from network and populate cache.
/// 4. If network fails and cache is empty, throw [AppError].
///
/// Write operations:
/// 1. Insert optimistic local copy with syncStatus = 'pending'.
/// 2. Attempt remote write.
/// 3. On success: replace optimistic copy with confirmed server response.
/// 4. On network failure: enqueue pending sync item, return local copy to UI.
class LucentDailyRecordRepository implements DailyRecordRepository {
  LucentDailyRecordRepository({
    required this.dataSource,
    required this.dao,
    this.pendingSyncDao,
    this.syncWorker,
  });

  final DailyRecordRemoteDataSource dataSource;
  final DailyRecordDao dao;
  final PendingSyncDao? pendingSyncDao;
  final SyncWorker? syncWorker;

  /// Background refresh throttle: 30 seconds per date.
  final Map<String, DateTime> _lastRefreshAttempt = {};

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    // 1. Check cache
    final cachedJson = await dao.fetchByDate(date, kind: kind);
    if (cachedJson.isNotEmpty) {
      final cachedItems = cachedJson
          .map(DailyRecordJsonCodec.itemFromJson)
          .toList(growable: false);

      // Background refresh (non-blocking, throttled)
      _refreshInBackground(date, kind: kind, page: page, pageSize: pageSize);

      return DailyRecordListData(items: cachedItems, total: cachedItems.length);
    }

    // 2. Cache empty → fetch from network
    try {
      final remote = await dataSource.fetchRecords(
        date,
        kind: kind,
        page: page,
        pageSize: pageSize,
      );

      // Write to cache (local scope replacement)
      final jsonItems = remote.items
          .map(DailyRecordJsonCodec.itemToJson)
          .toList();
      await dao.replaceByDate(date, kind: kind, jsonItems: jsonItems);

      return remote;
    } on DioException catch (e) {
      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) {
    // Summary is derived data; no caching needed.
    return dataSource.fetchSummary(date);
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    // For detail view, just fetch from network.
    // Cache lookup by ID would require an index; the list cache
    // already covers the common case (browsing a date).
    return dataSource.get(id);
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) {
    // Image upload is a prerequisite for create/update; no caching.
    return dataSource.uploadImage(input);
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) {
    // AI-generated candidates; not cached.
    return dataSource.generateCandidates(text: text, occurredAt: occurredAt);
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
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
      DailyRecordJsonCodec.itemToJson(optimisticItem),
    );

    try {
      // Attempt remote create
      final remote = await dataSource.create(input);

      // Replace optimistic copy with confirmed server response
      await dao.confirmSync(tempId, DailyRecordJsonCodec.itemToJson(remote));

      return remote;
    } on DioException catch (e) {
      // Network failed — enqueue pending sync
      appTalker.warning(
        'DailyRecord.create: network failed, queuing for sync: $e',
      );

      final psq = pendingSyncDao;
      if (psq != null) {
        await psq.enqueue(
          entityType: 'daily_record',
          entityId: tempId,
          operation: 'create',
          payload: DailyRecordJsonCodec.itemToJson(optimisticItem),
        );
        // Trigger a flush attempt (will be a no-op if still offline)
        unawaited(syncWorker?.flush());
      }

      // Return the optimistic copy so the UI can display it
      return optimisticItem;
    }
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    try {
      final remote = await dataSource.update(id, input);
      // Update cache with the confirmed response
      await dao.updateData(id, DailyRecordJsonCodec.itemToJson(remote));
      return remote;
    } on DioException catch (e) {
      appTalker.warning('DailyRecord.update: network failed: $e');

      final psq = pendingSyncDao;
      if (psq != null) {
        await psq.enqueue(
          entityType: 'daily_record',
          entityId: id,
          operation: 'update',
          payload: '{"id": "$id"}',
        );
        unawaited(syncWorker?.flush());
      }

      throw LucentErrorMapper.toAppError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await dataSource.delete(id);
      await dao.deleteById(id);
    } on DioException catch (e) {
      appTalker.warning('DailyRecord.delete: network failed: $e');

      final psq = pendingSyncDao;
      if (psq != null) {
        await psq.enqueue(
          entityType: 'daily_record',
          entityId: id,
          operation: 'delete',
          payload: '{"id": "$id"}',
        );
        unawaited(syncWorker?.flush());
      }

      throw LucentErrorMapper.toAppError(e);
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
        now.difference(lastAttempt) < const Duration(seconds: 30)) {
      return;
    }
    _lastRefreshAttempt[key] = now;

    // Fire and forget — errors are logged, not propagated
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
              .map(DailyRecordJsonCodec.itemToJson)
              .toList();
          await dao.replaceByDate(date, kind: kind, jsonItems: jsonItems);
        } catch (e) {
          appTalker.warning('DailyRecord background refresh failed: $e');
        }
      }),
    );
  }
}

/// Result type wrapper for cache-first repository operations.
///
/// Per ADR-0008, repository methods should return [Result<T>] instead of
/// throwing. However, the current [DailyRecordRepository] interface still
/// uses `Future<T>`. Full migration to `Result<T>` will happen when the
/// interface is updated. For now, this extension is provided for callers
/// that want to opt into the Result pattern.
extension DailyRecordResultExt on LucentDailyRecordRepository {
  /// Cache-first fetch that returns [Result] instead of throwing.
  Future<Result<DailyRecordListData>> fetchRecordsResult(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final data = await fetchRecords(
        date,
        kind: kind,
        page: page,
        pageSize: pageSize,
      );
      return Result.success(data);
    } on DioException catch (e) {
      return Result.failure(LucentErrorMapper.toAppError(e));
    } catch (e) {
      return Result.failure(AppError(message: '日常记录获取失败', cause: e));
    }
  }
}
