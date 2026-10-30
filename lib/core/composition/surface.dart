import 'package:flutter/widgets.dart';
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

/// Opens the customizer page for [surface].
///
/// The composition core may not import a feature (layering gate) and the
/// customizer is a feature, so the navigation is **injected**: the composition
/// root installs the real implementation and the tab headers stay
/// surface-agnostic. `null` means this build has no customizer, in which case
/// the title is plain text.
typedef SurfaceCustomizerOpener =
    void Function(BuildContext context, SurfaceId surface);

/// Routing action behind every 「点标题进入编排」 entry.
final surfaceCustomizerOpenerProvider = Provider<SurfaceCustomizerOpener?>(
  (ref) => null,
  name: 'surfaceCustomizerOpener',
);

/// Layout of one surface.
///
/// This is the **default** answer only: the composition root overrides it with
/// the stateful store (`lib/features/customizer/application/layout_store.dart`),
/// which falls back to `SurfaceDefinition.defaultLayout` while nothing is stored
/// and switches to the user's layout once there is one. `ComponentHost` only
/// knows this provider, so pages never read storage themselves.
final surfaceLayoutProvider = Provider.family<SurfaceLayout, SurfaceId>(
  (ref, surface) => ref.watch(surfaceCatalogProvider).defaultLayoutOf(surface),
  name: 'defaultSurfaceLayout',
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
