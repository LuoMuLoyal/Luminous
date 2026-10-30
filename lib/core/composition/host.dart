import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/app_log.dart';

import 'layout.dart';
import 'registry.dart';
import 'surface.dart';

/// Resolves [layout] into widgets, in order.
///
/// Returns only components that are registered **and** have something to show:
/// a descriptor answering `null` means "skip me", so a hidden banner leaves no
/// gap. Unknown ids are logged and skipped — a layout may mention components
/// this client version does not have (server rollout, downgraded build), and it
/// must still render the rest.
List<Widget> _resolve({
  required BuildContext context,
  required WidgetRef ref,
  required ComponentRegistry registry,
  required SurfaceId surface,
  required SurfaceLayout layout,
}) {
  final children = <Widget>[];
  for (final placement in layout.visiblePlacements) {
    final component = registry.find(placement.id);
    if (component == null) {
      appLog.warning(
        'ComponentHost(${surface.wireValue}): unknown component ${placement.id}',
      );
      continue;
    }
    final child = component.build(context, ref, placement.config);
    if (child == null) continue;
    children.add(child);
  }
  return children;
}

/// Inserts [spacing] *between* items, never after the last one.
List<Widget> _withSpacing(List<Widget> children, double spacing) {
  if (spacing <= 0 || children.length < 2) return children;
  final spaced = <Widget>[];
  for (var index = 0; index < children.length; index += 1) {
    spaced.add(
      index == children.length - 1
          ? children[index]
          : Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: children[index],
            ),
    );
  }
  return spaced;
}

/// Renders a surface layout inside a `Column`.
///
/// Spacing belongs to the host, not to components: one gap between adjacent
/// components, none after the last. Before this, every conditionally visible
/// section needed a matching `SizedBox.shrink()` placeholder in the page so the
/// gaps stayed correct.
class ComponentHost extends ConsumerWidget {
  const ComponentHost({
    super.key,
    required this.surface,
    required this.layout,
    this.spacing = 0,
  });

  /// Surface whose components are rendered.
  final SurfaceId surface;

  /// Layout to render. Owned by the caller until the layout store lands.
  final SurfaceLayout layout;

  /// Gap between adjacent components; applied by the host, not by components.
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = _withSpacing(
      _resolve(
        context: context,
        ref: ref,
        registry: ref.watch(componentRegistryProvider),
        surface: surface,
        layout: layout,
      ),
      spacing,
    );
    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Sliver variant of [ComponentHost], for scrolling surfaces.
///
/// Kept separate from [ComponentHost] so the page can keep its lazy sliver list
/// (a `Column` inside a `SliverToBoxAdapter` builds and lays out every
/// off-screen card immediately, which is a real cost for provider-heavy cards).
class ComponentHostSliver extends ConsumerWidget {
  const ComponentHostSliver({
    super.key,
    required this.surface,
    required this.layout,
    this.spacing = 0,
  });

  final SurfaceId surface;
  final SurfaceLayout layout;
  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = _withSpacing(
      _resolve(
        context: context,
        ref: ref,
        registry: ref.watch(componentRegistryProvider),
        surface: surface,
        layout: layout,
      ),
      spacing,
    );
    return SliverList(
      delegate: SliverChildListDelegate.fixed(children),
    );
  }
}
