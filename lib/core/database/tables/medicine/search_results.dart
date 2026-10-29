import 'package:drift/drift.dart';

/// Cache table for medicine search results.
///
/// Keyed by the full query shape (source + query + page), so re-running the same
/// search renders instantly and refreshes in the background.
///
/// [scope] is that composite key; [data] is the serialized result list.
/// [cachedAt] is only used by retention cleanup — there is no per-row TTL.
class SearchResultCacheEntries extends Table {
  TextColumn get scope => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}
