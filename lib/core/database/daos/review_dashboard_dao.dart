import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/review_dashboards.dart';

part 'review_dashboard_dao.g.dart';

/// Data access object for the report dashboard cache table.
///
/// Stores JSON-serialized report dashboard DTOs keyed by range + date span.
@DriftAccessor(tables: [ReviewDashboardCacheEntries])
class ReviewDashboardDao extends DatabaseAccessor<AppDatabase>
    with _$ReviewDashboardDaoMixin {
  ReviewDashboardDao(super.db);

  /// Returns the cached dashboard JSON for the given key, or null.
  Future<String?> fetch(String cacheKey) async {
    final row = await (select(
      reviewDashboardCacheEntries,
    )..where((t) => t.id.equals(cacheKey))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached dashboard for the given key.
  Future<void> replace(String cacheKey, String jsonData) async {
    await into(reviewDashboardCacheEntries).insertOnConflictUpdate(
      ReviewDashboardCacheEntriesCompanion.insert(
        id: cacheKey,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Builds a cache key from range and optional date span.
  static String cacheKey({
    required String range,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate?.toIso8601String() ?? 'auto';
    final end = endDate?.toIso8601String() ?? 'auto';
    return 'dashboard:$range:$start:$end';
  }

  /// Removes all cached dashboard data.
  Future<void> clear() async {
    await delete(reviewDashboardCacheEntries).go();
  }
}
