import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/presentation/providers/report_ai_summary_provider.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/widgets/report_dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(reportDashboardProvider);
    await ref.read(reportDashboardProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final dashboardAsync = ref.watch(reportDashboardProvider);
    final aiSummaryState = ref.watch(reportAiSummaryControllerProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return dashboardAsync.when(
      data: (dashboard) => _ReportMobileShell(
        onGenerate: () {
          ref.read(reportAiSummaryControllerProvider.notifier).generate();
        },
        onSync: () => ref.invalidate(reportDashboardProvider),
        onRefresh: () => _refreshDashboard(ref),
        isGenerating: aiSummaryState.isLoading,
        isSyncing: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.isConfirmedSignedOut) ...[
              _ReportSignedOutNotice(),
              const SizedBox(height: AppSpacingTokens.md),
            ],
            ReportDashboardView(
              dashboard: dashboard,
              authSession: session,
              aiSummaryState: aiSummaryState,
              onGenerateAiSummary: () async {
                await ref.read(reportAiSummaryControllerProvider.notifier).generate();
              },
            ),
          ],
        ),
      ),
      loading: () => _ReportMobileShell(
        isGenerating: aiSummaryState.isLoading,
        isSyncing: session.canAccessProtectedData,
        onGenerate: () => ref.invalidate(reportDashboardProvider),
        onSync: () => ref.invalidate(reportDashboardProvider),
        onRefresh: () => _refreshDashboard(ref),
        child: ReportDashboardView(
          dashboard: MockReportRepository.previewDashboard,
          authSession: session,
          isLoading: true,
        ),
      ),
      error: (error, _) {
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

class _ReportSignedOutNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateMessageView(
      key: const Key('report-signed-out-notice'),
      title: l10n.authNotSignedIn,
      description: l10n.authLoginRequiredPrompt,
      icon: Icons.lock_outline_rounded,
      actionLabel: l10n.authGoLogin,
      actionKey: const Key('report-signed-out-login-action'),
      onAction: () => pushAuthRequiredRoute(context, '/report'),
      tone: AppStateTone.warning,
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
    );
  }
}

class _ReportMobileShell extends StatelessWidget {
  const _ReportMobileShell({
    required this.child,
    required this.onGenerate,
    required this.onSync,
    required this.onRefresh,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final Widget child;
  final VoidCallback onGenerate;
  final VoidCallback onSync;
  final Future<void> Function() onRefresh;
  final bool isGenerating;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const PageStorageKey<String>('report-mobile-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.md,
              AppSpacingTokens.md,
              AppSpacingTokens.md,
              AppSpacingTokens.x5l,
            ),
            children: [
              ReportTopBar(
                isGenerating: isGenerating,
                isSyncing: isSyncing,
                onGenerate: onGenerate,
                onSync: onSync,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
