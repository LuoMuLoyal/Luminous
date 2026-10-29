import 'package:drift/drift.dart';

/// Cache table for medicine dose logs.
///
/// [logDate] is the scheduled-for date, used for date-range queries.
class MedicineDoseLogCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get logDate => text()();
  TextColumn get currentMedicineId => text().nullable()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
