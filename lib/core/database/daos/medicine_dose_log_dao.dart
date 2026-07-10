import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/medicine_dose_logs.dart';

part 'medicine_dose_log_dao.g.dart';

/// Data access object for the medicine dose logs cache table.
@DriftAccessor(tables: [MedicineDoseLogCacheEntries])
class MedicineDoseLogDao extends DatabaseAccessor<AppDatabase>
    with _$MedicineDoseLogDaoMixin {
  MedicineDoseLogDao(super.db);

  /// Returns cached dose logs for [date].
  Future<List<String>> fetchByDate(String date) async {
    final query = select(medicineDoseLogCacheEntries)
      ..where((t) => t.logDate.equals(date));
    final rows = await query.get();
    return rows.map((r) => r.data).toList();
  }

  /// Replaces all cached dose logs for [date] with [jsonItems].
  Future<void> replaceByDate(String date, List<String> jsonItems) async {
    await (delete(
      medicineDoseLogCacheEntries,
    )..where((t) => t.logDate.equals(date))).go();

    if (jsonItems.isEmpty) return;

    final now = DateTime.now();
    await batch((b) {
      b.insertAll(
        medicineDoseLogCacheEntries,
        jsonItems.map((json) {
          final map = jsonDecode(json) as Map<String, dynamic>;
          return MedicineDoseLogCacheEntriesCompanion.insert(
            id: map['id'] as String,
            logDate: date,
            currentMedicineId: Value(map['currentMedicineId'] as String?),
            data: json,
            cachedAt: now,
          );
        }),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Inserts an optimistic local copy for an offline dose log.
  Future<String> insertOptimistic(String date, String jsonItem) async {
    final map = jsonDecode(jsonItem) as Map<String, dynamic>;
    final id = map['id'] as String;
    await into(medicineDoseLogCacheEntries).insertOnConflictUpdate(
      MedicineDoseLogCacheEntriesCompanion.insert(
        id: id,
        logDate: date,
        currentMedicineId: Value(map['currentMedicineId'] as String?),
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
      medicineDoseLogCacheEntries,
    )..where((t) => t.id.equals(localId))).write(
      MedicineDoseLogCacheEntriesCompanion(
        id: Value(map['id'] as String),
        data: Value(jsonItem),
        cachedAt: Value(DateTime.now()),
        syncStatus: const Value('synced'),
      ),
    );
  }

  /// Removes all rows older than [olderThan] (synced only).
  Future<int> cleanup(DateTime olderThan) async {
    return await (delete(medicineDoseLogCacheEntries)
          ..where((t) => t.cachedAt.isSmallerThanValue(olderThan))
          ..where((t) => t.syncStatus.equals('synced')))
        .go();
  }

  /// Watches cached dose logs for [date].
  Stream<List<String>> watchByDate(String date) {
    final query = select(medicineDoseLogCacheEntries)
      ..where((t) => t.logDate.equals(date));
    return query.watch().map((rows) => rows.map((r) => r.data).toList());
  }
}
