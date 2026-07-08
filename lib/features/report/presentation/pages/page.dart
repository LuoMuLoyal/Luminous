import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart';
import 'package:share_plus/share_plus.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/notification/presentation/providers/providers.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/ai_summary_provider.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/dashboard_provider.dart';
import 'package:luminous/features/report/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/report/presentation/widgets/views/dashboard_view.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/report/presentation/widgets/shared/sections.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
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

    // Clinic share: generate a Redis share link and open native share sheet
    if (kind == ReportExportKind.clinicShare) {
      await _handleClinicShare(context, ref, l10n);
      return;
    }

    final controller = ref.read(dataExportControllerProvider.notifier);
    final launcher = ref.read(externalUrlLauncherProvider);

    try {
      final request = await controller.requestExport(
        _exportInputForKind(kind)!,
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
      debugPrint('ReportPage._handleExportAction: failed: $error');
      if (!context.mounted) {
        return;
      }
      final message = LucentErrorMapper.fromObject(error).message;
      await AppToast.show(context, '${l10n.reportExportFailedToast}: $message');
    }
  }

  Future<void> _handleClinicShare(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final reportsApi = ref.read(lucentReportsApiProvider);
      final response = await reportsApi.reportsControllerShareClinicSummaryV1();
      if (!context.mounted) return;

      final shareUrl = response.shareUrl;
      if (shareUrl.isEmpty) {
        await AppToast.show(context, l10n.reportExportFailedToast);
        return;
      }

      await SharePlus.instance.share(
        ShareParams(text: shareUrl, subject: l10n.reportExportClinicShareTitle),
      );
    } catch (error) {
      debugPrint('ReportPage._handleClinicShare: failed: $error');
      if (!context.mounted) return;
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
      isInsufficient: (_) => false,
    );

    return ShellDeferredContent(
      child: PageStateSwitch<ReportDashboard>(
        state: pageState,
        loadingBuilder: () => _buildLoadingShell(
          context: context,
          ref: ref,
          selectedDashboardQuery: selectedDashboardQuery,
        ),
        fatalErrorBuilder: (error) => FScaffold(
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
        emptyInsufficientBuilder: (empty) => DecoratedBox(
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
    final isDesktop = width >= AppBreakpoints.desktop;
    final dateRangeLabel = l10n.placeholderNoData;

    return isDesktop
        ? _ReportDesktopShell(
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
              showActionBar: true,
            ),
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
    final notificationListAsync = canAccessProtectedData
        ? ref.watch(notificationListPageProvider)
        : null;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final proactiveSuggestions =
        notificationListAsync?.asData?.value.items
            .where(
              (item) => item.type == UserNotificationType.aiProactiveSuggestion,
            )
            .take(3)
            .toList(growable: false) ??
        const <NotificationListItemDto>[];

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
      proactiveSuggestions: proactiveSuggestions,
      isSuggestionHistoryLoading: notificationListAsync?.isLoading ?? false,
      onSuggestionTap: (item) => context.push('/notifications/${item.id}'),
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
      return _ReportDesktopShell(
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
          showActionBar: true,
        ),
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
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const PageStorageKey<String>('report-desktop-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.level6,
              AppSpacingTokens.level6,
              AppSpacingTokens.level6,
              AppSpacingTokens.level6,
            ),
            children: [
              topBar,
              const SizedBox(height: AppSpacingTokens.level5),
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
              AppSpacingTokens.level4,
              AppSpacingTokens.level4,
              AppSpacingTokens.level4,
              AppSpacingTokens.level10,
            ),
            children: [
              topBar,
              const SizedBox(height: AppSpacingTokens.level4),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
