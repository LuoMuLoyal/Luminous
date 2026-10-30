import 'package:luminous/core/composition/composition.dart';

/// 一次编排会话的草稿。
///
/// 编排页编辑的是草稿，不是线上布局：用户在页面上拖来拖去、开关显隐、跨 tab
/// 搬组件，全部只改草稿；点「完成」才提交并落盘。这样"取消"就是丢弃草稿，
/// 不需要记住反向操作。
///
/// 草稿同时持有**未挂载池**（`pool`）——从某个 surface 移除的组件回到这里，
/// 而不是从世界上消失。用户可以把 risk 组件从 today 拿掉、再放到 mine 上，
/// 这个"中间状态"必须能表达，否则跨 tab 移动就没法只做一次操作。
final class LayoutDraft {
  LayoutDraft({
    required Map<SurfaceId, SurfaceLayout> surfaces,
    Map<SurfaceId, List<ComponentPlacement>>? pool,
  }) : surfaces = Map.unmodifiable(surfaces),
       pool = Map.unmodifiable(pool ?? const {});

  /// 每个 surface 当前的草稿布局。
  final Map<SurfaceId, SurfaceLayout> surfaces;

  /// 每个 surface 的"已移除、可再添加"组件。
  ///
  /// 一个组件被移除后仍属于它原来的 surface（用户重新添加时优先放回原处），
  /// 所以池是按 surface 分组的，而不是一个全局大池。
  final Map<SurfaceId, List<ComponentPlacement>> pool;

  SurfaceLayout layoutOf(SurfaceId surface) =>
      surfaces[surface] ?? SurfaceLayout.empty;

  List<ComponentPlacement> poolOf(SurfaceId surface) => pool[surface] ?? const [];

  LayoutDraft copyWith({
    Map<SurfaceId, SurfaceLayout>? surfaces,
    Map<SurfaceId, List<ComponentPlacement>>? pool,
  }) {
    return LayoutDraft(
      surfaces: surfaces ?? this.surfaces,
      pool: pool ?? this.pool,
    );
  }
}
