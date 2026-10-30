import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/application/layout_store.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/features/customizer/presentation/widgets/palette.dart';

import '../helpers/kv_test_store.dart';
import '../helpers/test_forui_app.dart';

/// 组件面板的回归用例。
///
/// 面板自己 `ref.watch` 草稿——**不能**接收调用方传入的快照。窄屏面板长在
/// `showModalBottomSheet` 里，那个 builder 不在页面重建范围内：传快照进来时，
/// 组件进了草稿、面板却按旧数据渲染，「已添加」的条目仍留在列表里，看起来
/// 就是点了没反应。
void main() {
  const surface = SurfaceId.today;
  const greeting = ComponentId('daily.greeting');
  const summary = ComponentId('summary.metrics');
  const fresh = ComponentId('observation.metrics');

  final catalog = SurfaceCatalog(const [
    SurfaceDefinition(
      surface: surface,
      owned: [greeting, summary, fresh],
      defaultLayout: SurfaceLayout(
        placements: [
          ComponentPlacement(id: greeting),
          ComponentPlacement(id: summary),
        ],
      ),
    ),
  ]);

  setUp(() => KvTestStore.install());
  tearDown(KvTestStore.reset);

  /// 建一个已经 `begin()` 过的容器，使面板能读到草稿。
  Future<ProviderContainer> startedContainer(SurfaceCatalog catalog) async {
    final container = ProviderContainer(
      overrides: [surfaceCatalogProvider.overrideWithValue(catalog)],
    );
    addTearDown(container.dispose);
    await container.read(surfaceLayoutsProvider.future);
    await container.read(editSessionProvider.notifier).begin(catalog);
    // autoDispose：无人订阅时 begin() 之后会被回收。
    container.listen(editSessionProvider, (_, _) {});
    return container;
  }

  Future<void> pumpPalette(
    WidgetTester tester,
    ProviderContainer container,
    SurfaceCatalog catalog,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiApp(
          home: Scaffold(
            body: CustomizerPalette(current: surface, catalog: catalog),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists only components that are mountable but not mounted', (
    tester,
  ) async {
    final container = await startedContainer(catalog);
    await pumpPalette(tester, container, catalog);

    // 已挂载的 summary 不出现；未挂载的 fresh 出现一次。
    // `TestForuiApp` 默认中文，组件名走 ARB 的 zh 分支。
    expect(find.text('今日总结'), findsNothing);
    expect(find.text('观察指标'), findsOneWidget);
  });

  testWidgets('adding a component removes it from the list immediately', (
    tester,
  ) async {
    final container = await startedContainer(catalog);
    await pumpPalette(tester, container, catalog);

    expect(find.text('观察指标'), findsOneWidget);

    await tester.tap(find.text('观察指标'));
    await tester.pumpAndSettle();

    // 面板要跟着草稿一起变：加完之后这一条必须消失。
    expect(find.text('观察指标'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a component owned by another surface can be added here', (
    tester,
  ) async {
    const recordOwned = ComponentId('calendar.strip');
    final crossCatalog = SurfaceCatalog(const [
      SurfaceDefinition(
        surface: surface,
        owned: [greeting],
        defaultLayout: SurfaceLayout(
          placements: [ComponentPlacement(id: greeting)],
        ),
      ),
      SurfaceDefinition(
        surface: SurfaceId.record,
        owned: [recordOwned],
        defaultLayout: SurfaceLayout.empty,
      ),
    ]);

    final container = await startedContainer(crossCatalog);
    await pumpPalette(tester, container, crossCatalog);

    // Record 的组件列在 Today 的面板里——这就是跨 tab 复用。
    expect(find.text('日期条'), findsOneWidget);
    await tester.tap(find.text('日期条'));
    await tester.pumpAndSettle();
    expect(find.text('日期条'), findsNothing);
  });
}
