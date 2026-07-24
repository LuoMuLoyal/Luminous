import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:luminous/core/database/daos/medicine_dose_log_dao.dart';
import 'package:luminous/core/database/daos/pending_sync_dao.dart';
import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/database/sync/sync_worker.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dose_log_cached.g.dart';

/// Cache-first wrapper around [DoseLogRemoteDataSource].
///
/// Read: returns cached dose logs for a date immediately, then background refreshes.
/// If cache is empty, fetches from network and populates cache.
///
/// Write: attempts remote mutation; on success, updates the cache.
/// On network failure ([DioException]), enqueues the HTTP request into the
/// pending sync queue for later replay by [SyncWorker], then rethrows so the
/// UI can show an error.
class CachedDoseLogDataSource {
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

  Future<List<DoseLogItem>> fetchForDate(String date) async {
    // 1. Check cache
    final cachedJson = await dao.fetchByDate(date);
    if (cachedJson.isNotEmpty) {
      final cached = cachedJson.map(_itemFromJson).toList();
      // Background refresh (throttled 60s for dose logs — TTL is 1h)
      _refreshInBackground(date);
      return cached;
    }

    // 2. Cache empty → fetch from network
    final remoteItems = await remote.fetchForDate(date);
    final jsonItems = remoteItems.map(_itemToJson).toList();
    await dao.replaceByDate(date, jsonItems);
    return remoteItems;
  }

  Future<DoseLogItem> create(
    String currentMedicineId,
    String status,
    String date,
  ) async {
    try {
      final result = await remote.create(currentMedicineId, status, date);
      // Refresh cache for this date
      await _refreshCache(date);
      return result;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  Future<DoseLogItem> update(String doseLogId, String status) async {
    try {
      final result = await remote.update(doseLogId, status);
      // Refresh cache for this date (we don't know the date, so skip targeted refresh)
      return result;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
    try {
      final result = await remote.mark(
        currentMedicineId: currentMedicineId,
        status: status,
        date: date,
        reminderId: reminderId,
        scheduledTime: scheduledTime,
      );
      // Refresh cache for this date
      await _refreshCache(date);
      return result;
    } on DioException catch (e) {
      await _enqueueWriteFailure(e);
      throw LucentErrorMapper.toAppError(e);
    }
  }

  /// Enqueues a failed write operation into the pending sync queue.
  ///
  /// The HTTP method, path, and request body are serialized from the
  /// [DioException]'s [RequestOptions]. If the request body contains a
  /// `scheduledFor` field, it is also stored so the replay handler can
  /// refresh the cache for that date after a successful replay.
  Future<void> _enqueueWriteFailure(DioException e) async {
    appTalker.warning('DoseLog write failed, queuing for sync: $e');

    final psq = pendingSyncDao;
    if (psq == null) return;

    await psq.enqueue(
      entityType: 'dose_log',
      operation: 'write',
      payload: _serializeHttpRequest(e.requestOptions),
    );
    unawaited(syncWorker?.flush());
  }

  /// Serializes a [RequestOptions] into a JSON string for the pending sync
  /// queue payload. Extracts `scheduledFor` from the body (if present) for
  /// targeted cache refresh after replay.
  static String _serializeHttpRequest(RequestOptions options) {
    final body = options.data;
    String? date;
    if (body is Map<String, dynamic>) {
      date = body['scheduledFor'] as String?;
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
