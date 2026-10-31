/// 表面（surface）的纯值类型：稳定标识、作用域声明与默认布局。
///
/// 这些是**数据**，不是渲染：customizer 的 `domain/` 用 surface 与组件 id 做
/// 编排、`data/` 用 layout 做持久化，两者都不该依赖 `lib/core/**`。
/// 渲染宿主与 Riverpod 装配留在 `lib/core/composition/`。
library;

import 'id.dart';
import 'layout.dart';

/// Surfaces the app knows about: the five tabs plus the tab bar itself.
///
/// `tabChrome` shares the layout machinery with the pages: it is "the surface
/// whose components are the bottom tabs", so tab reordering/renaming needs no
/// second model.
enum SurfaceId {
  today,
  record,
  medicine,
  review,
  mine,
  tabChrome;

  /// Value used in persisted layouts and backend payloads.
  String get wireValue => switch (this) {
    SurfaceId.today => 'today',
    SurfaceId.record => 'record',
    SurfaceId.medicine => 'medicine',
    SurfaceId.review => 'review',
    SurfaceId.mine => 'mine',
    SurfaceId.tabChrome => 'tab_chrome',
  };

  static SurfaceId? fromWire(String raw) {
    for (final surface in SurfaceId.values) {
      if (surface.wireValue == raw) return surface;
    }
    return null;
  }
}

/// What a surface owns, and what it shows before the user edits anything.
///
/// `owned` is the set of components the surface's own feature provides. It is
/// **not** a permission list — see [SurfaceCatalog.mountableOn]; it only decides
/// which feature the components come from, and drives the panel grouping.
/// `defaultLayout` is what the surface shows when the user has no layout of their
/// own; it must be independently usable, because most users never open the
/// editor.
final class SurfaceDefinition {
  const SurfaceDefinition({
    required this.surface,
    required this.owned,
    required this.defaultLayout,
  });

  final SurfaceId surface;
  final List<ComponentId> owned;
  final SurfaceLayout defaultLayout;
}

/// The set of surfaces the app defines.
///
/// Pure data (no Riverpod): the provider that exposes it lives with the rest of
/// the composition seams in `lib/core/composition/surface.dart`.
final class SurfaceCatalog {
  SurfaceCatalog([Iterable<SurfaceDefinition> definitions = const []]) {
    for (final definition in definitions) {
      _bySurface[definition.surface] = definition;
    }
  }

  final Map<SurfaceId, SurfaceDefinition> _bySurface = {};

  SurfaceDefinition? definitionOf(SurfaceId surface) => _bySurface[surface];

  /// Ids a surface owns; empty when the surface is unknown.
  ///
  /// Ownership is *not* a permission list — see [mountableOn]. It only says
  /// which feature provides the component, and drives the "by tab" grouping in
  /// the customizer.
  List<ComponentId> ownedBy(SurfaceId surface) =>
      _bySurface[surface]?.owned ?? const [];

  /// Whether [id] may be mounted on [surface].
  ///
  /// **Any component may go on any surface** as long as it is registered. The
  /// component system's whole point is cross-surface reuse (the plan's L3):
  /// putting the dose risk card on Today, the water trend on Record. Ownership
  /// ([ownedBy]) only decides default order and grouping.
  ///
  /// A surface that does not exist cannot host anything, and `tabChrome` is not
  /// a page — neither takes page components.
  bool mountableOn(SurfaceId surface, ComponentId id) {
    if (surface == SurfaceId.tabChrome) return false;
    return _bySurface.containsKey(surface);
  }

  /// Default layout of [surface]; an empty layout when the surface is unknown.
  SurfaceLayout defaultLayoutOf(SurfaceId surface) =>
      _bySurface[surface]?.defaultLayout ?? SurfaceLayout.empty;

  Iterable<SurfaceDefinition> get definitions => _bySurface.values;
}
