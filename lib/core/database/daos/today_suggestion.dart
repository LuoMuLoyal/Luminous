import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/today_suggestions.dart';

part 'today_suggestion.g.dart';

/// Data access object for the today suggestion cache.
///
/// Stores a single snapshot row with id = 'snapshot'.
/// The full TodaySuggestionBundle (primary + secondary + observations)
/// is serialized as JSON. AI analysis text is NOT cached.
@DriftAccessor(tables: [TodaySuggestionCacheEntries])
class TodaySuggestionDao extends DatabaseAccessor<AppDatabase>
    with _$TodaySuggestionDaoMixin {
  TodaySuggestionDao(super.db);

  static const _snapshotId = 'snapshot';

  /// Returns the cached suggestion bundle JSON, or null if not cached.
  Future<String?> fetch() async {
    final row = await (select(
      todaySuggestionCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).getSingleOrNull();
    return row?.data;
  }

  /// Replaces the cached suggestion bundle.
  Future<void> replace(String jsonData) async {
    await into(todaySuggestionCacheEntries).insertOnConflictUpdate(
      TodaySuggestionCacheEntriesCompanion.insert(
        id: _snapshotId,
        data: jsonData,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Removes the cached snapshot.
  Future<void> clear() async {
    await (delete(
      todaySuggestionCacheEntries,
    )..where((t) => t.id.equals(_snapshotId))).go();
  }
}
