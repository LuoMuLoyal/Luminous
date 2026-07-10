import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/health_context.dart';

part 'health_context_dao.g.dart';

/// Data access object for the health context cache.
///
/// Stores a single snapshot row with id = 'snapshot'.
/// The full HealthContextSnapshot is serialized as JSON.
@DriftAccessor(tables: [HealthContextCacheEntries])
class HealthContextDao extends DatabaseAccessor<AppDatabase>
    with _$HealthContextDaoMixin {
  HealthContextDao(super.db);

  static const _snapshotId = 'snapshot';

  /// Returns the cached health context JSON, or null if not cached.
  Future<String?> fetch() async {
    final row = await (select(
      healthContextCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached health context snapshot.
  Future<void> replace(String jsonData) async {
    await into(healthContextCacheEntries).insertOnConflictUpdate(
      HealthContextCacheEntriesCompanion.insert(
        id: _snapshotId,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Removes the cached snapshot.
  Future<void> clear() async {
    await (delete(
      healthContextCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).go();
  }
}
