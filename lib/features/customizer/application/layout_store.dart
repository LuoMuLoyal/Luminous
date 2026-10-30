import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/customizer/data/datasources/layout_cache.dart';
import 'package:luminous/features/customizer/data/datasources/layout_remote.dart';
import 'package:luminous/features/customizer/data/repositories/cached_layout.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';

/// 布局仓储的装配点。
///
/// cache-first 读 + 乐观写都在实现里；这里只回答「用哪一个实现」。
final layoutRepositoryProvider = Provider<LayoutRepository>((ref) {
  return CachedLayoutRepository(
    cache: LayoutCache(KvStore.instance),
    remote: const LayoutRemote(),
  );
});

/// 布局的读侧状态：用户的布局叠加在代码内默认布局之上。
///
/// 读的是仓储（缓存优先，见 `CachedLayoutRepository`），所以首帧就有值：
/// 缓存命中即用，未命中就是默认布局——两种情况下页面都不等网络。
///
/// 空 map 与「某 surface 未自定义」是同一件事：surface 缺省即用它的
/// `defaultLayout`。这样「恢复默认」不需要一条特殊记录，删掉记录即可。
final surfaceLayoutsProvider =
    AsyncNotifierProvider<
      SurfaceLayoutsNotifier,
      Map<SurfaceId, SurfaceLayout>
    >(SurfaceLayoutsNotifier.new, name: 'surfaceLayouts');

class SurfaceLayoutsNotifier
    extends AsyncNotifier<Map<SurfaceId, SurfaceLayout>> {
  @override
  Future<Map<SurfaceId, SurfaceLayout>> build() async {
    final result = await ref.watch(layoutRepositoryProvider).readAll().run();
    // 读失败不阻断页面：回退到「没有任何自定义」，页面照默认布局渲染。
    // 仓储在远端失败但本地有缓存时已经返回缓存，这里的失败只剩「连缓存都没有」。
    return result.getOrElse((_) => const {});
  }

  /// 写入草稿并立即更新 UI。
  ///
  /// 先改状态再落盘：用户点「完成」后页面必须马上是新布局，不能等网络往返。
  /// 写失败只记日志（仓储层已处理），不回滚——用户的选择已经生效，缓存也在。
  Future<void> commit(LayoutDraft draft) async {
    final next = <SurfaceId, SurfaceLayout>{
      ...state.value ?? const {},
      ...draft.surfaces,
    };
    state = AsyncData(next);

    final repository = ref.read(layoutRepositoryProvider);
    for (final entry in draft.surfaces.entries) {
      // 返回值就是刚写进去的那份布局，状态已是最新；失败由仓储负责重试。
      await repository.write(entry.key, entry.value).run();
    }
  }
}

/// 某个 surface 当前生效的布局（来自本地缓存 + 用户编排）。
///
/// 读完后由组合根覆盖 `core/composition/surface.dart` 里那个**只返回默认布局**
/// 的同名 provider —— `ComponentHost` 只认后者，所以「用户编排 → 页面重排」
/// 这条链路只有一个开关：存了用户布局就用它，否则用 surface 的默认布局。
final storedSurfaceLayoutProvider = Provider.family<SurfaceLayout, SurfaceId>((
  ref,
  surface,
) {
  final layouts = ref.watch(surfaceLayoutsProvider).value;
  return layouts?[surface] ??
      ref.watch(surfaceCatalogProvider).defaultLayoutOf(surface);
}, name: 'storedSurfaceLayout');
