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
    final notifier = ref.read(reportDashboardProvider.notifier);

    return dashboardAsync.when(
      data: (dashboard) => _ReportMobileShell(
        onGenerate: notifier.sync,
        onSync: notifier.sync,
        child: ReportDashboardView(dashboard: dashboard),
      ),
      loading: () => _ReportMobileShell(
        isSyncing: true,
        onGenerate: notifier.sync,
        onSync: notifier.sync,
        child: const ReportDashboardView(
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
              onAction: notifier.sync,
              tone: AppStateTone.warning,
            ),
          ),
        );
      },
    );
  }
}

class _ReportMobileShell extends StatelessWidget {
  const _ReportMobileShell({
    required this.child,
    required this.onGenerate,
    required this.onSync,
    this.isSyncing = false,
  });

  final Widget child;
  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final bool isSyncing;

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
            ReportTopBar(
              isSyncing: isSyncing,
              onGenerate: onGenerate,
              onSync: onSync,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            child,
          ],
        ),
      ),
    );
  }
}
