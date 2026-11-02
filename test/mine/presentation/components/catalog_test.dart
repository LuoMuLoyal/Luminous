import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/mine/presentation/components/catalog.dart';

/// Guards the `mine` component catalog in isolation.
///
/// Registration is exercised without the app-wide registry on purpose: this test
/// must fail for `mine` reasons only, not because some other feature's catalog
/// registers a colliding id.
void main() {
  test('registers every component of the surface definition', () {
    final registry = ComponentRegistry();
    registerMineComponents(registry);

    final mounted = mineSurfaceDefinition.defaultLayout.placements
        .map((placement) => placement.id)
        .toList();

    expect(mounted, isNotEmpty);
    for (final id in mounted) {
      expect(registry.contains(id), isTrue, reason: 'not registered: $id');
      expect(
        mineSurfaceDefinition.owned,
        contains(id),
        reason: 'default layout mounts an id the surface cannot host: $id',
      );
    }
    expect(registry.length, mineSurfaceDefinition.owned.length);
  });

  test('component ids are <domain>.<view> and never mention the tab', () {
    final registry = ComponentRegistry();
    registerMineComponents(registry);

    for (final component in registry.components) {
      expect(component.id.isValid, isTrue, reason: component.id.value);
      expect(
        component.id.value.split('.').first,
        isNot('mine'),
        reason: 'ids name what they show, not the surface hosting them',
      );
    }
  });

  test('surface is mine and mounts every default placement', () {
    expect(mineSurfaceDefinition.surface, SurfaceId.mine);
    expect(
      mineSurfaceDefinition.defaultLayout.placements.length,
      mineSurfaceDefinition.owned.length,
    );
  });

  test('provider overrides expose the surface through the catalog', () {
    final catalog = SurfaceCatalog([mineSurfaceDefinition]);
    expect(
      catalog.defaultLayoutOf(SurfaceId.mine).placements.length,
      mineSurfaceDefinition.owned.length,
    );
    expect(catalog.ownedBy(SurfaceId.mine), isNotEmpty);
  });
}
