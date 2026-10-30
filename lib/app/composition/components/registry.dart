import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/core/composition/composition.dart';
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
List<Override> compositionProviderOverrides() => [
  componentRegistryProvider.overrideWithValue(buildComponentRegistry()),
  surfaceCatalogProvider.overrideWithValue(buildSurfaceCatalog()),
];
