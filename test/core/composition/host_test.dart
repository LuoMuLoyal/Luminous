import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';

/// Minimal descriptor used by the host tests.
class _Probe extends ComponentDescriptor<NoComponentConfig> {
  _Probe(this.id, {this.shows = true, this.label});

  @override
  final ComponentId id;
  final bool shows;
  final String? label;
  final List<ComponentId> renderLog = [];

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    renderLog.add(id);
    if (!shows) return null;
    return Text(label ?? id.value);
  }
}

Widget _wrap(List<Override> overrides, Widget child) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('ComponentHost', () {
    testWidgets('renders placements in layout order', (tester) async {
      final first = _Probe(const ComponentId('a.first'), label: 'first');
      final second = _Probe(const ComponentId('b.second'), label: 'second');
      final registry = ComponentRegistry()
        ..registerDescriptor(first)
        ..registerDescriptor(second);
      const layout = SurfaceLayout(
        placements: [
          ComponentPlacement(id: ComponentId('b.second')),
          ComponentPlacement(id: ComponentId('a.first')),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          [componentRegistryProvider.overrideWithValue(registry)],
          const ComponentHost(surface: SurfaceId.today, layout: layout, spacing: 8),
        ),
      );

      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data)
          .toList();
      expect(texts, ['second', 'first']);
    });

    testWidgets('skips unknown component ids without throwing', (tester) async {
      final registry = ComponentRegistry()
        ..registerDescriptor(_Probe(const ComponentId('a.known'), label: 'known'));
      const layout = SurfaceLayout(
        placements: [
          ComponentPlacement(id: ComponentId('missing.component')),
          ComponentPlacement(id: ComponentId('a.known')),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          [componentRegistryProvider.overrideWithValue(registry)],
          const ComponentHost(surface: SurfaceId.today, layout: layout),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('known'), findsOneWidget);
    });

    testWidgets('a component that renders nothing leaves no gap', (
      tester,
    ) async {
      final registry = ComponentRegistry()
        ..registerDescriptor(_Probe(const ComponentId('a.shown'), label: 'shown'))
        ..registerDescriptor(
          _Probe(const ComponentId('b.hidden'), shows: false),
        )
        ..registerDescriptor(_Probe(const ComponentId('c.shown'), label: 'last'));
      const layout = SurfaceLayout(
        placements: [
          ComponentPlacement(id: ComponentId('a.shown')),
          ComponentPlacement(id: ComponentId('b.hidden')),
          ComponentPlacement(id: ComponentId('c.shown')),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          [componentRegistryProvider.overrideWithValue(registry)],
          const ComponentHost(surface: SurfaceId.today, layout: layout, spacing: 16),
        ),
      );

      // Two visible components, therefore exactly one 16px gap — not two.
      expect(find.byType(Padding), findsOneWidget);
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.only(bottom: 16));
    });

    testWidgets('invisible placements are not built at all', (tester) async {
      final probe = _Probe(const ComponentId('a.hidden'), label: 'hidden');
      final registry = ComponentRegistry()..registerDescriptor(probe);
      const layout = SurfaceLayout(
        placements: [
          ComponentPlacement(id: ComponentId('a.hidden'), visible: false),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          [componentRegistryProvider.overrideWithValue(registry)],
          const ComponentHost(surface: SurfaceId.today, layout: layout),
        ),
      );

      expect(probe.renderLog, isEmpty);
      expect(find.text('hidden'), findsNothing);
    });
  });
}
