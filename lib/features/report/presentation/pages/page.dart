import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart';
import 'package:share_plus/share_plus.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/ai_summary.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';
import 'package:luminous/features/report/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/report/presentation/widgets/shared/sections.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/presentation/providers/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

DataExportRequestInput? _exportInputForKind(ReportExportKind kind) {
  return reportExportInputForKind(kind);
}

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    final query = ref.read(reportDashboardSelectedQueryProvider);
    ref.invalidate(reportDashboardProvider(query));
    await ref.read(reportDashboardProvider(query).future);
  }

  Future<void> _showRangePicker(
    BuildContext context, {
    required ReportDashboardQuery selectedQuery,
    required WidgetRef ref,
  }) async {
    final selected = await showReportRangePickerDialog(
      context,
      selectedQuery: selectedQuery,
    );
    if (selected != null && selected != selectedQuery) {
      ref
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setQuery(selected);
    }
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
    if (context.mounted) {
      final route = filterType != null
          ? '/record?filter=${Uri.encodeComponent(filterType.name)}'
          : '/record';
      context.push(route);
    }
  }

  Future<void> _handleExportAction(
    BuildContext context,
    WidgetRef ref,
    ReportExportKind kind,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.read(authSessionProvider);
    if (!session.canAccessProtectedData) {
      unawaited(pushAuthRequiredRoute(context, '/report'));
      return;
    }

    // Clinic share: generate a Redis share link and open native share sheet
    if (kind == ReportExportKind.clinicShare) {
      await _handleClinicShare(context, ref, l10n);
      return;
    }

    final controller = ref.read(dataExportControllerProvider.notifier);
    final launcher = ref.read(externalUrlLauncherProvider);

    final result = await runGuarded(
      ref: ref,
      tag: 'ReportPage._handleExportAction',
      action: () => controller.requestExport(_exportInputForKind(kind)!),
    );
    switch (result) {
      case Success(:final value):
        if (!context.mounted) return;
        await _handleExportResult(
          context: context,
          ref: ref,
          launcher: launcher,
          request: value,
        );
      case Failure(:final error):
        if (!context.mounted) return;
        await AppToast.show(
          context,
          '${l10n.reportExportFailedToast}: ${error.message}',
        );
    }
  }

  Future<void> _handleClinicShare(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await runGuarded(
      ref: ref,
      tag: 'ReportPage._handleClinicShare',
      action: () async {
        final reportsApi = ref.read(lucentClientProvider).reports;
        final response = await reportsApi
            .reportsControllerShareClinicSummaryV1();
        final shareUrl = response.shareUrl;
        if (shareUrl.isEmpty) {
          if (context.mounted) {
            await AppToast.show(context, l10n.reportExportFailedToast);
          }
          return false;
        }
        await SharePlus.instance.share(
          ShareParams(
            text: shareUrl,
            subject: l10n.reportExportClinicShareTitle,
          ),
        );
        return true;
      },
    );
    switch (result) {
      case Success():
        // Toast already shown inside action if URL was empty.
        break;
      case Failure(:final error):
        if (!context.mounted) return;
        await AppToast.show(
          context,
          '${l10n.reportExportFailedToast}: ${error.message}',
        );
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
              ? request?.errorMessage ?? ''
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
    final session = ref.watch(authSessionProvider);
    final canAccessProtectedData = session.canAccessProtectedData;
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final selectedDashboardQuery = ref.watch(
      reportDashboardSelectedQueryProvider,
    );

    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(
      reportDashboardProvider(selectedDashboardQuery),
    );

    final pageState = resolvePageViewState<ReportDashboard>(
      session: session,
      data: dashboardAsync,
    );

    return ShellDeferredContent(
      child: PageStateSwitch<ReportDashboard>(
        state: pageState,
        loadingBuilder: () => _buildLoadingShell(
          context: context,
          ref: ref,
          selectedDashboardQuery: selectedDashboardQuery,
        ),
        fatalErrorBuilder: (error) => isDesktop
            ? DesktopTabShell(
                title: l10n.tabReport,
                child: AppStateErrorView(
                  title: l10n.reportErrorTitle,
                  description: l10n.reportErrorDescription,
                  icon: FLucideIcons.chartColumnBig,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  tone: AppStateTone.warning,
                ),
              )
            : FScaffold(
                header: const SafeArea(
                  bottom: false,
                  child: FHeader.nested(prefixes: [AppBackButton()]),
                ),
                child: SafeArea(
                  bottom: false,
                  child: AppStateErrorView(
                    title: l10n.reportErrorTitle,
                    description: l10n.reportErrorDescription,
                    icon: FLucideIcons.chartColumnBig,
                    actionLabel: l10n.todayRetryAction,
                    onAction: () => ref.invalidate(
                      reportDashboardProvider(selectedDashboardQuery),
                    ),
                    tone: AppStateTone.warning,
                  ),
                ),
              ),
        emptyInsufficientBuilder: (empty) => isDesktop
            ? DesktopTabShell(
                title: l10n.tabReport,
                child: AppStateMessageView(
                  title: l10n.stateEmptyDefaultTitle,
                  description: l10n.stateEmptyDefaultDescription,
                  icon: FLucideIcons.chartColumnBig,
                  actionLabel: l10n.todayEmptyAction,
                  onAction: () => context.push('/record/create'),
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(color: colors.background),
                child: SafeArea(
                  bottom: false,
                  child: AppStateMessageView(
                    title: l10n.stateEmptyDefaultTitle,
                    description: l10n.stateEmptyDefaultDescription,
                    icon: FLucideIcons.chartColumnBig,
                    actionLabel: l10n.todayEmptyAction,
                    onAction: () => context.push('/record/create'),
                  ),
                ),
              ),
        readyBuilder: (dashboard, isPreview) => _buildReadyContent(
          context: context,
          ref: ref,
          dashboard: dashboard,
          selectedDashboardQuery: selectedDashboardQuery,
          canAccessProtectedData: canAccessProtectedData,
          isPreview: isPreview,
          onSignIn: () => context.push(loginRouteForCurrentLocation(context)),
        ),
      ),
    );
  }

  Widget _buildLoadingShell({
    required BuildContext context,
    required WidgetRef ref,
    required ReportDashboardQuery selectedDashboardQuery,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final dateRangeLabel = l10n.placeholderLoading;

    return isDesktop
        ? DesktopTabShell(
            title: l10n.tabReport,
            subtitle: Text(dateRangeLabel),
            trailing: [
              ReportPeriodPill(
                range: selectedDashboardQuery.range,
                onTap: () => _showRangePicker(
                  context,
                  selectedQuery: selectedDashboardQuery,
                  ref: ref,
                ),
              ),
            ],
            bottom: ReportActionBar(onGenerate: () {}, onSync: () {}),
            scrollable: false,
            child: const ReportSkeletonView(),
          )
        : _ReportMobileShell(
            isGenerating: false,
            isSyncing: false,
            onGenerate: () {},
            onSync: () {},
            onRefresh: () async {},
            topBar: ReportTopBar(
              dateRangeLabel: dateRangeLabel,
              selectedQuery: selectedDashboardQuery,
              onQueryChanged: (_) {},
              onGenerate: () {},
              onSync: () {},
              isGenerating: false,
              isSyncing: false,
              showActionBar: false,
            ),
            child: const ReportSkeletonView(),
          );
  }

  Widget _buildReadyContent({
    required BuildContext context,
    required WidgetRef ref,
    required ReportDashboard dashboard,
    required ReportDashboardQuery selectedDashboardQuery,
    required bool canAccessProtectedData,
    required bool isPreview,
    required VoidCallback onSignIn,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final aiSummariesEnabled = canAccessProtectedData
        ? ref.watch(
            userSettingsControllerProvider.select(
              (s) => s.asData?.value.aiSummariesEnabled,
            ),
          )
        : null;
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
    final suggestionHistoryAsync = canAccessProtectedData
        ? ref.watch(suggestionHistoryProvider)
        : null;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final suggestionHistory =
        suggestionHistoryAsync?.asData?.value?.items
            .take(3)
            .toList(growable: false) ??
        const <TodaySuggestionHistoryItem>[];

    final dateRangeLabel = reportDashboardDateRangeLabel(
      context,
      dashboard.startDate,
      dashboard.endDate,
    );
    final generatedAtLabel = reportDashboardGeneratedAtLabel(
      context,
      dashboard.generatedAt,
    );

    final dashboardView = ReportDashboardView(
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      dashboardQuery: selectedDashboardQuery,
      onDashboardQueryChanged: (query) {
        ref.read(reportDashboardSelectedQueryProvider.notifier).setQuery(query);
      },
      aiSummaryState: aiSummaryState,
      aiSummaryRange: selectedAiSummaryRange,
      latestExportRequest: latestExportRequest,
      exportRequestInFlight: exportRequestInFlight,
      isPreview: isPreview,
      generatedAtLabel: generatedAtLabel,
      onSignIn: onSignIn,
      onContinueRecord: () => context.push('/record/create'),
      onSync: () => _refreshDashboard(ref),
      suggestionHistory: suggestionHistory,
      isSuggestionHistoryLoading: suggestionHistoryAsync?.isLoading ?? false,
      onSuggestionTap: null,
      onAiSummaryRangeChanged: (range) {
        ref.read(reportAiSummarySelectedRangeProvider.notifier).setRange(range);
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
      onExportActionTap: (kind) => _handleExportAction(context, ref, kind),
      onMetricSelected: (kind) => _openRecordFilter(context, ref, kind),
    );

    if (isDesktop) {
      return DesktopTabShell(
        title: l10n.tabReport,
        subtitle: Text(dateRangeLabel),
        trailing: [
          ReportPeriodPill(
            range: selectedDashboardQuery.range,
            onTap: () => _showRangePicker(
              context,
              selectedQuery: selectedDashboardQuery,
              ref: ref,
            ),
          ),
        ],
        bottom: ReportActionBar(
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
        onRefresh: () => _refreshDashboard(ref),
        scrollStorageKey: 'report-desktop-scroll',
        child: dashboardView,
      );
    }

    return _ReportMobileShell(
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
        showActionBar: false,
      ),
      child: dashboardView,
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
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const PageStorageKey<String>('report-mobile-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              Spacing.level4,
              Spacing.level4,
              Spacing.level4,
              Spacing.level10,
            ),
            children: [
              topBar,
              const SizedBox(height: Spacing.level4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
