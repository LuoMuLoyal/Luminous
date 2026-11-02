import 'package:drift/drift.dart';

/// Cache table for user privacy/AI settings.
///
/// Settings gate several pages (assistant availability, AI summaries, data
/// sharing), so a cached copy avoids a round trip before those pages can decide
/// what to render.
///
/// Single row: settings are per-user, and only one user is signed in.
class UserSettingsCacheEntries extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
