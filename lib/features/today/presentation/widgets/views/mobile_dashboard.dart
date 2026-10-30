import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/refresh_indicator.dart';
import 'package:luminous/features/today/presentation/widgets/shared/top_bar.dart';

/// Mobile `today` surface: top bar + pull-to-refresh + the surface's layout.
///
/// The page no longer knows which sections exist. It only decides that this is
/// the `today` surface and renders its layout; adding or reordering a component
/// never touches this file.
class MobileTodayDashboard extends ConsumerWidget {
  const MobileTodayDashboard({super.key, required this.onRefresh});

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
              key: const PageStorageKey<String>('today-dashboard-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.lg,
                    Spacing.lg,
                    Spacing.xl6 + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: ComponentHostSliver(
                    surface: SurfaceId.today,
                    layout: layout,
                    spacing: Spacing.lg,
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
