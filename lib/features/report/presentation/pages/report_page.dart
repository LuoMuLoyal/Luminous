import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/providers/report_ai_summary_provider.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/widgets/report_dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

DataExportRequestInput _exportInputForKind(ReportExportKind kind) {
  return reportExportInputForKind(kind);
}

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.invalidate(reportDashboardProvider);
    await ref.read(reportDashboardProvider.future);
  }

  Future<void> _handleExportAction(
    BuildContext context,
    WidgetRef ref,
    ReportExportKind kind,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      pushAuthRequiredRoute(context, '/report');
      return;
    }

    final controller = ref.read(dataExportControllerProvider.notifier);
    final launcher = ref.read(externalUrlLauncherProvider);

    try {
      final request = await controller.requestExport(
        _exportInputForKind(kind),
      );
      if (!context.mounted) {
        return;
      }
      await _handleExportResult(
        context: context,
        ref: ref,
        launcher: launcher,
        request: request,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      final message = LucentErrorMapper.fromObject(error).message;
      await AppToast.show(context, '${l10n.reportExportFailedToast}: $message');
    }
  }

  Future<void> _handleExportResult({
    required BuildContext context,
    required WidgetRef ref,
    required ExternalUrlLauncher launcher,
    required DataExportRequestDataDto? request,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (request == null) {
      await AppToast.show(context, l10n.reportExportFailedToast);
      return;
    }

    switch (request.status) {
      case DataExportStatus.completed:
        final latest = await ref
            .read(dataExportControllerProvider.notifier)
            .refresh();
        if (!context.mounted) {
          return;
        }
        final completedRequest = latest ?? request;
        final downloadUrl = completedRequest.downloadUrl;
        if (downloadUrl == null || downloadUrl.isEmpty) {
          await AppToast.show(context, l10n.reportExportLinkMissingToast);
          return;
        }

        final opened = await launcher.open(Uri.parse(downloadUrl));
        if (!context.mounted) {
          return;
        }
        await AppToast.show(
          context,
          opened
              ? l10n.reportExportReadyToast
              : l10n.reportExportOpenFailedToast,
        );
        return;
      case DataExportStatus.requested:
      case DataExportStatus.processing:
        await AppToast.show(context, l10n.mineExportRequested);
        return;
      case DataExportStatus.failed:
      case DataExportStatus.unavailable:
        await AppToast.show(
          context,
          request.errorMessage?.isNotEmpty == true
              ? request.errorMessage!
              : l10n.reportExportFailedToast,
        );
        return;
      case DataExportStatus.unknownDefaultOpenApi:
        await AppToast.show(context, l10n.reportExportFailedToast);
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final dashboardAsync = ref.watch(reportDashboardProvider);
    final selectedAiSummaryRange = ref.watch(
      reportAiSummarySelectedRangeProvider,
    );
    final aiSummaryState = ref.watch(
      reportAiSummaryControllerProvider(selectedAiSummaryRange),
    );
    final exportRequestInFlight = ref.watch(dataExportRequestInFlightProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return dashboardAsync.when(
      data: (dashboard) => _ReportMobileShell(
        onGenerate: () {
          ref
              .read(
                reportAiSummaryControllerProvider(
                  selectedAiSummaryRange,
                ).notifier,
              )
              .generate();
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
              aiSummaryRange: selectedAiSummaryRange,
              exportRequestInFlight: exportRequestInFlight,
              onAiSummaryRangeChanged: (range) {
                ref
                    .read(reportAiSummarySelectedRangeProvider.notifier)
                    .setRange(range);
              },
              onGenerateAiSummary: () async {
                await ref
                    .read(
                      reportAiSummaryControllerProvider(
                        selectedAiSummaryRange,
                      ).notifier,
                    )
                    .generate();
              },
              onExportActionTap: (kind) =>
                  _handleExportAction(context, ref, kind),
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
          aiSummaryRange: selectedAiSummaryRange,
          exportRequestInFlight: exportRequestInFlight,
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
