import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/app_log.dart';

import 'descriptor.dart';
import 'layout.dart';
import 'registry.dart';
import 'responsive/grid.dart';
import 'responsive/viewport.dart';
import 'size.dart';
import 'surface.dart';

/// Resolves [layout] into widgets, in order, paired with their column spans.
///
/// Returns only components that are registered **and** have something to show:
/// a descriptor answering `null` means "skip me", so a hidden banner leaves no
/// gap. Unknown ids are logged and skipped — a layout may mention components
/// this client version does not have (server rollout, downgraded build), and it
/// must still render the rest.
List<GridEntry> _resolve({
  required BuildContext context,
  required WidgetRef ref,
  required ComponentRegistry registry,
  required SurfaceId surface,
  required SurfaceLayout layout,
  required ComponentLayout grid,
}) {
  final children = <GridEntry>[];
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
    children.add((widget: child, span: _spanOf(grid, placement, component)));
  }
  return children;
}

/// Column span of [placement], honouring the sizes its descriptor declares.
///
/// A persisted layout may ask for a size the component does not support (an
/// older build wrote `wide`, a newer one made it `compact` only). Falling back to
/// the descriptor's smallest supported size keeps the grid valid instead of
/// overflowing it.
int _spanOf(
  ComponentLayout grid,
  ComponentPlacement placement,
  RegisteredComponent component,
) {
  var size = placement.size;
  if (!component.supportedSizes.contains(size)) {
    size = component.supportedSizes.isEmpty
        ? ComponentSize.regular
        : component.supportedSizes.reduce((a, b) => a.index <= b.index ? a : b);
  }
  return grid.spanOf(size);
}

/// Inserts [spacing] *between* items, never after the last one.
List<Widget> _withSpacing(List<GridEntry> entries, double spacing) {
  if (spacing <= 0 || entries.length < 2) {
    return [for (final entry in entries) entry.widget];
  }
  return [
    for (var index = 0; index < entries.length; index += 1)
      index == entries.length - 1
          ? entries[index].widget
          : Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: entries[index].widget,
            ),
  ];
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

  /// Layout to render.
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
        grid: ComponentLayout.of(context),
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
        grid: ComponentLayout.of(context),
      ),
      spacing,
    );
    return SliverList(delegate: SliverChildListDelegate.fixed(children));
  }
}

/// Multi-column variant of [ComponentHost]: L2/L3 responsiveness.
///
/// Lays the surface out as [ComponentLayout.columns] equal columns and gives each
/// component the span its [ComponentSize] asks for, so one persisted layout
/// describes a phone (1 col), a tablet (2 cols) and a desktop (3 cols) at once.
///
/// A `Wrap` cannot express this: `wide` must take the whole row while two
/// `compact` components share one, and `Wrap` has no notion of spans. The rows are
/// built explicitly by `ResponsiveGrid` instead.
///
/// Box variant — use where the parent is a `Column`/`SingleChildScrollView`.
/// For a `CustomScrollView` use [ComponentHostGridSliver].
class ComponentHostGrid extends ConsumerWidget {
  const ComponentHostGrid({
    super.key,
    required this.surface,
    required this.layout,
    this.rowSpacing = 0,
    this.columnSpacing = 0,
  });

  final SurfaceId surface;
  final SurfaceLayout layout;

  /// Gap between rows. Never applied after the last row.
  final double rowSpacing;

  /// Gap between columns.
  final double columnSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ComponentLayout.of(context);
    final entries = _resolve(
      context: context,
      ref: ref,
      registry: ref.watch(componentRegistryProvider),
      surface: surface,
      layout: layout,
      grid: grid,
    );
    if (entries.isEmpty) return const SizedBox.shrink();

    // A single column is exactly the old vertical list; skipping the grid avoids
    // paying for track solving on the most common (phone) case.
    if (grid.columns == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _withSpacing(entries, rowSpacing),
      );
    }
    return ResponsiveGrid(
      entries: entries,
      columns: grid.columns,
      rowSpacing: rowSpacing,
      columnSpacing: columnSpacing,
    );
  }
}

/// Sliver variant of [ComponentHostGrid].
///
/// A `Column` of rows has no sliver form, so this wraps it in a
/// `SliverToBoxAdapter`. That means the rows are laid out eagerly — the
/// lazy-build guarantee of [ComponentHostSliver] is lost. Accepted deliberately:
/// multi-column surfaces are tablet/desktop only, where the viewport shows most of
/// the content anyway, and a real sliver grid cannot express per-item spans.
///
/// Row heights stay content-sized (`auto` tracks), so the adapter measures the
/// whole grid rather than being given a fixed extent.
class ComponentHostGridSliver extends ConsumerWidget {
  const ComponentHostGridSliver({
    super.key,
    required this.surface,
    required this.layout,
    this.rowSpacing = 0,
    this.columnSpacing = 0,
  });

  final SurfaceId surface;
  final SurfaceLayout layout;
  final double rowSpacing;
  final double columnSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ComponentLayout.of(context);
    final entries = _resolve(
      context: context,
      ref: ref,
      registry: ref.watch(componentRegistryProvider),
      surface: surface,
      layout: layout,
      grid: grid,
    );

    if (grid.columns == 1) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed(
          _withSpacing(entries, rowSpacing),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: entries.isEmpty
          ? const SizedBox.shrink()
          : ResponsiveGrid(
              entries: entries,
              columns: grid.columns,
              rowSpacing: rowSpacing,
              columnSpacing: columnSpacing,
            ),
    );
  }
}
