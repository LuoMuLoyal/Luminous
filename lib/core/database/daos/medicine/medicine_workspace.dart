import 'package:drift/drift.dart';

import '../../database.dart';
import '../../tables/medicine_workspaces.dart';

part 'medicine_workspace.g.dart';

/// Data access object for the「用药」workspace cache.
@DriftAccessor(tables: [MedicineWorkspaceCacheEntries])
class MedicineWorkspaceDao extends DatabaseAccessor<AppDatabase>
    with _$MedicineWorkspaceDaoMixin {
  MedicineWorkspaceDao(super.db);

  /// The single-row key: one workspace per signed-in user.
  static const String scope = 'workspace';

  /// Returns the cached workspace JSON, or null on a cache miss.
  Future<String?> fetch() async {
    final row = await (select(
      medicineWorkspaceCacheEntries,
    )..where((t) => t.id.equals(scope))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached workspace.
  Future<void> replace(String json) async {
    await into(medicineWorkspaceCacheEntries).insertOnConflictUpdate(
      MedicineWorkspaceCacheEntriesCompanion.insert(
        id: scope,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Drops the cached workspace.
  Future<void> invalidate() async {
    await (delete(
      medicineWorkspaceCacheEntries,
    )..where((t) => t.id.equals(scope))).go();
  }

  /// Removes the cached workspace when it predates [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      medicineWorkspaceCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
