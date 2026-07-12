import 'dart:async';
import 'dart:convert';

import 'package:luminous/core/database/daos/medicine_dose_log_dao.dart';
import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';

part 'dose_log_cached.g.dart';

/// Cache-first wrapper around [DoseLogRemoteDataSource].
///
/// Read: returns cached dose logs for a date immediately, then background refreshes.
/// If cache is empty, fetches from network and populates cache.
/// Write: after successful remote mutation, updates the cache.
class CachedDoseLogDataSource {
  CachedDoseLogDataSource({required this.remote, required this.dao});

  final DoseLogRemoteDataSource remote;
  final MedicineDoseLogDao dao;

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
    final result = await remote.create(currentMedicineId, status, date);
    // Refresh cache for this date
    await _refreshCache(date);
    return result;
  }

  Future<DoseLogItem> update(String doseLogId, String status) async {
    final result = await remote.update(doseLogId, status);
    // Refresh cache for this date (we don't know the date, so skip targeted refresh)
    return result;
  }

  Future<DoseLogItem> mark({
    required String currentMedicineId,
    required String status,
    required String date,
    String? reminderId,
    String? scheduledTime,
  }) async {
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
  return CachedDoseLogDataSource(
    remote: ref.watch(doseLogRemoteDataSourceProvider),
    dao: ref.watch(medicineDoseLogDaoProvider),
  );
}
