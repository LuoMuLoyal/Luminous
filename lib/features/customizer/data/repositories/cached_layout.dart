import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/mappers/layout_wire.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 布局仓储：cache-first 读取 + 乐观写入。
///
/// 与仓库其它仓储同构（ADR-0006）：
/// - 读：缓存命中就用，后端拉不到时记录并沿用缓存，不和用户报「没有布局」；
/// - 写：先写缓存（用户立刻看到结果），再推远端，远端失败交给离线队列重放。
final class CachedLayoutRepository implements LayoutRepository {
  CachedLayoutRepository({
    required this._cache,
    required this._remote,
  });

  final LayoutCache _cache;
  final LayoutRemote _remote;
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
          .put(surface, _wire.encodePayload(layout), ifVersion: ifVersion)
          .run();
      return result.match(
        (failure) {
          // 远端失败不回滚本地：用户的选择已经生效，队列会重放。
          appLog.warning(
            'CachedLayoutRepository.write(${surface.wireValue}): '
            'queued for retry, remote failed: ${failure.message}',
          );
          return Right<LucentFailure, SurfaceLayout>(layout);
        },
        (_) => Right<LucentFailure, SurfaceLayout>(layout),
      );
    });
  }
}
