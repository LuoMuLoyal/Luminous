import 'package:drift/drift.dart';

/// Cache table for today suggestion cards (not AI analysis text).
///
/// Stores a single snapshot row with [id] = 'snapshot'.
/// The full [TodaySuggestionBundle] is serialized as JSON in [data].
class TodaySuggestionCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
