import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/composition/customizer/layout_repository.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/repositories/cached_layout.dart';
import 'package:luminous/features/customizer/data/sync/layout_sync_queue.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 测试用的布局远端：不触网，默认「服务端什么都没有」。
///
/// 真实的 `LayoutRemote` 要走 `lucentClientProvider`（Dio + 鉴权拦截器），
/// widget 测试里没有网络就会挂住。凡是驱动编排页的用例都用这个替身覆盖
/// `layoutRepositoryProvider`。
final class FakeLayoutRemote implements LayoutRemote {
  FakeLayoutRemote({this.remoteDocs = const {}, this.onPut});

  /// 服务端已有的布局：`surface → payload JSON 字符串`。
  final Map<SurfaceId, String> remoteDocs;

  /// 每次写入时回调，用于断言「写到了哪个 surface」。
  void Function(SurfaceId surface, String payload, int? ifVersion)? onPut;

  LucentFailure? failure;

  @override
  TaskEither<LucentFailure, Map<SurfaceId, String>> fetchAll() {
    return TaskEither(
      () async => failure != null
          ? Left<LucentFailure, Map<SurfaceId, String>>(failure!)
          : Right<LucentFailure, Map<SurfaceId, String>>(remoteDocs),
    );
  }

  @override
  TaskEither<LucentFailure, int> put(
    SurfaceId surface,
    String payload, {
    required int schemaVersion,
    int? ifVersion,
  }) {
    onPut?.call(surface, payload, ifVersion);
    return TaskEither(
      () async => failure != null
          ? Left<LucentFailure, int>(failure!)
          : const Right<LucentFailure, int>(1),
    );
  }
}

/// 用 [FakeLayoutRemote] 装配的布局仓储覆盖。
///
/// 与生产装配（`lib/app/composition/customizer/layout_repository.dart`）同构，
/// 只是把远端换成替身；缓存仍然走 `KvTestStore`，所以持久化行为是真测的。
Override fakeLayoutRepositoryOverride([FakeLayoutRemote? remote]) {
  return layoutRepositoryProvider.overrideWith((ref) {
    return CachedLayoutRepository(
      cache: LayoutCache(KvStore.instance),
      remote: remote ?? FakeLayoutRemote(),
      syncQueue: LayoutSyncQueue(ref.watch(pendingSyncDaoProvider)),
    );
  });
}

/// 让调用方拿到注入的 [FakeLayoutRemote] 实例，便于断言写入。
FakeLayoutRemote fakeLayoutRemote([FakeLayoutRemote? remote]) =>
    remote ?? FakeLayoutRemote();

/// `LayoutRepository` 的便捷类型别名，避免测试文件重复 import domain。
typedef TestLayoutRepository = LayoutRepository;
