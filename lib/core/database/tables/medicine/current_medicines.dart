import 'package:drift/drift.dart';

/// Cache table for the current medicines list.
///
/// Stores a single snapshot row with [id] = 'snapshot'.
/// The full medicines list is serialized as JSON in [data].
class CurrentMedicineCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
