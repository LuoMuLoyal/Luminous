import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luminous/shared/domain/composition/layout.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

export 'package:luminous/shared/domain/composition/surface.dart';

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
