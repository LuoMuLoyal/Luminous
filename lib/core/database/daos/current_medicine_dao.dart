import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/current_medicines.dart';

part 'current_medicine_dao.g.dart';

/// Data access object for the current medicines cache.
///
/// Stores a single snapshot row with id = 'snapshot'.
/// The full medicines list (from HealthContextSnapshot.currentMedicines)
/// is serialized as JSON in the [data] column.
@DriftAccessor(tables: [CurrentMedicineCacheEntries])
class CurrentMedicineDao extends DatabaseAccessor<AppDatabase>
    with _$CurrentMedicineDaoMixin {
  CurrentMedicineDao(super.db);

  static const _snapshotId = 'snapshot';

  /// Returns the cached medicines JSON, or null if not cached.
  Future<String?> fetch() async {
    final row = await (select(
      currentMedicineCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached medicines snapshot.
  Future<void> replace(String jsonData) async {
    await into(currentMedicineCacheEntries).insertOnConflictUpdate(
      CurrentMedicineCacheEntriesCompanion.insert(
        id: _snapshotId,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Removes the cached snapshot.
  Future<void> clear() async {
    await (delete(
      currentMedicineCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).go();
  }
}
