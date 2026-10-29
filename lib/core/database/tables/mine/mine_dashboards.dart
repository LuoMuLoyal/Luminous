import 'package:drift/drift.dart';

/// Cache table for the「我的」dashboard.
///
/// The dashboard is assembled from the health-context snapshot, but assembling
/// it still costs a round trip on the first paint. Caching the assembled result
/// lets the tab render immediately and refresh in the background.
///
/// Single row: the dashboard is per-user, and only one user is signed in.
class MineDashboardCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
