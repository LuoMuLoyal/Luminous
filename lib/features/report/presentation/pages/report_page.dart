import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/report/data/repositories/mock_report_repository.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/providers/report_ai_summary_provider.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/providers/record_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/providers/report_dashboard_provider.dart';
import 'package:luminous/features/report/presentation/utils/report_ui_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/report_dashboard_view.dart';
import 'package:luminous/features/shell/presentation/shell_deferred_content.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/report/presentation/widgets/report_sections.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';

DataExportRequestInput _exportInputForKind(ReportExportKind kind) {
  return reportExportInputForKind(kind);
}

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    final query = ref.read(reportDashboardSelectedQueryProvider);
    ref.invalidate(reportDashboardProvider(query));
    await ref.read(reportDashboardProvider(query).future);
  }

  void _openRecordFilter(
    BuildContext context,
    WidgetRef ref,
    ReportDataKind kind,
  ) {
    final filterType = switch (kind) {
      ReportDataKind.medication => RecordEntryType.medication,
      ReportDataKind.water => RecordEntryType.water,
      ReportDataKind.sleep => RecordEntryType.sleep,
      ReportDataKind.general => null,
    };
    if (filterType != null) {
      ref.read(selectedRecordFilterProvider.notifier).setFilter(filterType);
    }
    ref.read(shellProvider.notifier).selectTab(1);
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
      final request = await controller.requestExport(_exportInputForKind(kind));
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
    switch (dataExportUiStatusForRequest(request)) {
      case DataExportUiStatus.idle:
        await AppToast.show(context, l10n.reportExportFailedToast);
        return;
      case DataExportUiStatus.completed:
      case DataExportUiStatus.completedLinkMissing:
        final latest = await ref
            .read(dataExportControllerProvider.notifier)
            .refresh();
        if (!context.mounted) {
          return;
        }
        final completedRequest = latest ?? request;
        if (completedRequest == null) {
          await AppToast.show(context, l10n.reportExportFailedToast);
          return;
        }
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
      case DataExportUiStatus.requested:
        await AppToast.show(context, l10n.reportExportRequestedToast);
        return;
      case DataExportUiStatus.processing:
        await AppToast.show(context, l10n.reportExportProcessingToast);
        return;
      case DataExportUiStatus.failed:
      case DataExportUiStatus.unavailable:
        await AppToast.show(
          context,
          request?.errorMessage?.isNotEmpty == true
              ? request!.errorMessage!
              : dataExportUiStatusForRequest(request) ==
                    DataExportUiStatus.unavailable
              ? l10n.reportExportUnavailableToast
              : l10n.reportExportFailedToast,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccessProtectedData = ref.watch(
      authSessionProvider.select((s) => s.canAccessProtectedData),
    );
    final isConfirmedSignedOut = ref.watch(
      authSessionProvider.select((s) => s.isConfirmedSignedOut),
    );
    final aiSummariesEnabled = canAccessProtectedData
        ? ref.watch(
            userSettingsControllerProvider.select(
              (s) => s.asData?.value.aiSummariesEnabled,
            ),
          )
        : null;
    final selectedDashboardQuery = ref.watch(
      reportDashboardSelectedQueryProvider,
    );
    final dashboardAsync = ref.watch(
      reportDashboardProvider(selectedDashboardQuery),
    );
    final selectedAiSummaryRange = ref.watch(
      reportAiSummarySelectedRangeProvider,
    );
    final aiSummaryState = ref.watch(
      reportAiSummaryControllerProvider(selectedAiSummaryRange),
    );
    final latestExportRequest = ref.watch(
      dataExportControllerProvider.select((s) => s.asData?.value),
    );
    final exportRequestInFlight = ref.watch(dataExportRequestInFlightProvider);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;

    final dateRangeLabel = dashboardAsync.when(
      data: (dashboard) => reportDashboardDateRangeLabel(
        context,
        dashboard.startDate,
        dashboard.endDate,
      ),
      loading: () => reportDashboardDateRangeLabel(
        context,
        MockReportRepository.previewDashboard.startDate,
        MockReportRepository.previewDashboard.endDate,
      ),
      error: (_, __) => reportDashboardDateRangeLabel(
        context,
        MockReportRepository.previewDashboard.startDate,
        MockReportRepository.previewDashboard.endDate,
      ),
    );

    return ShellDeferredContent(
      child: dashboardAsync.when(
        data: (dashboard) => isDesktop
            ? _ReportDesktopShell(
                onGenerate: () {
                  ref
                      .read(
                        reportAiSummaryControllerProvider(
                          selectedAiSummaryRange,
                        ).notifier,
                      )
                      .generate();
                },
                onSync: () => _refreshDashboard(ref),
                onRefresh: () => _refreshDashboard(ref),
                isGenerating: aiSummaryState.isLoading,
                isSyncing: false,
                topBar: ReportTopBar(
                  dateRangeLabel: dateRangeLabel,
                  selectedQuery: selectedDashboardQuery,
                  onQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  onGenerate: () {
                    ref
                        .read(
                          reportAiSummaryControllerProvider(
                            selectedAiSummaryRange,
                          ).notifier,
                        )
                        .generate();
                  },
                  onSync: () => _refreshDashboard(ref),
                  isGenerating: aiSummaryState.isLoading,
                  isSyncing: false,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isConfirmedSignedOut) ...[
                      _ReportSignedOutNotice(),
                      const SizedBox(height: AppSpacingTokens.md),
                    ],
                    ReportDashboardView(
                      dashboard: dashboard,
                      canAccessProtectedData: canAccessProtectedData,
                      aiSummariesEnabled: aiSummariesEnabled,
                      dashboardQuery: selectedDashboardQuery,
                      onDashboardQueryChanged: (query) {
                        ref
                            .read(reportDashboardSelectedQueryProvider.notifier)
                            .setQuery(query);
                      },
                      aiSummaryState: aiSummaryState,
                      aiSummaryRange: selectedAiSummaryRange,
                      latestExportRequest: latestExportRequest,
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
                      onMetricSelected: (kind) =>
                          _openRecordFilter(context, ref, kind),
                    ),
                  ],
                ),
              )
            : _ReportMobileShell(
                onGenerate: () {
                  ref
                      .read(
                        reportAiSummaryControllerProvider(
                          selectedAiSummaryRange,
                        ).notifier,
                      )
                      .generate();
                },
                onSync: () => _refreshDashboard(ref),
                onRefresh: () => _refreshDashboard(ref),
                isGenerating: aiSummaryState.isLoading,
                isSyncing: false,
                topBar: ReportTopBar(
                  dateRangeLabel: dateRangeLabel,
                  selectedQuery: selectedDashboardQuery,
                  onQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  onGenerate: () {
                    ref
                        .read(
                          reportAiSummaryControllerProvider(
                            selectedAiSummaryRange,
                          ).notifier,
                        )
                        .generate();
                  },
                  onSync: () => _refreshDashboard(ref),
                  isGenerating: aiSummaryState.isLoading,
                  isSyncing: false,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isConfirmedSignedOut) ...[
                      _ReportSignedOutNotice(),
                      const SizedBox(height: AppSpacingTokens.md),
                    ],
                    ReportDashboardView(
                      dashboard: dashboard,
                      canAccessProtectedData: canAccessProtectedData,
                      aiSummariesEnabled: aiSummariesEnabled,
                      dashboardQuery: selectedDashboardQuery,
                      onDashboardQueryChanged: (query) {
                        ref
                            .read(reportDashboardSelectedQueryProvider.notifier)
                            .setQuery(query);
                      },
                      aiSummaryState: aiSummaryState,
                      aiSummaryRange: selectedAiSummaryRange,
                      latestExportRequest: latestExportRequest,
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
                      onMetricSelected: (kind) =>
                          _openRecordFilter(context, ref, kind),
                    ),
                  ],
                ),
              ),
        loading: () => isDesktop
            ? _ReportDesktopShell(
                isGenerating: aiSummaryState.isLoading,
                isSyncing: canAccessProtectedData,
                onGenerate: () => ref.invalidate(
                  reportDashboardProvider(selectedDashboardQuery),
                ),
                onSync: () => ref.invalidate(
                  reportDashboardProvider(selectedDashboardQuery),
                ),
                onRefresh: () => _refreshDashboard(ref),
                topBar: ReportTopBar(
                  dateRangeLabel: dateRangeLabel,
                  selectedQuery: selectedDashboardQuery,
                  onQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  onGenerate: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  onSync: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  isGenerating: aiSummaryState.isLoading,
                  isSyncing: canAccessProtectedData,
                ),
                child: ReportDashboardView(
                  dashboard: MockReportRepository.previewDashboard,
                  canAccessProtectedData: canAccessProtectedData,
                  aiSummariesEnabled: aiSummariesEnabled,
                  isLoading: true,
                  dashboardQuery: selectedDashboardQuery,
                  onDashboardQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  aiSummaryRange: selectedAiSummaryRange,
                  latestExportRequest: latestExportRequest,
                  exportRequestInFlight: exportRequestInFlight,
                  onMetricSelected: (kind) =>
                      _openRecordFilter(context, ref, kind),
                ),
              )
            : _ReportMobileShell(
                isGenerating: aiSummaryState.isLoading,
                isSyncing: canAccessProtectedData,
                onGenerate: () => ref.invalidate(
                  reportDashboardProvider(selectedDashboardQuery),
                ),
                onSync: () => ref.invalidate(
                  reportDashboardProvider(selectedDashboardQuery),
                ),
                onRefresh: () => _refreshDashboard(ref),
                topBar: ReportTopBar(
                  dateRangeLabel: dateRangeLabel,
                  selectedQuery: selectedDashboardQuery,
                  onQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  onGenerate: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  onSync: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  isGenerating: aiSummaryState.isLoading,
                  isSyncing: canAccessProtectedData,
                ),
                child: ReportDashboardView(
                  dashboard: MockReportRepository.previewDashboard,
                  canAccessProtectedData: canAccessProtectedData,
                  aiSummariesEnabled: aiSummariesEnabled,
                  isLoading: true,
                  dashboardQuery: selectedDashboardQuery,
                  onDashboardQueryChanged: (query) {
                    ref
                        .read(reportDashboardSelectedQueryProvider.notifier)
                        .setQuery(query);
                  },
                  aiSummaryRange: selectedAiSummaryRange,
                  latestExportRequest: latestExportRequest,
                  exportRequestInFlight: exportRequestInFlight,
                  onMetricSelected: (kind) =>
                      _openRecordFilter(context, ref, kind),
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
                onAction: () => ref.invalidate(
                  reportDashboardProvider(selectedDashboardQuery),
                ),
                tone: AppStateTone.warning,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportSignedOutNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Container(
      key: const Key('report-signed-out-notice'),
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.authNotSignedIn,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.reportSignedOutInlineHint,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          OutlinedButton(
            key: const Key('report-signed-out-login-action'),
            onPressed: () => pushAuthRequiredRoute(context, '/report'),
            child: Text(l10n.authGoLogin),
          ),
        ],
      ),
    );
  }
}

class _ReportDesktopShell extends StatelessWidget {
  const _ReportDesktopShell({
    required this.child,
    required this.topBar,
    required this.onGenerate,
    required this.onSync,
    required this.onRefresh,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final Widget child;
  final ReportTopBar topBar;
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
            key: const PageStorageKey<String>('report-desktop-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
              AppSpacingTokens.xl,
            ),
            children: [
              topBar,
              const SizedBox(height: AppSpacingTokens.lg),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportMobileShell extends StatelessWidget {
  const _ReportMobileShell({
    required this.child,
    required this.topBar,
    required this.onGenerate,
    required this.onSync,
    required this.onRefresh,
    this.isGenerating = false,
    this.isSyncing = false,
  });

  final Widget child;
  final ReportTopBar topBar;
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
              topBar,
              const SizedBox(height: AppSpacingTokens.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
