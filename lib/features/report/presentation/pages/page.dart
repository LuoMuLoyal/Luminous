import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/ai_summary.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';
import 'package:luminous/features/report/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/suggestion_history_detail_sheet.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/report/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/report/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/shell/presentation/desktop_tab_shell.dart';
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

    // Clinic share: show preview dialog first, then share from inside
    if (kind == ReportExportKind.clinicShare) {
      await showClinicSummaryPreviewDialog(context);
      return;
    }

    final input = _exportInputForKind(kind);
    if (input == null) return;

    final controller = ref.read(dataExportControllerProvider.notifier);
    final launcher = ref.read(externalUrlLauncherProvider);

    final result = await runGuarded(
      ref: ref,
      tag: 'ReportPage._handleExportAction',
      action: () => controller.requestExport(input),
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
        await Toast.show(
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
        await Toast.show(context, l10n.reportExportFailedToast);
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
          await Toast.show(context, l10n.reportExportFailedToast);
          return;
        }
        final downloadUrl = completedRequest.downloadUrl;
        if (downloadUrl == null || downloadUrl.isEmpty) {
          await Toast.show(context, l10n.reportExportLinkMissingToast);
          return;
        }

        final opened = await launcher.open(Uri.parse(downloadUrl));
        if (!context.mounted) {
          return;
        }
        await Toast.show(
          context,
          opened
              ? l10n.reportExportReadyToast
              : l10n.reportExportOpenFailedToast,
        );
        return;
      case DataExportUiStatus.requested:
        await Toast.show(context, l10n.reportExportRequestedToast);
        return;
      case DataExportUiStatus.processing:
        await Toast.show(context, l10n.reportExportProcessingToast);
        return;
      case DataExportUiStatus.failed:
      case DataExportUiStatus.unavailable:
        await Toast.show(
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

    // Cache the last successful dashboard so that switching time ranges
    // shows stale data instead of a full skeleton.
    ref.listen<AsyncValue<ReportDashboard>>(
      reportDashboardProvider(selectedDashboardQuery),
      (_, next) {
        next.whenData((dashboard) {
          ref.read(reportLastDashboardProvider.notifier).set(dashboard);
        });
      },
    );
    final cachedDashboard = ref.watch(reportLastDashboardProvider);

    // If the current query is loading without a value, fall back to the
    // cached dashboard so resolvePageViewState shows stale data.
    final effectiveAsync =
        dashboardAsync.isLoading &&
            !dashboardAsync.hasValue &&
            cachedDashboard != null
        ? AsyncValue<ReportDashboard>.data(cachedDashboard)
        : dashboardAsync;

    final pageState = resolvePageViewState<ReportDashboard>(
      session: session,
      data: effectiveAsync,
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
                child: StateErrorView(
                  title: l10n.reportErrorTitle,
                  description: l10n.reportErrorDescription,
                  icon: FLucideIcons.chartColumnBig,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () => ref.invalidate(
                    reportDashboardProvider(selectedDashboardQuery),
                  ),
                  tone: StateTone.warning,
                ),
              )
            : DecoratedBox(
                decoration: BoxDecoration(color: colors.background),
                child: SafeArea(
                  bottom: false,
                  child: StateErrorView(
                    title: l10n.reportErrorTitle,
                    description: l10n.reportErrorDescription,
                    icon: FLucideIcons.chartColumnBig,
                    actionLabel: l10n.todayRetryAction,
                    onAction: () => ref.invalidate(
                      reportDashboardProvider(selectedDashboardQuery),
                    ),
                    tone: StateTone.warning,
                  ),
                ),
              ),
        readyBuilder: (dashboard, isPreview) => _buildReadyContent(
          context: context,
          ref: ref,
          dashboard: dashboard,
          isRefreshing: dashboardAsync.isLoading,
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

    return isDesktop
        ? DesktopTabShell(
            title: l10n.tabReport,
            suffixes: [
              ReportRangeMenu(
                selectedQuery: selectedDashboardQuery,
                onQueryChanged: (query) {
                  ref
                      .read(reportDashboardSelectedQueryProvider.notifier)
                      .setQuery(query);
                },
              ),
            ],
            child: const Expanded(child: ReportSkeletonView()),
          )
        : _ReportMobileShell(
            onRefresh: () async {},
            header: ReportTopBar(
              selectedQuery: selectedDashboardQuery,
              onQueryChanged: (_) {},
            ),
            child: const ReportSkeletonView(),
          );
  }

  Widget _buildReadyContent({
    required BuildContext context,
    required WidgetRef ref,
    required ReportDashboard dashboard,
    required bool isRefreshing,
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
    final clinicShareInFlight = ref.watch(clinicShareInFlightProvider);
    final suggestionHistoryAsync = canAccessProtectedData
        ? ref.watch(suggestionHistoryProvider)
        : null;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final suggestionHistory =
        suggestionHistoryAsync?.asData?.value?.items
            .fold<Map<String, TodaySuggestionHistoryItem>>({}, (map, item) {
              final key = '${item.title}|${item.reason}|${item.type.name}';
              final existing = map[key];
              if (existing == null ||
                  _suggestionLifecycleRank(item.lifecycleState) >
                      _suggestionLifecycleRank(existing.lifecycleState)) {
                map[key] = item;
              }
              return map;
            })
            .values
            .take(3)
            .toList(growable: false) ??
        const <TodaySuggestionHistoryItem>[];

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
      clinicShareInFlight: clinicShareInFlight,
      isPreview: isPreview,
      generatedAtLabel: generatedAtLabel,
      onSignIn: onSignIn,
      onContinueRecord: () => context.push('/record/create'),
      onSync: () => _refreshDashboard(ref),
      suggestionHistory: suggestionHistory,
      isSuggestionHistoryLoading: suggestionHistoryAsync?.isLoading ?? false,
      onSuggestionTap: (item) =>
          showSuggestionHistoryDetailSheet(context, suggestion: item),
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
        suffixes: [
          ReportRangeMenu(
            selectedQuery: selectedDashboardQuery,
            onQueryChanged: (query) {
              ref
                  .read(reportDashboardSelectedQueryProvider.notifier)
                  .setQuery(query);
            },
          ),
        ],
        onRefresh: () => _refreshDashboard(ref),
        scrollStorageKey: 'report-desktop-scroll',
        child: dashboardView,
      );
    }

    return _ReportMobileShell(
      onRefresh: () => _refreshDashboard(ref),
      header: ReportTopBar(
        selectedQuery: selectedDashboardQuery,
        onQueryChanged: (query) {
          ref
              .read(reportDashboardSelectedQueryProvider.notifier)
              .setQuery(query);
        },
      ),
      child: dashboardView,
    );
  }
}

class _ReportMobileShell extends StatelessWidget {
  const _ReportMobileShell({
    required this.child,
    required this.header,
    required this.onRefresh,
  });

  final Widget child;
  final Widget header;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            header,
            Expanded(
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
                  children: [child],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _suggestionLifecycleRank(TodaySuggestionLifecycleState state) =>
    switch (state) {
      TodaySuggestionLifecycleState.active => 3,
      TodaySuggestionLifecycleState.generated => 2,
      TodaySuggestionLifecycleState.fading => 1,
      TodaySuggestionLifecycleState.dismissed => 0,
      TodaySuggestionLifecycleState.expired => -1,
    };
