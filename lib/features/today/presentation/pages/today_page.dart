import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/widgets/today_dashboard_view.dart';

/// Today page.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(todayDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? surface.canvas
            : surface.canvasSoft,
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
            final maxWidth = isDesktop
                ? AppLayoutTokens.resolve(constraints.maxWidth).maxContentWidth
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: dashboardAsync.when(
                  data: (dashboard) => TodayDashboardView(dashboard: dashboard),
                  loading: () => const TodayDashboardView(
                    dashboard: MockTodayRepository.previewDashboard,
                    isLoading: true,
                  ),
                  error: (_, __) => TodayErrorView(
                    onRetry: () => ref.invalidate(todayDashboardProvider),
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
