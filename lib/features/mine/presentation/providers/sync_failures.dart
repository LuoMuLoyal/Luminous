import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/models/pending_sync_error_details.dart';
import 'package:luminous/core/database/sync/worker.dart';

/// 结转的类型别名：展示层经由这里引用队列项与其结构化错误详情，
/// 而不是直接 import `core/database`。
typedef MineSyncEntry = PendingSyncEntry;
typedef MineSyncErrorDetails = PendingSyncErrorDetails;

/// 本地待同步队列的展示层接缝（mine feature 的组合根）。
///
/// 只有这个文件认识 `core/database` 的 DAO / worker；页面与 widget 通过
/// [MineSyncQueue] 与下面的 provider 取数、重试、丢弃。
class MineSyncQueue {
  const MineSyncQueue(this._ref);

  final Ref _ref;

  /// 永久失败的队列项，最早的在前。
  Future<List<PendingSyncEntry>> permanentlyFailed() {
    return _ref.read(pendingSyncDaoProvider).fetchPermanentlyFailed();
  }

  /// 永久失败项的数量（Mine 页横幅用）。
  Future<int> permanentlyFailedCount() {
    return _ref.read(syncFailedCountProvider.future);
  }

  /// 把所有失败项重新排入队列并触发一次 flush。
  Future<void> retryAll(List<PendingSyncEntry> entries) async {
    final dao = _ref.read(pendingSyncDaoProvider);
    await Future.wait(entries.map((entry) => dao.resetForRetry(entry.id)));
    await _ref.read(syncWorkerProvider).flush();
  }

  /// 从队列里删除一条（服务端持续拒绝时用户的终态动作）。
  Future<void> discard(PendingSyncEntry entry) {
    return _ref.read(pendingSyncDaoProvider).remove(entry.id);
  }

  /// 队列变更后让相关 provider 失效。
  void invalidate() {
    _ref.invalidate(syncFailedCountProvider);
    _ref.invalidate(mineSyncFailedEntriesProvider);
  }
}

/// 队列访问器的 provider。
final mineSyncQueueProvider = Provider<MineSyncQueue>(MineSyncQueue.new);

/// Permanently failed local sync items, oldest first.
///
/// Backs the sync-failures page. The queue is local-only; the count shown in
/// the Mine banner comes from [mineSyncFailedCountProvider], which reads the
/// same table.
final mineSyncFailedEntriesProvider = FutureProvider<List<PendingSyncEntry>>((
  ref,
) {
  return ref.watch(mineSyncQueueProvider).permanentlyFailed();
});

/// Mine 页横幅用的失败计数。
final mineSyncFailedCountProvider = FutureProvider<int>((ref) {
  return ref.watch(mineSyncQueueProvider).permanentlyFailedCount();
});
