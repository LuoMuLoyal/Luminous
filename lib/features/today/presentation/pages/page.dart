import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/today/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/suggestion_provider.dart';
import 'package:luminous/features/today/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/today/presentation/widgets/views/skeleton_view.dart';

/// Today page.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    ref.invalidate(todayDashboardProvider);
    ref.invalidate(todaySuggestionProvider);
    await Future.wait([
      ref.read(todayDashboardProvider.future),
      ref.read(todaySuggestionProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final colors = context.theme.colors;

    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(todayDashboardProvider);

    final pageState = resolvePageViewState(
      session: session,
      data: dashboardAsync,
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= Breakpoints.desktop;
            final maxWidth = isDesktop
                ? LayoutScaleResolver.resolve(
                    constraints.maxWidth,
                  ).maxContentWidth
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: PageStateSwitch(
                  state: pageState,
                  loadingBuilder: () => const TodaySkeletonView(),
                  fatalErrorBuilder: (error) => TodayErrorView(
                    onRetry: () => ref.invalidate(todayDashboardProvider),
                  ),
                  readyBuilder: (dashboard, isPreview) => TodayDashboardView(
                    dashboard: dashboard,
                    isPreview: isPreview,
                    onSignIn: isPreview
                        ? () => context.push(
                            loginRouteForCurrentLocation(context),
                          )
                        : null,
                    onRefresh: () => _refreshAll(ref),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
