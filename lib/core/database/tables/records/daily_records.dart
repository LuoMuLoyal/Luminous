import 'package:drift/drift.dart';

/// Cache table for daily records (symptoms, water, sleep, medication, notes).
///
/// Stores the full JSON-serialized [DailyRecordItem] in the [data] column.
/// The [recordDate] and [kind] columns are indexed for efficient filtering.
/// [cachedAt] is used for TTL-based cache invalidation.
/// [syncStatus] tracks optimistic-write lifecycle.
class DailyRecordCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get recordDate => text()();
  TextColumn get kind => text().nullable()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
