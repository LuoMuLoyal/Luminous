import 'package:drift/drift.dart';

import '../../database.dart';
import '../../tables/mine/mine_dashboards.dart';

part 'mine_dashboard.g.dart';

/// Data access object for the「我的」dashboard cache.
@DriftAccessor(tables: [MineDashboardCacheEntries])
class MineDashboardDao extends DatabaseAccessor<AppDatabase>
    with _$MineDashboardDaoMixin {
  MineDashboardDao(super.db);

  /// The single-row key: one dashboard per signed-in user.
  static const String scope = 'mine';

  /// Returns the cached dashboard JSON, or null on a cache miss.
  Future<String?> fetch() async {
    final row = await (select(
      mineDashboardCacheEntries,
    )..where((t) => t.id.equals(scope))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached dashboard.
  Future<void> replace(String json) async {
    await into(mineDashboardCacheEntries).insertOnConflictUpdate(
      MineDashboardCacheEntriesCompanion.insert(
        id: scope,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Drops the cached dashboard.
  Future<void> invalidate() async {
    await (delete(
      mineDashboardCacheEntries,
    )..where((t) => t.id.equals(scope))).go();
  }

  /// Removes the cached dashboard when it predates [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      mineDashboardCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
