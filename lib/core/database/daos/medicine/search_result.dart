import 'package:drift/drift.dart';

import '../../database.dart';
import '../../tables/medicine/search_results.dart';

part 'search_result.g.dart';

/// Data access object for the medicine search result cache.
@DriftAccessor(tables: [SearchResultCacheEntries])
class SearchResultDao extends DatabaseAccessor<AppDatabase>
    with _$SearchResultDaoMixin {
  SearchResultDao(super.db);

  /// Returns the cached result JSON for [scope], or null on a cache miss.
  Future<String?> fetch(String scope) async {
    final row = await (select(
      searchResultCacheEntries,
    )..where((t) => t.scope.equals(scope))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached result for [scope].
  Future<void> replace(String scope, String json) async {
    await into(searchResultCacheEntries).insertOnConflictUpdate(
      SearchResultCacheEntriesCompanion.insert(
        scope: scope,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Removes results cached before [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      searchResultCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
