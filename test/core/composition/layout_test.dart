import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';

void main() {
  group('ComponentId', () {
    test('accepts domain.view shape', () {
      expect(const ComponentId('summary.metrics').isValid, isTrue);
      expect(const ComponentId('dose.risk_overview').isValid, isTrue);
    });

    test('rejects ids without a domain part or with a tab prefix misuse', () {
      expect(const ComponentId('summary').isValid, isFalse);
      expect(const ComponentId('Summary.Metrics').isValid, isFalse);
      expect(const ComponentId('summary.').isValid, isFalse);
      expect(const ComponentId('.metrics').isValid, isFalse);
    });
  });

  group('ComponentRegistry', () {
    test('rejects malformed ids at registration', () {
      final registry = ComponentRegistry();
      expect(
        () => registry.register(
          const RegisteredComponent(
            id: ComponentId('notvalid'),
            supportedSizes: {ComponentSize.regular},
            defaultConfig: {},
            build: _neverBuild,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects duplicate ids', () {
      final registry = ComponentRegistry();
      const component = RegisteredComponent(
        id: ComponentId('a.b'),
        supportedSizes: {ComponentSize.regular},
        defaultConfig: {},
        build: _neverBuild,
      );
      registry.register(component);
      expect(() => registry.register(component), throwsStateError);
    });

    test('unregister makes the id unknown but keeps the registry usable', () {
      final registry = ComponentRegistry()
        ..register(
          const RegisteredComponent(
            id: ComponentId('a.b'),
            supportedSizes: {ComponentSize.regular},
            defaultConfig: {},
            build: _neverBuild,
          ),
        );
      registry.unregister(const ComponentId('a.b'));
      expect(registry.find(const ComponentId('a.b')), isNull);
      expect(registry.length, 0);
    });
  });

  group('SurfaceLayout', () {
    test('round-trips through JSON', () {
      const layout = SurfaceLayout(
        placements: [
          ComponentPlacement(
            id: ComponentId('summary.metrics'),
            size: ComponentSize.wide,
            config: {'metrics': ['water', 'sleep']},
          ),
          ComponentPlacement(
            id: ComponentId('quick_action.strip'),
            visible: false,
          ),
        ],
      );

      final decoded = SurfaceLayout.fromJson(layout.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.placements.length, 2);
      expect(decoded.placements.first.id, const ComponentId('summary.metrics'));
      expect(decoded.placements.first.size, ComponentSize.wide);
      expect(decoded.placements.first.config['metrics'], ['water', 'sleep']);
      expect(decoded.placements.last.visible, isFalse);
      expect(decoded.visiblePlacements.length, 1);
    });

    test('a newer schema version is refused as a whole', () {
      final json = {
        'schemaVersion': SurfaceLayout.currentSchemaVersion + 1,
        'placements': <Object?>[],
      };
      expect(SurfaceLayout.fromJson(json), isNull);
    });

    test('unreadable documents return null instead of throwing', () {
      expect(SurfaceLayout.fromJson(null), isNull);
      expect(SurfaceLayout.fromJson('nonsense'), isNull);
      expect(SurfaceLayout.fromJson({'schemaVersion': 1}), isNull);
    });

    test('individual malformed placements are dropped, not fatal', () {
      final layout = SurfaceLayout.fromJson({
        'schemaVersion': 1,
        'placements': [
          {'id': 'not-an-id'},
          {'size': 'wide'},
          {'id': 'summary.metrics'},
        ],
      });
      expect(layout, isNotNull);
      expect(layout!.placements.length, 1);
      expect(layout.placements.single.id, const ComponentId('summary.metrics'));
    });

    test('unknown size and missing config fall back to defaults', () {
      final layout = SurfaceLayout.fromJson({
        'schemaVersion': 1,
        'placements': [
          {'id': 'summary.metrics', 'size': 'gigantic'},
        ],
      });
      final placement = layout!.placements.single;
      expect(placement.size, ComponentSize.regular);
      expect(placement.config, isEmpty);
    });
  });
}

Widget? _neverBuild(Object? context, Object? ref, Map<String, Object?> config) =>
    null;
