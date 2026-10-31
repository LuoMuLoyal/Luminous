import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/core/composition/composition.dart';

/// Contract checks for the component system.
///
/// These assert the structural properties that make a page "assembled from
/// data" instead of hand-written — the kind that silently regress because
/// nothing fails to compile when they are violated.
///
/// Scope: the `today` surface, which is the one wired in this batch. The
/// cross-surface checks grow with each surface as it is componentized.
void main() {
  /// Ids exempt from the "first segment is never a surface" rule.
  ///
  /// `generative.<surface>` is the one deliberate exception (plan
  /// `2026-10-31-a2ui-generative.md` §7 answer 2): a generated surface is
  /// **per-surface by definition** — its result is stored under
  /// `genui.<surface>.surface` and it is rendered by that surface's own
  /// `GenerativeTransport`. Pretending it is a reusable component would mean
  /// one engine instance serving several pages, and "which page does this
  /// result belong to" would become a runtime question.
  ///
  /// Keeping the id self-describing is the point: `generative.today` tells you
  /// both that it is a generative slot and which surface it belongs to.
  bool isSurfaceScopedGenerativeId(ComponentId id) =>
      id.value.startsWith('generative.');

  group('registry and surfaces', () {
    test('every registered id is well formed and mounted on some surface', () {
      final registry = buildComponentRegistry();
      final catalog = buildSurfaceCatalog();

      // Surface-scoped generative ids are not in any `owned` list: they are
      // mounted by their feature's renderer, not offered in the customizer.
      final mounted = <ComponentId>{
        for (final surface in SurfaceId.values) ...catalog.ownedBy(surface),
      };
      final registered = <ComponentId>{
        for (final component in registry.components) component.id,
      };

      expect(registry.length, greaterThan(0));
      for (final component in registry.components) {
        expect(
          component.id.isValid,
          isTrue,
          reason: 'component id must be domain.view: ${component.id}',
        );
        if (isSurfaceScopedGenerativeId(component.id)) continue;
        expect(
          mounted,
          contains(component.id),
          reason:
              '${component.id} is registered but no surface may mount it — '
              'registration without a mount point is dead code',
        );
      }

      // ...and the reverse: nothing offered in a surface is unregistered.
      for (final id in mounted) {
        expect(
          registered,
          contains(id),
          reason: '$id is offered by a surface but nothing registers it',
        );
      }
    });

    test('a surface default layout only uses ids it may mount', () {
      final catalog = buildSurfaceCatalog();
      for (final definition in catalog.definitions) {
        final available = definition.owned.toSet();
        for (final placement in definition.defaultLayout.placements) {
          expect(
            available,
            contains(placement.id),
            reason:
                '${definition.surface.wireValue} default layout mounts '
                '${placement.id} which is not in its available list',
          );
        }
      }
    });

    test('every available id is registered', () {
      final registry = buildComponentRegistry();
      final catalog = buildSurfaceCatalog();
      for (final definition in catalog.definitions) {
        for (final id in definition.owned) {
          expect(
            registry.find(id),
            isNotNull,
            reason:
                '${definition.surface.wireValue} offers $id but nothing '
                'registers it',
          );
        }
      }
    });

    test('component ids never encode the surface that hosts them', () {
      final registry = buildComponentRegistry();
      for (final component in registry.components) {
        // Deliberate exception, see [isSurfaceScopedGenerativeId].
        if (isSurfaceScopedGenerativeId(component.id)) continue;
        final domain = component.id.value.split('.').first;
        expect(
          {'today', 'record', 'medicine', 'review', 'mine', 'tab_chrome'},
          isNot(contains(domain)),
          reason:
              '${component.id}: the first segment names what the component '
              'shows, never the surface — otherwise it cannot be mounted twice',
        );
      }
    });

    test('a generative id names exactly one known surface', () {
      final registry = buildComponentRegistry();
      final generative = registry.components.where(
        (c) => isSurfaceScopedGenerativeId(c.id),
      );
      expect(generative, isNotEmpty);

      final wires = {for (final s in SurfaceId.values) s.wireValue};
      for (final component in generative) {
        final parts = component.id.value.split('.');
        expect(parts, hasLength(2), reason: 'expected generative.<surface>');
        expect(
          wires,
          contains(parts[1]),
          reason:
              '${component.id} names a surface that does not exist — a typo '
              'here would register a slot nothing can ever mount',
        );
      }
    });
  });

  group('today surface assembly', () {
    test('the mobile surface renders a host, not a section list', () {
      final source = File(
        'lib/features/today/presentation/widgets/views/mobile_dashboard.dart',
      ).readAsStringSync();
      expect(source.contains('ComponentHostSliver('), isTrue);
      expect(source.contains('/widgets/sections/'), isFalse);
      expect(source.contains('SizedBox.shrink'), isFalse);
    });

    test('the page does not hand-write a widget list', () {
      final page = File(
        'lib/features/today/presentation/pages/page.dart',
      ).readAsStringSync();
      expect(page.contains('<Widget>['), isFalse);
      expect(page.contains('/widgets/sections/'), isFalse);
    });

    test('registered section widgets take no page-injected callbacks', () {
      // A component that needs `onXxx` from the page cannot be mounted on a
      // second surface, because only the originating page knows what the action
      // means.
      const sections = {
        'lib/features/today/presentation/widgets/sections/summary.dart':
            'TodaySummarySection',
        'lib/features/today/presentation/widgets/sections/observation.dart':
            'TodayObservationSection',
        'lib/features/today/presentation/widgets/sections/quick_actions.dart':
            'TodayQuickActionsSection',
        'lib/features/today/presentation/widgets/views/health_event_section.dart':
            'HealthEventSection',
      };
      for (final entry in sections.entries) {
        final source = File(entry.key).readAsStringSync();
        final classStart = source.indexOf('class ${entry.value} ');
        expect(
          classStart,
          greaterThanOrEqualTo(0),
          reason: '${entry.key} no longer declares ${entry.value}',
        );
        // The declaration up to the first `@override` is the constructor and its
        // fields; private inner widgets below it may take callbacks from their
        // parent section.
        final overrideStart = source.indexOf('  @override', classStart);
        final declaration = source.substring(
          classStart,
          overrideStart < 0 ? source.length : overrideStart,
        );
        expect(
          RegExp(r'required this\.on[A-Z]').hasMatch(declaration),
          isFalse,
          reason: '${entry.key} still requires a callback from its page',
        );
      }
    });
  });
}
