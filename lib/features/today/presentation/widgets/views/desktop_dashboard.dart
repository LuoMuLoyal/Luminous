import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/refresh_indicator.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';

/// Desktop `today` surface: top bar + pull-to-refresh + the surface's layout on a
/// multi-column grid.
///
/// Used to be a hand-written two-pane `Row` (7:5 flex, four hard-coded
/// sections), which meant the desktop arrangement was not composable at all —
/// editing the layout on a phone had no effect here, and the panes were fixed
/// regardless of what the user mounted.
///
/// It now renders the **same** `SurfaceId.today` layout as mobile through
/// [ComponentHostGridSliver]: the desktop gets three columns and each component
/// spans them according to its [ComponentSize]. One persisted layout therefore
/// describes both form factors.
class DesktopTodayDashboard extends ConsumerWidget {
  const DesktopTodayDashboard({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.today));

    return Column(
      children: [
        const TodayTopBar(),
        Expanded(
          child: ForuiRefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              key: const PageStorageKey<String>(
                'today-dashboard-desktop-scroll',
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  // Horizontal padding is provided by DesktopTabShell's content
                  // area. Only add bottom padding for nav bar.
                  padding: const EdgeInsets.only(bottom: Spacing.xl6),
                  sliver: ComponentHostGridSliver(
                    surface: SurfaceId.today,
                    layout: layout,
                    rowSpacing: Spacing.xl2,
                    columnSpacing: Spacing.xl2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
