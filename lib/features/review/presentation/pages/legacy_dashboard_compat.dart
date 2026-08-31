// ═══════════════════════════════════════════════════════════════════════════
// LEGACY 兼容页 — 从 Review 页 More sheet 的「历史报告」入口进入。
//
// Task 8：导出与就诊摘要迁入 More 后，旧 dashboard 主路径已移除；为兼容
// 仍需要旧版周报的用户，按 d8c9c5f5e 旧 ReviewPage 的 dashboard 装配重建
// 本兼容页（readiness 首卡 + 趋势/发现/建议历史 + AI 总结/规律 + 四张导出卡
// + 7/30 天范围切换的 ReviewTopBar），推送式进入（`/review/legacy`）。
//
// 取舍说明：只重建移动端布局（与当前 ReviewView 一致，桌面宽度也渲染同一
// 布局），不复刻旧桌面端 DesktopTabShell 双栏外壳；导出/分享行为经共享的
// `handleReviewExportAction` 与旧装配保持一致，不新增功能。
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/page_state.dart';
import 'package:luminous/core/widgets/common/state_message.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/export_actions.dart';
import 'package:luminous/features/review/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/suggestion_history_detail_sheet.dart';
import 'package:luminous/features/review/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/review/presentation/widgets/views/legacy/dashboard_view.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/providers/suggestion.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LegacyDashboardCompatPage extends ConsumerWidget {
  const LegacyDashboardCompatPage({super.key});

  Future<void> _refreshDashboard(WidgetRef ref) async {
    final query = ref.read(reviewDashboardSelectedQueryProvider);
    ref.invalidate(reviewDashboardProvider(query));
    await ref.read(reviewDashboardProvider(query).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final canAccessProtectedData = session.canAccessProtectedData;

    final selectedDashboardQuery = ref.watch(
      reviewDashboardSelectedQueryProvider,
    );

    // Always watch the provider — when signed out it returns preview data.
    final dashboardAsync = ref.watch(
      reviewDashboardProvider(selectedDashboardQuery),
    );

    // Cache the last successful dashboard so that switching time ranges
    // shows stale data instead of a full skeleton.
    ref.listen<AsyncValue<ReviewDashboard>>(
      reviewDashboardProvider(selectedDashboardQuery),
      (_, next) {
        next.whenData((dashboard) {
          ref.read(reviewLastDashboardProvider.notifier).set(dashboard);
        });
      },
    );
    final cachedDashboard = ref.watch(reviewLastDashboardProvider);

    final effectiveAsync =
        dashboardAsync.isLoading &&
            !dashboardAsync.hasValue &&
            cachedDashboard != null
        ? AsyncValue<ReviewDashboard>.data(cachedDashboard)
        : dashboardAsync;

    final pageState = resolvePageViewState<ReviewDashboard>(
      session: session,
      data: effectiveAsync,
    );

    return PageStateSwitch<ReviewDashboard>(
      state: pageState,
      loadingBuilder: () => _buildShell(
        context: context,
        header: _header(context, ref, selectedDashboardQuery),
        child: const ReviewSkeletonView(),
        onRefresh: () => _refreshDashboard(ref),
      ),
      fatalErrorBuilder: (error) => _buildShell(
        context: context,
        header: _header(context, ref, selectedDashboardQuery),
        child: StateErrorView(
          title: AppLocalizations.of(context)!.reviewErrorTitle,
          description: AppLocalizations.of(context)!.reviewErrorDescription,
          icon: SemanticIcons.tabReview,
          actionLabel: AppLocalizations.of(context)!.todayRetryAction,
          onAction: () =>
              ref.invalidate(reviewDashboardProvider(selectedDashboardQuery)),
          tone: StateTone.warning,
        ),
        onRefresh: () => _refreshDashboard(ref),
      ),
      readyBuilder: (dashboard, isPreview) => _buildReadyContent(
        context: context,
        ref: ref,
        dashboard: dashboard,
        selectedDashboardQuery: selectedDashboardQuery,
        canAccessProtectedData: canAccessProtectedData,
        isPreview: isPreview,
      ),
    );
  }

  Widget _header(
    BuildContext context,
    WidgetRef ref,
    ReviewDashboardQuery selectedQuery,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return FHeader.nested(
      title: Text(l10n.tabReview),
      prefixes: const [AppBackButton()],
      suffixes: [
        ReviewRangeMenu(
          selectedQuery: selectedQuery,
          onQueryChanged: (query) {
            ref
                .read(reviewDashboardSelectedQueryProvider.notifier)
                .setQuery(query);
          },
        ),
      ],
    );
  }

  Widget _buildShell({
    required BuildContext context,
    required Widget header,
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.theme.colors.background),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            header,
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView(
                  key: const PageStorageKey<String>(
                    'legacy-dashboard-compat-scroll',
                  ),
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

  Widget _buildReadyContent({
    required BuildContext context,
    required WidgetRef ref,
    required ReviewDashboard dashboard,
    required ReviewDashboardQuery selectedDashboardQuery,
    required bool canAccessProtectedData,
    required bool isPreview,
  }) {
    final aiSummariesEnabled = canAccessProtectedData
        ? ref.watch(
            userSettingsControllerProvider.select(
              (s) => s.asData?.value.aiSummariesEnabled,
            ),
          )
        : null;
    final selectedAiSummaryRange = ref.watch(
      reviewAiSummarySelectedRangeProvider,
    );
    final aiSummaryState = ref.watch(
      reviewAiSummaryControllerProvider(selectedAiSummaryRange),
    );
    final latestExportRequest = ref.watch(
      dataExportControllerProvider.select((s) => s.asData?.value),
    );
    final exportRequestInFlight = ref.watch(dataExportRequestInFlightProvider);
    final clinicShareInFlight = ref.watch(clinicShareInFlightProvider);
    final suggestionHistoryAsync = canAccessProtectedData
        ? ref.watch(suggestionHistoryProvider)
        : null;
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

    final dashboardView = ReviewDashboardView(
      dashboard: dashboard,
      canAccessProtectedData: canAccessProtectedData,
      aiSummariesEnabled: aiSummariesEnabled,
      dashboardQuery: selectedDashboardQuery,
      onDashboardQueryChanged: (query) {
        ref.read(reviewDashboardSelectedQueryProvider.notifier).setQuery(query);
      },
      aiSummaryState: aiSummaryState,
      aiSummaryRange: selectedAiSummaryRange,
      latestExportRequest: latestExportRequest,
      exportRequestInFlight: exportRequestInFlight,
      clinicShareInFlight: clinicShareInFlight,
      isPreview: isPreview,
      generatedAtLabel: generatedAtLabel,
      onSignIn: () => context.push(loginRouteForCurrentLocation(context)),
      onContinueRecord: () => context.push('/record/create'),
      onSync: () => _refreshDashboard(ref),
      suggestionHistory: suggestionHistory,
      isSuggestionHistoryLoading: suggestionHistoryAsync?.isLoading ?? false,
      onSuggestionTap: (item) =>
          showSuggestionHistoryDetailSheet(context, suggestion: item),
      onAiSummaryRangeChanged: (range) {
        ref.read(reviewAiSummarySelectedRangeProvider.notifier).setRange(range);
      },
      onGenerateAiSummary: () async {
        await ref
            .read(
              reviewAiSummaryControllerProvider(
                selectedAiSummaryRange,
              ).notifier,
            )
            .generate();
      },
      onExportActionTap: (kind) => handleReviewExportAction(context, ref, kind),
    );

    return _buildShell(
      context: context,
      header: _header(context, ref, selectedDashboardQuery),
      child: dashboardView,
      onRefresh: () => _refreshDashboard(ref),
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
