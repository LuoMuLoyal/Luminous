import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/application/layout_store.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';

import '../helpers/kv_test_store.dart';

const _surface = SurfaceId.today;

const _first = ComponentId('daily.greeting');
const _second = ComponentId('summary.metrics');

final _catalog = SurfaceCatalog(const [
  SurfaceDefinition(
    surface: _surface,
    owned: [_first, _second],
    defaultLayout: SurfaceLayout(
      placements: [
        ComponentPlacement(id: _first),
        ComponentPlacement(id: _second),
      ],
    ),
  ),
]);

/// 只在意「存下来、再读出来还是同一份」——这就是编排结果能不能改变页面的全部前提。
void main() {
  setUp(() => KvTestStore.install());
  tearDown(KvTestStore.reset);

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [surfaceCatalogProvider.overrideWithValue(_catalog)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('no stored layout falls back to the surface default layout', () async {
    final container = createContainer();

    await container.read(surfaceLayoutsProvider.future);

    final layout = container.read(storedSurfaceLayoutProvider(_surface));
    expect(layout.placements.map((p) => p.id), [_first, _second]);
  });

  test('a committed draft is what the surface renders next', () async {
    final container = createContainer();
    await container.read(surfaceLayoutsProvider.future);

    const reordered = SurfaceLayout(
      placements: [
        ComponentPlacement(id: _second, visible: false),
        ComponentPlacement(id: _first),
      ],
    );
    await container
        .read(surfaceLayoutsProvider.notifier)
        .commit(LayoutDraft(surfaces: {_surface: reordered}));

    final layout = container.read(storedSurfaceLayoutProvider(_surface));
    expect(layout.placements.map((p) => p.id), [_second, _first]);
    expect(layout.visiblePlacements.map((p) => p.id), [_first]);
  });

  test('a saved layout survives a restart (read back from the cache)', () async {
    final first = createContainer();
    await first.read(surfaceLayoutsProvider.future);
    await first
        .read(surfaceLayoutsProvider.notifier)
        .commit(
          LayoutDraft(
            surfaces: {
              _surface: const SurfaceLayout(
                placements: [ComponentPlacement(id: _second)],
              ),
            },
          ),
        );

    // 新容器 = 冷启动：KvStore 里已有刚才写下的那一条。
    final restarted = createContainer();
    await restarted.read(surfaceLayoutsProvider.future);

    final layout = restarted.read(storedSurfaceLayoutProvider(_surface));
    expect(layout.placements.map((p) => p.id), [_second]);
  });

  test('a corrupt stored payload falls back to defaults instead of throwing', () async {
    KvTestStore.install(seed: const {'layout.today': 'not json'});
    final container = createContainer();

    await container.read(surfaceLayoutsProvider.future);

    final layout = container.read(storedSurfaceLayoutProvider(_surface));
    expect(layout.placements.map((p) => p.id), [_first, _second]);
  });
}
