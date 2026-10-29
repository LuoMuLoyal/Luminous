import 'package:drift/drift.dart';

/// Cache table for a page of notifications.
///
/// The inbox renders from this instead of waiting for the network, so opening
/// the list shows the previous page immediately and refreshes in the background.
///
/// [scope] identifies the page (`page=1&size=20`); [data] is the serialized
/// [NotificationPage]. [cachedAt] is only used by retention cleanup — there is
/// no per-row TTL.
class NotificationPageCacheEntries extends Table {
  TextColumn get scope => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}
