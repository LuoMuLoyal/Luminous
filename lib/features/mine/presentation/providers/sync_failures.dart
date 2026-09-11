import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_failures.g.dart';

/// Permanently failed local sync items, oldest first.
///
/// Backs the sync-failures page. The queue is local-only, so this reads the
/// DAO directly; the count shown in the Mine banner comes from
/// `syncFailedCountProvider`, which reads the same table.
@riverpod
Future<List<PendingSyncEntry>> mineSyncFailedEntries(Ref ref) {
  return ref.watch(pendingSyncDaoProvider).fetchPermanentlyFailed();
}
