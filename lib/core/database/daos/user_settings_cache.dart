import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/user_settings_cache.dart';

part 'user_settings_cache.g.dart';

/// Data access object for the user settings cache.
@DriftAccessor(tables: [UserSettingsCacheEntries])
class UserSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  /// The single-row key: settings are per signed-in user.
  static const String scope = 'user-settings';

  /// Returns the cached settings JSON, or null on a cache miss.
  Future<String?> fetch() async {
    final row = await (select(
      userSettingsCacheEntries,
    )..where((t) => t.id.equals(scope))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached settings.
  Future<void> replace(String json) async {
    await into(userSettingsCacheEntries).insertOnConflictUpdate(
      UserSettingsCacheEntriesCompanion.insert(
        id: scope,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Drops the cached settings.
  ///
  /// Called after an update so the next read reflects the new values instead of
  /// serving the pre-update copy.
  Future<void> invalidate() async {
    await (delete(
      userSettingsCacheEntries,
    )..where((t) => t.id.equals(scope))).go();
  }

  /// Removes the cached settings when they predate [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      userSettingsCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
