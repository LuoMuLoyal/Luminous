import 'package:drift/drift.dart';

/// Cache table for the「用药」workspace.
///
/// The workspace aggregates reminders, current medicines and dose logs into a
/// single surface. Caching the assembled result lets the tab render immediately
/// and refresh in the background instead of waiting on every source.
///
/// Single row: the workspace is per-user, and only one user is signed in.
class MedicineWorkspaceCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
