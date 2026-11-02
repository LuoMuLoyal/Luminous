import 'package:drift/drift.dart';

/// Cache table for report dashboard data.
///
/// Stores JSON-serialized report dashboard DTOs keyed by range + date span.
class ReviewDashboardCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
