import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/daily_records.dart';

part 'daily_record_dao.g.dart';

/// Data access object for the daily records cache table.
///
/// Implements cache-first patterns:
/// - [fetchByDate] returns cached rows for a date (optionally filtered by kind).
/// - [replaceByDate] replaces all cached rows for a given date with fresh data.
/// - [insertOptimistic] / [confirmSync] / [markPendingSync] manage the
///   optimistic-write lifecycle.
/// - [cleanup] removes rows older than the retention period.
@DriftAccessor(tables: [DailyRecordCacheEntries])
class DailyRecordDao extends DatabaseAccessor<AppDatabase>
    with _$DailyRecordDaoMixin {
  DailyRecordDao(super.db);

  /// Returns cached daily records for [date], optionally filtered by [kind].
  /// Returns an empty list if the cache is empty or expired.
  Future<List<String>> fetchByDate(String date, {String? kind}) async {
    final query = select(dailyRecordCacheEntries)
      ..where((t) => t.recordDate.equals(date));
    if (kind != null) {
      query.where((t) => t.kind.equals(kind));
    }
    final rows = await query.get();
    return rows.map((r) => r.data).toList();
  }

  /// Replaces all cached rows for [date] (optionally filtered by [kind])
  /// with [jsonItems]. Each item is a JSON-serialized DailyRecordItem.
  Future<void> replaceByDate(
    String date, {
    String? kind,
    required List<String> jsonItems,
  }) async {
    await (delete(dailyRecordCacheEntries)
          ..where((t) => t.recordDate.equals(date))
          ..where((t) {
            if (kind != null) {
              return t.kind.equals(kind);
            }
            return const Constant(true);
          }))
        .go();

    if (jsonItems.isEmpty) return;

    final now = DateTime.now();
    await batch((b) {
      b.insertAll(
        dailyRecordCacheEntries,
        jsonItems.map((json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          return DailyRecordCacheEntriesCompanion.insert(
            id: map['id'] as String,
            recordDate: date,
            kind: Value(map['kind'] as String?),
            data: json,
            cachedAt: now,
          );
        }),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Inserts an optimistic local copy. The row is marked with
  /// syncStatus = 'pending' until the server confirms.
  Future<String> insertOptimistic(String date, String jsonItem) async {
    final map = jsonDecode(jsonItem) as Map<String, dynamic>;
    final id = map['id'] as String;
    await into(dailyRecordCacheEntries).insertOnConflictUpdate(
      DailyRecordCacheEntriesCompanion.insert(
        id: id,
        recordDate: date,
        kind: Value(map['kind'] as String?),
        data: jsonItem,
        cachedAt: DateTime.now(),
        syncStatus: const Value('pending'),
      ),
    );
    return id;
  }

  /// Replaces the optimistic copy with the confirmed server response.
  Future<void> confirmSync(String localId, String jsonItem) async {
    final map = jsonDecode(jsonItem) as Map<String, dynamic>;
    await (update(
      dailyRecordCacheEntries,
    )..where((t) => t.id.equals(localId))).write(
      DailyRecordCacheEntriesCompanion(
        id: Value(map['id'] as String),
        data: Value(jsonItem),
        cachedAt: Value(DateTime.now()),
        syncStatus: const Value('synced'),
      ),
    );
  }

  /// Marks a row as pending sync (offline write).
  Future<void> markPendingSync(String id) async {
    await (update(
      dailyRecordCacheEntries,
    )..where((t) => t.id.equals(id))).write(
      const DailyRecordCacheEntriesCompanion(syncStatus: Value('pending')),
    );
  }

  /// Deletes a cached record by ID.
  Future<void> deleteById(String id) async {
    await (delete(dailyRecordCacheEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Updates a cached record's data (e.g. after an edit).
  Future<void> updateData(String id, String jsonItem) async {
    await (update(
      dailyRecordCacheEntries,
    )..where((t) => t.id.equals(id))).write(
      DailyRecordCacheEntriesCompanion(
        data: Value(jsonItem),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Removes all rows older than [olderThan].
  /// Only removes synced rows; pending rows are preserved.
  Future<int> cleanup(DateTime olderThan) async {
    return await (delete(dailyRecordCacheEntries)
          ..where((t) => t.cachedAt.isSmallerThanValue(olderThan))
          ..where((t) => t.syncStatus.equals('synced')))
        .go();
  }

  /// Watches cached rows for [date] as a reactive stream.
  Stream<List<String>> watchByDate(String date, {String? kind}) {
    final query = select(dailyRecordCacheEntries)
      ..where((t) => t.recordDate.equals(date));
    if (kind != null) {
      query.where((t) => t.kind.equals(kind));
    }
    return query.watch().map((rows) => rows.map((r) => r.data).toList());
  }
}
