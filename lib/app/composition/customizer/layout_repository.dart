import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/repositories/cached_layout.dart';
import 'package:luminous/features/customizer/data/sync/layout_sync_queue.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';

/// 布局仓储的装配点。
///
/// 放在组合根而不是 `customizer/application/`：装配要同时看见 `data/` 实现
/// 与 `core/` 基础设施，而 `application/` 层两样都不允许 import（分层门禁 R3）。
/// application 只声明「需要一个 [LayoutRepository]」，谁来实现由这里决定。
///
/// cache-first 读 + 乐观写 + 离线重放都在实现里；这里只回答「用哪一个实现」。
final layoutRepositoryProvider = Provider<LayoutRepository>((ref) {
  final remote = LucentLayoutRemote(ref.watch(lucentClientProvider));
  final syncWorker = ref.watch(syncWorkerProvider);
  final queue = PendingLayoutSyncQueue(ref.watch(pendingSyncDaoProvider));

  // 重放：联网后把队列里的布局文档推给服务端。`SyncWorker` 负责退避与
  // 永久失败，这里只做一次请求，失败就让它按既有策略重试。
  syncWorker.registerHandler(LayoutSyncQueue.entityType, (entry) async {
    final decoded = decodeLayoutPayload(entry);
    if (decoded == null) return;
    final result = await remote
        .put(
          decoded.surface,
          decoded.payload,
          schemaVersion: decoded.schemaVersion,
          ifVersion: decoded.ifVersion,
        )
        .run();
    // 失败以异常抛出，让 `SyncWorker` 走它的退避/永久失败分支。
    result.fold((failure) => throw failure, (_) {});
  });

  return CachedLayoutRepository(
    cache: LayoutCache(KvStore.instance),
    remote: remote,
    syncQueue: queue,
  );
});
