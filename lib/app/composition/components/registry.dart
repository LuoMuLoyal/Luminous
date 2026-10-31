import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/app/composition/generative/catalog.dart'
    show buildGenerativeCatalog;
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/presentation/providers/layout_store.dart'
    show storedSurfaceLayoutProvider;
import 'package:luminous/features/customizer/presentation/widgets/title/entry.dart'
    show openSurfaceCustomizer;
import 'package:luminous/features/generative/presentation/components/catalog.dart'
    show registerGenerativeComponents;
import 'package:luminous/features/generative/presentation/providers/surface_state.dart'
    show generativeCatalogProvider;
import 'package:luminous/features/medicine/presentation/components/catalog.dart';
import 'package:luminous/features/mine/presentation/components/catalog.dart';
import 'package:luminous/features/record/presentation/components/catalog.dart';
import 'package:luminous/features/review/presentation/components/catalog.dart';
import 'package:luminous/features/today/presentation/components/catalog.dart';

/// Composition root for the component system.
///
/// `lib/core/composition/` defines the mechanisms (ids, layout model, registry,
/// host) but may not import features — that is the layering gate. Registering
/// concrete components therefore happens here, where `app/` is allowed to know
/// both core and features.
///
/// This file is the single aggregation point: each feature owns its own
/// `components/catalog.dart` (registration function + surface definition), and
/// wiring a new surface is one line here. Component implementations never go in
/// this file.
ComponentRegistry buildComponentRegistry() {
  final registry = ComponentRegistry();
  registerTodayComponents(registry);
  registerRecordComponents(registry);
  registerMedicineComponents(registry);
  registerReviewComponents(registry);
  registerMineComponents(registry);
  registerGenerativeComponents(registry);
  return registry;
}

/// Surface definitions for the whole app.
SurfaceCatalog buildSurfaceCatalog() {
  return SurfaceCatalog([
    todaySurfaceDefinition,
    recordSurfaceDefinition,
    medicineSurfaceDefinition,
    reviewSurfaceDefinition,
    mineSurfaceDefinition,
  ]);
}

/// Provider overrides that install the composition root into the app container.
///
/// Two seams are swapped here:
///
/// - **layout**: the static default becomes the stateful store, so every
///   `ComponentHost` renders the user's layout once one is stored and that
///   surface's `defaultLayout` otherwise. Nothing else in the app reads storage.
/// - **customizer entry**: the tab title button routes through an injected
///   action instead of importing the customizer feature, which is what keeps
///   `core/` and the sibling features free of a dependency on it.
/// - **generative catalog**: the empty default becomes the one carrying the
///   domain items (`metric_card` / `trend_chart` / `finding`). `CatalogItem` is
///   a `genui` type, so it may only be constructed here — this override is the
///   whole reason the feature can stay free of the render engine.
List<Override> compositionProviderOverrides() {
  final store = storedSurfaceLayoutProvider;
  final defaultLayout = surfaceLayoutProvider;
  final catalog = generativeCatalogProvider;

  return [
    componentRegistryProvider.overrideWithValue(buildComponentRegistry()),
    surfaceCatalogProvider.overrideWithValue(buildSurfaceCatalog()),
    defaultLayout.overrideWith((ref, surface) => ref.watch(store(surface))),
    surfaceCustomizerOpenerProvider.overrideWithValue(openSurfaceCustomizer),
    // A `family` override replaces the builder for **every** key: the callback
    // receives the key, so one entry covers all surfaces (tab chrome included —
    // it never renders a generative component, and an empty catalog is the
    // correct answer there anyway).
    catalog.overrideWith((ref, surface) => buildGenerativeCatalog(surface)),
  ];
}
