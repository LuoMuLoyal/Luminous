import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'id.dart';
import 'layout.dart';

/// Surfaces the app knows about. Defaults to an empty catalog so widget tests
/// that never touch composition still build; the composition root overrides it
/// with the real definitions (`lib/app/composition/components/`).
final surfaceCatalogProvider = Provider<SurfaceCatalog>(
  (ref) => SurfaceCatalog(),
  name: 'surfaceCatalog',
);

/// Layout of one surface.
///
/// For now this is always the surface's default layout. The layout store (local
/// cache + backend sync) replaces the read path here without touching the page,
/// which is why `ComponentHost` takes a layout value instead of reading storage
/// itself.
final surfaceLayoutProvider = Provider.family<SurfaceLayout, SurfaceId>(
  (ref, surface) => ref.watch(surfaceCatalogProvider).defaultLayoutOf(surface),
  name: 'surfaceLayout',
);

/// A place that hosts components (a tab page, or the tab chrome itself).
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

/// What a surface can host and what it shows before the user edits anything.
///
/// `available` is the mounting permission (layout ⊆ mount ⊆ catalog);
/// `defaultLayout` is used when the user has no layout of their own — it must be
/// independently usable, because most users never open the editor.
final class SurfaceDefinition {
  const SurfaceDefinition({
    required this.surface,
    required this.available,
    required this.defaultLayout,
  });

  final SurfaceId surface;
  final List<ComponentId> available;
  final SurfaceLayout defaultLayout;
}

/// The set of surfaces the app defines.
final class SurfaceCatalog {
  SurfaceCatalog([Iterable<SurfaceDefinition> definitions = const []]) {
    for (final definition in definitions) {
      _bySurface[definition.surface] = definition;
    }
  }

  final Map<SurfaceId, SurfaceDefinition> _bySurface = {};

  SurfaceDefinition? definitionOf(SurfaceId surface) => _bySurface[surface];

  /// Ids that may be mounted on [surface]; empty when the surface is unknown.
  List<ComponentId> availableOf(SurfaceId surface) =>
      _bySurface[surface]?.available ?? const [];

  /// Default layout of [surface]; an empty layout when the surface is unknown.
  SurfaceLayout defaultLayoutOf(SurfaceId surface) =>
      _bySurface[surface]?.defaultLayout ?? SurfaceLayout.empty;

  Iterable<SurfaceDefinition> get definitions => _bySurface.values;
}
