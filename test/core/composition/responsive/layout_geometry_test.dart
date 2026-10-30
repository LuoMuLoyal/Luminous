import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';

/// 一行里只有一个子项、且该子项跨 [span] 列时它的宽度。
///
/// 行尾的 `Spacer(flex: columns - span)` 占掉未使用的列。`SizedBox` 间距只插在
/// 相邻子项之间，而 Spacer 是 flex 项、前面没有间距，所以整行宽度按 flex 比例
/// 直接切分：子项宽度 = 行宽 * span / columns。
double _singleItemWidth(
  double total, {
  required int columns,
  required int span,
  required double gap,
}) {
  if (span >= columns) return total;
  return total * span / columns;
}

/// 探针组件的 id 与尺寸档。
const _compactId = ComponentId('probe.compact');
const _regularId = ComponentId('probe.regular');
const _wideId = ComponentId('probe.wide');

/// 一个只画固定高度色块的假组件，便于测量真实几何。
///
/// 不依赖任何 feature/provider：这里验证的是**网格的排版结果**，
/// 与业务组件无关，所以用探针比拉真实 section 更可靠（也不会因为
/// 某张卡没有数据而返回 null，导致测不到）。
class _Probe extends ComponentDescriptor<NoComponentConfig> {
  _Probe(this._id, this._key, this._sizes);

  final ComponentId _id;
  final String _key;
  final Set<ComponentSize> _sizes;

  @override
  ComponentId get id => _id;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => _sizes;

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 撑满格子：网格给每个子项分配的是精确矩形，探针量到的就是格子本身。
    return Align(
      key: Key(_key),
      alignment: Alignment.topLeft,
      child: const SizedBox(
        height: 40,
        child: ColoredBox(color: Color(0xFF888888)),
      ),
    );
  }
}

List<RegisteredComponent> _registryComponents() {
  final registry = ComponentRegistry();
  registry.registerDescriptor(
    _Probe(_compactId, 'p-compact', const {ComponentSize.compact}),
  );
  registry.registerDescriptor(
    _Probe(_regularId, 'p-regular', const {ComponentSize.regular}),
  );
  registry.registerDescriptor(
    _Probe(_wideId, 'p-wide', const {ComponentSize.wide}),
  );
  return registry.components.toList();
}

/// 渲染一张布局并返回各探针的几何矩形。
Future<Map<String, Rect>> _measure(
  WidgetTester tester, {
  required double width,
  required SurfaceLayout layout,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final registry = ComponentRegistry(_registryComponents());

  await tester.pumpWidget(
    ProviderScope(
      overrides: [componentRegistryProvider.overrideWithValue(registry)],
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: ComponentHostGrid(
                surface: SurfaceId.today,
                layout: layout,
                rowSpacing: 12,
                columnSpacing: 12,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final rects = <String, Rect>{};
  for (final key in ['p-compact', 'p-regular', 'p-wide']) {
    final finder = find.byKey(Key(key));
    if (finder.evaluate().isEmpty) continue;
    rects[key] = tester.getRect(finder);
  }
  return rects;
}

void main() {
  // compact + regular + wide，覆盖三档。
  const layout = SurfaceLayout(
    placements: [
      ComponentPlacement(id: _compactId, size: ComponentSize.compact),
      ComponentPlacement(id: _regularId, size: ComponentSize.regular),
      ComponentPlacement(id: _wideId, size: ComponentSize.wide),
    ],
  );

  group('手机宽度（1 列）', () {
    testWidgets('所有组件同宽、纵向堆叠', (tester) async {
      final r = await _measure(tester, width: 400, layout: layout);

      // 单列时每个组件都占满可用宽度（三档在 1 列下都塌缩成 1 格）。
      for (final key in ['p-compact', 'p-regular', 'p-wide']) {
        expect(r[key]!.width, closeTo(400, 0.5), reason: key);
      }

      // 且纵向依次排列（top 严格递增）。
      expect(r['p-regular']!.top, greaterThan(r['p-compact']!.top));
      expect(r['p-wide']!.top, greaterThan(r['p-regular']!.top));

      // 同一行起点，说明没有并排。
      expect(r['p-compact']!.left, closeTo(r['p-regular']!.left, 0.5));
    });
  });

  group('平板宽度（2 列）', () {
    testWidgets('compact 占 1 列、regular 占满 2 列', (tester) async {
      const columns = 2;
      expect(ComponentLayout.tablet.columns, columns);

      // 逐个单独渲染：一次只放一个组件，量到的就是它真实的跨列宽度。
      // 放在同一张表里时自动放置会把它们拼进同一行（那本身是对的），
      // 但会让「跨几列」与「实测宽度」不再一一对应。
      final compact = await _measure(
        tester,
        width: 1000,
        layout: const SurfaceLayout(
          placements: [
            ComponentPlacement(id: _compactId, size: ComponentSize.compact),
          ],
        ),
      );
      expect(
        compact['p-compact']!.width,
        closeTo(_singleItemWidth(1000, columns: columns, span: 1, gap: 12), 1),
      );

      final regular = await _measure(
        tester,
        width: 1000,
        layout: const SurfaceLayout(
          placements: [
            ComponentPlacement(id: _regularId, size: ComponentSize.regular),
          ],
        ),
      );
      // regular 跨满 2 列 → 整行，没有 Spacer。
      expect(
        regular['p-regular']!.width,
        closeTo(_singleItemWidth(1000, columns: columns, span: 2, gap: 12), 1),
      );
    });
  });

  group('桌面宽度（3 列）', () {
    testWidgets('compact=1 列、regular=2 列、wide=3 列', (tester) async {
      const columns = 3;
      expect(ComponentLayout.desktop.columns, columns);

      for (final probe in [
        (_compactId, 'p-compact', 1),
        (_regularId, 'p-regular', 2),
        (_wideId, 'p-wide', 3),
      ]) {
        final (id, key, span) = probe;
        final layout = SurfaceLayout(
          placements: [
            ComponentPlacement(
              id: id,
              size: switch (span) {
                1 => ComponentSize.compact,
                2 => ComponentSize.regular,
                _ => ComponentSize.wide,
              },
            ),
          ],
        );
        final r = await _measure(tester, width: 1440, layout: layout);
        expect(
          r[key]!.width,
          closeTo(
            _singleItemWidth(1440, columns: columns, span: span, gap: 12),
            1,
          ),
          reason: '$key span=$span',
        );
      }
    });

    testWidgets('compact 与 regular 并排在同一行', (tester) async {
      final r = await _measure(tester, width: 1440, layout: layout);

      // compact(1 列) + regular(2 列) = 3 列，正好一行 → top 相同。
      expect(r['p-compact']!.top, closeTo(r['p-regular']!.top, 0.5));
      // regular 紧接在 compact 右侧（中间隔一个 columnSpacing）。
      expect(r['p-regular']!.left, closeTo(r['p-compact']!.right + 12, 0.5));
      // wide(3 列) 独占下一行。
      expect(r['p-wide']!.top, greaterThan(r['p-compact']!.top));
    });
  });

  group('降级与边界', () {
    testWidgets('持久化的尺寸不被组件支持时回退到最小支持档', (tester) async {
      // 组件只支持 compact，但布局里写了 wide（旧版本写入的值）。
      const mismatch = SurfaceLayout(
        placements: [
          ComponentPlacement(id: _compactId, size: ComponentSize.wide),
        ],
      );
      final r = await _measure(tester, width: 1440, layout: mismatch);

      // 回退到 compact → 桌面端只占 1 列，而不是撑满 3 列。
      expect(
        r['p-compact']!.width,
        closeTo(_singleItemWidth(1440, columns: 3, span: 1, gap: 12), 1),
      );
    });

    testWidgets('未注册的 id 被跳过，其余照常渲染', (tester) async {
      const withUnknown = SurfaceLayout(
        placements: [
          ComponentPlacement(id: _compactId, size: ComponentSize.compact),
          ComponentPlacement(id: ComponentId('nope.missing')),
        ],
      );
      final r = await _measure(tester, width: 1440, layout: withUnknown);

      expect(r['p-compact'], isNotNull);
      expect(
        r['p-compact']!.width,
        closeTo(_singleItemWidth(1440, columns: 3, span: 1, gap: 12), 1),
      );
    });

    testWidgets('空布局不渲染任何内容也不崩', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            componentRegistryProvider.overrideWithValue(ComponentRegistry()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1440,
                child: ComponentHostGrid(
                  surface: SurfaceId.today,
                  layout: SurfaceLayout.empty,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
