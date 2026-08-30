import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/reviews.dart';

part 'review.g.dart';

/// Data access object for the review cache table.
///
/// Stores JSON-serialized review payloads (current snapshot + history pages).
/// Implements a cache-first pattern: callers check the cache before hitting
/// the network, and background refreshes update the cache after a successful
/// fetch.
@DriftAccessor(tables: [ReviewCacheEntries])
class ReviewDao extends DatabaseAccessor<AppDatabase> with _$ReviewDaoMixin {
  ReviewDao(super.db);

  static const _currentId = 'current';

  /// Returns the cached current review JSON, or null if not cached.
  Future<String?> fetchCurrent() async {
    final row = await (select(
      reviewCacheEntries,
    )..where((t) => t.id.equals(_currentId))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached current review snapshot.
  Future<void> replaceCurrent(String jsonData) async {
    await into(reviewCacheEntries).insertOnConflictUpdate(
      ReviewCacheEntriesCompanion.insert(
        id: _currentId,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Returns the cached history page JSON for the given key, or null.
  Future<String?> fetchHistory(String cacheKey) async {
    final row = await (select(
      reviewCacheEntries,
    )..where((t) => t.id.equals(cacheKey))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached history page for the given key.
  Future<void> replaceHistory(String cacheKey, String jsonData) async {
    await into(reviewCacheEntries).insertOnConflictUpdate(
      ReviewCacheEntriesCompanion.insert(
        id: cacheKey,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Builds a history cache key from status filter and cursor.
  static String historyKey({String? status, String? cursor}) {
    return 'history:${status ?? 'all'}:${cursor ?? 'start'}';
  }

  /// Removes all cached review data.
  Future<void> clear() async {
    await delete(reviewCacheEntries).go();
  }
}
