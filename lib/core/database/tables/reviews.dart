import 'package:drift/drift.dart';

/// Cache table for event review data (current review + history pages).
///
/// Stores JSON-serialized review payloads keyed by a logical cache key:
/// - 'current' for the latest event review snapshot
/// - 'history:{status}:{cursor}' for paginated history pages
class ReviewCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
