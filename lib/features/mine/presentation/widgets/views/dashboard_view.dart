import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';

/// The `mine` surface.
///
/// Both form factors render the surface's layout through the component host:
/// the page no longer knows which sections exist, so adding, reordering or
/// re-spanning one never touches this file. Desktop uses
/// [ComponentHostGrid] so the layout's two columns are filled by `compact`
/// cards instead of a hand-written `Row` split that the customizer could never
/// reflow.
class MineDashboardView extends ConsumerWidget {
  const MineDashboardView({super.key, this.isLoading = false});

  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.mine));

    final Widget content = ComponentHostGrid(
      surface: SurfaceId.mine,
      layout: layout,
      rowSpacing: Spacing.xl,
      columnSpacing: Spacing.xl,
    );

    // No entrance animation here: the surrounding transition already brings this
    // view in (page state switch fade-through / tab branch cross-fade), and
    // stacking a second fade + rise on top of it delayed the visible appearance
    // and read as the content drifting upwards.
    return SkeletonScope(isLoading: isLoading, child: content);
  }
}
