import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/sync/layout_sync_queue.dart';
import 'package:luminous/features/shell/data/sync/nav_config_sync.dart';
import 'package:luminous/features/shell/domain/repositories/nav_config_remote.dart';
import 'package:luminous/features/shell/presentation/providers/data_access.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// tab 配置远端同步的装配点。
///
/// 放在组合根：要同时看见 shell 的端口与 customizer 的实现，而
/// `shell/data/` 不许 import `customizer/data/`（`cross_feature_import`）。
/// 组合根本来就是唯一允许「同时看见两边」的地方。
///
/// 与页面布局共用同一个 `/layouts` 端点、同一个 `ui_layout` 离线队列、
/// 同一套 409 语义——只是载荷形状不同（见 `NavConfigSync` 的说明）。
final navConfigSyncProvider = Provider<NavConfigSync>((ref) {
  final remote = LucentLayoutRemote(ref.watch(lucentClientProvider));
  return NavConfigSync(
    remote: _LayoutRemoteToNavConfigPort(remote),
    syncQueue: _LayoutQueueToNavConfigPort(
      PendingLayoutSyncQueue(ref.watch(pendingSyncDaoProvider)),
    ),
    local: ref.watch(navConfigRepositoryProvider),
  );
});

/// 把 [LayoutRemote] 适配成 shell 的窄端口。
final class _LayoutRemoteToNavConfigPort implements NavConfigRemote {
  const _LayoutRemoteToNavConfigPort(this._remote);

  final LayoutRemote _remote;

  @override
  Future<bool> put({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  }) async {
    final result = await _remote
        .put(surface, payload, schemaVersion: schemaVersion)
        .run();
    // 409 与网络失败都返回 false：调用方统一「入队或静默」，
    // 不在这里替它区分——它没有能据此做不同事的信息。
    return result.isRight();
  }

  @override
  Future<({String? payload, LucentFailure? failure})> fetch(
    SurfaceId surface,
  ) async {
    final result = await _remote.fetch(surface).run();
    return result.match(
      (failure) => (payload: null, failure: failure),
      (payload) => (payload: payload, failure: null),
    );
  }
}

/// 把 [LayoutSyncQueue] 适配成 shell 的窄端口。
final class _LayoutQueueToNavConfigPort implements NavConfigSyncQueue {
  const _LayoutQueueToNavConfigPort(this._queue);

  final LayoutSyncQueue _queue;

  @override
  Future<void> enqueue({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  }) {
    return _queue.enqueueRaw(
      surface: surface,
      schemaVersion: schemaVersion,
      payload: payload,
    );
  }
}
