import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/network/pending_sync_access.dart';

/// 结转的类型别名：展示层经由这里引用队列项与其结构化错误详情，
/// 而不是直接 import `core/database`。
typedef MineSyncEntry = PendingSyncFailure;
typedef MineSyncErrorDetails = PendingSyncErrorView;

/// Permanently failed local sync items, oldest first.
///
/// Backs the sync-failures page. Access goes through
/// `core/providers/pending_sync_access.dart`, which owns the DAO/sync-worker
/// wiring; presentation never touches `core/database` directly.
final mineSyncFailedEntriesProvider = FutureProvider<List<MineSyncEntry>>((
  ref,
) {
  return ref.watch(pendingSyncFailuresProvider.future);
});

/// Mine 页横幅用的失败计数。
final mineSyncFailedCountProvider = FutureProvider<int>((ref) {
  return ref.watch(pendingSyncFailedCountProvider.future);
});

/// 队列动作（重试 / 丢弃）的访问器。
final mineSyncQueueActionsProvider = Provider<MineSyncQueueActions>((ref) {
  return MineSyncQueueActions(ref);
});

class MineSyncQueueActions {
  const MineSyncQueueActions(this._ref);

  final Ref _ref;

  Future<void> retryAll(List<MineSyncEntry> entries) async {
    await _ref
        .read(pendingSyncQueueProvider)
        .retryAll(entries.map((e) => e.id).toList());
    invalidate();
  }

  Future<void> discard(MineSyncEntry entry) async {
    await _ref.read(pendingSyncQueueProvider).discard(entry.id);
    invalidate();
  }

  void invalidate() {
    _ref.invalidate(pendingSyncFailuresProvider);
    _ref.invalidate(pendingSyncFailedCountProvider);
    _ref.invalidate(mineSyncFailedEntriesProvider);
    _ref.invalidate(mineSyncFailedCountProvider);
  }
}
