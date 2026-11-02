import 'package:drift/drift.dart';

/// Cache table for the health context snapshot (allergies, conditions, medicines).
///
/// Stores a single snapshot row with [id] = 'snapshot'.
/// The full [HealthContextSnapshot] is serialized as JSON in [data].
class HealthContextCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
