import 'package:drift/drift.dart';

import '../../database.dart';
import '../../tables/notification_pages.dart';

part 'notification_page.g.dart';

/// Data access object for the notification page cache.
@DriftAccessor(tables: [NotificationPageCacheEntries])
class NotificationPageDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationPageDaoMixin {
  NotificationPageDao(super.db);

  /// Returns the cached page JSON for [scope], or null on a cache miss.
  Future<String?> fetch(String scope) async {
    final row = await (select(
      notificationPageCacheEntries,
    )..where((t) => t.scope.equals(scope))).getSingleOrNull();
    return row?.data;
  }

  /// Overwrites the cached page for [scope].
  Future<void> replace(String scope, String json) async {
    await into(notificationPageCacheEntries).insertOnConflictUpdate(
      NotificationPageCacheEntriesCompanion.insert(
        scope: scope,
        data: json,
        cachedAt: DateTime.now(),
      ),
    );
  }

  /// Drops every cached page.
  ///
  /// Called after a mutation (read / unread / delete) because a single-item
  /// change invalidates the unread counts and read flags of every page.
  Future<void> invalidateAll() async {
    await delete(notificationPageCacheEntries).go();
  }

  /// Removes pages cached before [cutoff].
  Future<int> cleanup(DateTime cutoff) async {
    return (delete(
      notificationPageCacheEntries,
    )..where((t) => t.cachedAt.isSmallerThanValue(cutoff))).go();
  }
}
