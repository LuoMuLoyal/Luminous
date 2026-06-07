import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/widgets/report_dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(reportDashboardProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return dashboardAsync.when(
      data: (dashboard) =>
          _ReportMobileShell(child: ReportDashboardView(dashboard: dashboard)),
      loading: () => const _ReportMobileShell(
        child: ReportDashboardView(
          dashboard: MockReportRepository.dashboard,
          isLoading: true,
        ),
      ),
      error: (_, __) {
        final l10n = AppLocalizations.of(context)!;

        return DecoratedBox(
          decoration: BoxDecoration(color: surface.canvasSoft),
          child: SafeArea(
            bottom: false,
            child: AppStateErrorView(
              title: l10n.reportErrorTitle,
              description: l10n.reportErrorDescription,
              icon: Icons.bar_chart_rounded,
              actionLabel: l10n.todayRetryAction,
              onAction: () => ref.invalidate(reportDashboardProvider),
              tone: AppStateTone.warning,
            ),
          ),
        );
      },
    );
  }
}

class _ReportMobileShell extends StatelessWidget {
  const _ReportMobileShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const PageStorageKey<String>('report-mobile-scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.x5l,
          ),
          children: [
            const ReportTopBar(),
            const SizedBox(height: AppSpacingTokens.md),
            child,
          ],
        ),
      ),
    );
  }
}
