import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/record/presentation/components/catalog.dart';

/// record 表面的组件目录契约。
///
/// 只装配 record 自己的目录，避免把别的 feature 的注册表一起拉进来。
List<Override> _recordOnlyOverrides() => [
  componentRegistryProvider.overrideWithValue(_recordRegistry()),
  surfaceCatalogProvider.overrideWithValue(
    SurfaceCatalog([recordSurfaceDefinition]),
  ),
];

ComponentRegistry _recordRegistry() {
  final registry = ComponentRegistry();
  registerRecordComponents(registry);
  return registry;
}

void main() {
  test('registers every record component by a domain.view id', () {
    final registry = _recordRegistry();
    for (final placement in recordSurfaceDefinition.defaultLayout.placements) {
      expect(
        registry.contains(placement.id),
        isTrue,
        reason: '${placement.id} 出现在默认布局里却没有注册',
      );
    }
    expect(registry.length, recordSurfaceDefinition.owned.length);
  });

  test('component ids never name the record tab', () {
    // id 首段说的是「显示什么」，不是「挂在哪个 tab」——同一个组件要能挂到别的表面。
    for (final id in recordSurfaceDefinition.owned) {
      expect(
        id.value.split('.').first,
        isNot(anyOf('record', 'tab')),
        reason: '${id.value} 的首段不应该是一个 tab 名',
      );
    }
  });

  test('available and default layout agree', () {
    expect(
      recordSurfaceDefinition.defaultLayout.placements
          .map((placement) => placement.id)
          .toList(),
      recordSurfaceDefinition.owned,
      reason: '默认布局应当就是改动前的移动端区块顺序',
    );
  });

  test('registering into a shared registry throws on a duplicate id', () {
    final registry = _recordRegistry();
    expect(
      () => registerRecordComponents(registry),
      throwsA(isA<StateError>()),
    );
  });

  group('surface overrides', () {
    testWidgets('surface catalog resolves record default layout', (
      tester,
    ) async {
      final container = ProviderContainer(overrides: _recordOnlyOverrides());
      addTearDown(container.dispose);

      final catalog = container.read(surfaceCatalogProvider);
      expect(catalog.definitionOf(SurfaceId.record), isNotNull);
      expect(
        catalog.ownedBy(SurfaceId.record),
        recordSurfaceDefinition.owned,
      );
    });
  });
}
