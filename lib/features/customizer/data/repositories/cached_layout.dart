import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/mappers/layout_wire.dart';
import 'package:luminous/features/customizer/data/sync/layout_sync_queue.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';
import 'package:luminous/shared/domain/composition/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 布局仓储：cache-first 读取 + 乐观写入 + 离线重放。
///
/// 与仓库其它仓储同构（ADR-0006）：
/// - 读：缓存命中就用，后端拉不到时记录并沿用缓存，不和用户报「没有布局」；
/// - 写：先写缓存（用户立刻看到结果），再推远端；远端失败（非 409）入
///   `pending_sync_queue`，由 `SyncWorker` 在联网后重放。
final class CachedLayoutRepository implements LayoutRepository {
  CachedLayoutRepository({
    required this._cache,
    required this._remote,
    required this._syncQueue,
  });

  final LayoutCache _cache;
  final LayoutRemote _remote;
  final LayoutSyncQueue _syncQueue;
  final LayoutWire _wire = const LayoutWire();

  @override
  TaskEither<LucentFailure, Map<SurfaceId, SurfaceLayout>> readAll() {
    return TaskEither(() async {
      final cached = await _cache.readAll();
      final remote = await _remote.fetchAll().run();

      return remote.match(
        (failure) {
          // 远端不可用：有缓存就用缓存；都没有才把失败交出去，让页面渲染
          // FatalError，而不是伪装成「用户没自定义过布局」。
          if (cached.isNotEmpty) {
            appLog.warning(
              'CachedLayoutRepository.readAll: using cache, remote failed: '
              '${failure.message}',
            );
            return Right<LucentFailure, Map<SurfaceId, SurfaceLayout>>(cached);
          }
          return Left<LucentFailure, Map<SurfaceId, SurfaceLayout>>(failure);
        },
        (docs) {
          final layouts = <SurfaceId, SurfaceLayout>{};
          for (final entry in docs.entries) {
            final layout = _wire.fromDoc(entry.value);
            if (layout == null) continue;
            layouts[entry.key] = layout;
            // 缓存写入失败不影响本次读取（下次拉远端还会覆盖）。
            unawaited(_cache.write(entry.key, layout));
          }
          for (final entry in cached.entries) {
            layouts.putIfAbsent(entry.key, () => entry.value);
          }
          return Right<LucentFailure, Map<SurfaceId, SurfaceLayout>>(layouts);
        },
      );
    });
  }

  @override
  TaskEither<LucentFailure, SurfaceLayout> write(
    SurfaceId surface,
    SurfaceLayout layout, {
    int? ifVersion,
  }) {
    return TaskEither(() async {
      // 乐观写：先落本地，用户点「完成」后立刻看到结果。
      await _cache.write(surface, layout);

      final result = await _remote
          .put(
            surface,
            _wire.encodePayload(layout),
            schemaVersion: layout.schemaVersion,
            ifVersion: ifVersion,
          )
          .run();
      return result.match((failure) {
        // 409：另一台设备先写了。服务端在 `errors.current` 带回当前文档，
        // 采纳它并写回缓存——不重试、不合并、不入队。
        final adopted = _adoptConflict(surface, failure);
        if (adopted != null) {
          appLog.warning(
            'CachedLayoutRepository.write(${surface.wireValue}): '
            'version conflict, adopted server layout',
          );
          return Right<LucentFailure, SurfaceLayout>(adopted);
        }
        // 其余失败：本地已生效，远端等联网后重放。只保留最后一次编辑
        // （同 entityType + entityId 的队列项由 SyncWorker 合并）。
        unawaited(
          _syncQueue.enqueue(
            surface: surface,
            layout: layout,
            ifVersion: ifVersion,
          ),
        );
        appLog.warning(
          'CachedLayoutRepository.write(${surface.wireValue}): '
          'queued for retry, remote failed: ${failure.message}',
        );
        return Right<LucentFailure, SurfaceLayout>(layout);
      }, (_) => Right<LucentFailure, SurfaceLayout>(layout));
    });
  }

  /// 409 `LAYOUT_VERSION_CONFLICT` 时把服务端文档写回缓存并返回它；其余失败返回
  /// `null`。缓存写是异步的，这里 fire-and-forget——下一次 `readAll` 会再拉一次。
  SurfaceLayout? _adoptConflict(SurfaceId surface, LucentFailure failure) {
    if (failure.statusCode != 409) return null;
    final current = failure.errors?['current'];
    final adopted = _wire.fromDoc(current);
    if (adopted == null) return null;
    unawaited(_cache.write(surface, adopted));
    return adopted;
  }
}
