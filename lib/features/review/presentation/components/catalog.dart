import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/components/legacy.dart';
import 'package:luminous/features/review/presentation/providers/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/data_access.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';
import 'package:luminous/features/review/presentation/providers/surface.dart';
import 'package:luminous/features/review/presentation/providers/trend.dart';
import 'package:luminous/features/review/presentation/widgets/sections/event/ai_summary.dart';
import 'package:luminous/features/review/presentation/widgets/sections/event/what_happened.dart';
import 'package:luminous/features/review/presentation/widgets/sections/history/history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/history/period_switch.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/completed_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/coverage_strip.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/event_header.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/key_changes.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/next_step.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/noteworthy.dart';
import 'package:luminous/features/review/presentation/widgets/sections/overview/record_guide.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/preview_locked.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/presentation/components/catalog.dart'
    show todayPreviewBannerId;
import 'package:luminous/l10n/app_localizations.dart';

/// Components of the `review` surface.
///
/// Each one is an adapter around an existing section widget: the section keeps
/// its rendering, the adapter owns the id, the visibility decision and the
/// "nothing to show right now" answer. Components read from providers
/// ([reviewSurfaceStateProvider] and friends) instead of receiving page-owned
/// data slices, which is what lets the same widget be mounted on a
/// user-chosen layout later.
///
/// Ids are `<domain>.<view>` and never mention `review` — the tab name is not a
/// domain.
///
/// `build` returning `null` means "skip me and my spacing"; this is what
/// removes the `SizedBox.shrink()` placeholders the hand-written page needed.
const reviewPeriodSwitchId = ComponentId('period.switch');
const reviewCoverageStripId = ComponentId('coverage.strip');
const reviewNoteworthyId = ComponentId('overview.noteworthy');
const reviewRecordGuideId = ComponentId('overview.record_guide');
const reviewEventHeaderId = ComponentId('event.header');
const reviewWhatHappenedId = ComponentId('event.what_happened');
const reviewKeyChangesId = ComponentId('overview.key_changes');
const reviewCompletedActionsId = ComponentId('overview.completed_actions');
const reviewNextStepId = ComponentId('overview.next_step');
const reviewTrendId = ComponentId('trend.single');
const reviewHistoryId = ComponentId('history.review');
const reviewAiSummaryId = ComponentId('ai_summary.event');
const reviewPreviewOverviewId = ComponentId('preview.overview');
const reviewNoEventExplanationId = ComponentId('preview.no_event_note');
const reviewStaleBannerId = ComponentId('status.stale_banner');

/// Surface definition: what `review` may host and what it shows by default.
///
/// The default layout is the pre-composition render order of `ReviewView`, so
/// this phase is a pure refactor — a user who never edits anything sees the
/// same page in the same order.
const reviewSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.review,
  available: [
    reviewPeriodSwitchId,
    reviewTrendId,
    reviewCoverageStripId,
    reviewEventHeaderId,
    reviewWhatHappenedId,
    reviewKeyChangesId,
    reviewCompletedActionsId,
    reviewNextStepId,
    reviewNoteworthyId,
    reviewRecordGuideId,
    reviewHistoryId,
    reviewAiSummaryId,
    reviewPreviewOverviewId,
    reviewNoEventExplanationId,
    reviewStaleBannerId,
    // legacy 组件：可被用户选中编排，但不进默认布局（默认必须等于
    // 今天的事件优先页面）。
    ...reviewLegacyComponentIds,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      // P0-1 周期开关：顶栏下首行。
      ComponentPlacement(id: reviewPeriodSwitchId),
      // 登录提示由组件自行判断是否出现。
      // 未登录预览横幅是全局登录提示，不属于任何单一页面：today 与 review
      // 挂的是**同一个组件**（同 id），因此这里只引用今日目录导出的 id，不重复
      // 注册——否则注册表会因为重复 id 直接抛错。
      // 文案由 today 的组件统一提供（全局登录提示只说一句话），review 不再
      // 自定义，避免用户在编排界面看到两个几乎一样的「登录提示」选项。
      ComponentPlacement(id: todayPreviewBannerId),
      // 覆盖率概览行：空列表时不渲染。
      ComponentPlacement(id: reviewCoverageStripId),
      // 值得注意区：空 findings 时展示弃权占位（始终出现）。
      ComponentPlacement(id: reviewNoteworthyId),
      // 无进行中事件时：数据过稀 → 记录引导卡，否则由页面级解释卡承接。
      ComponentPlacement(id: reviewRecordGuideId),
      // 无事件时：轻量解释卡之后的「记录后可看到什么」预告卡；有事件时不出现。
      ComponentPlacement(id: reviewNoEventExplanationId),
      ComponentPlacement(id: reviewPreviewOverviewId),
      ComponentPlacement(id: reviewStaleBannerId),
      // 有进行中/最近事件时：事件头部 + 四段。
      ComponentPlacement(id: reviewEventHeaderId),
      ComponentPlacement(id: reviewWhatHappenedId),
      ComponentPlacement(id: reviewKeyChangesId),
      ComponentPlacement(id: reviewCompletedActionsId),
      ComponentPlacement(id: reviewNextStepId),
      // 纵向洞察折线图：空趋势时不渲染。
      ComponentPlacement(id: reviewTrendId),
      ComponentPlacement(id: reviewHistoryId),
    ],
  ),
);

/// Registers every `review` component into [registry].
void registerReviewComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _PeriodSwitchComponent());
  registry.registerDescriptor(const _CoverageStripComponent());
  registry.registerDescriptor(const _NoteworthyComponent());
  registry.registerDescriptor(const _RecordGuideComponent());
  registry.registerDescriptor(const _EventHeaderComponent());
  registry.registerDescriptor(const _WhatHappenedComponent());
  registry.registerDescriptor(const _KeyChangesComponent());
  registry.registerDescriptor(const _CompletedActionsComponent());
  registry.registerDescriptor(const _NextStepComponent());
  registry.registerDescriptor(const _TrendComponent());
  registry.registerDescriptor(const _HistoryComponent());
  registry.registerDescriptor(const _AiSummaryComponent());
  registry.registerDescriptor(const _PreviewOverviewComponent());
  registry.registerDescriptor(const _NoEventExplanationComponent());
  registry.registerDescriptor(const _StaleBannerComponent());
  registerReviewLegacyComponents(registry);
}

/// Cold start: no usable coverage and no trend data for the selected range.
///
/// Mirrors the old page-level decision exactly — when data is too sparse the
/// record guide replaces the "start observing" action (event actions now live
/// on Today), which is why this lives next to the component that renders it.
bool isReviewColdStart(ReviewDashboard dashboard) {
  final metrics = dashboard.metrics;
  if (metrics.isEmpty) return true;
  final hasUsableCoverage = metrics.any(
    (metric) =>
        metric.observedMetric != null &&
        metric.observedMetric!.coverage != ReviewObservedMetricCoverage.none &&
        metric.observedMetric!.observedCount >= 2,
  );
  return !hasUsableCoverage && dashboard.trends.isEmpty;
}
/// Reads the current review without flattening the `AsyncValue`.
///
/// `null` covers "still loading", "failed" and "confirmed no event": the page
/// owns the skeleton and the error view, and the no-event branch is handled by
/// [reviewRecordGuideId]. A component must never turn a failure into
/// "no event".
EventReview? _currentReview(WidgetRef ref) {
  final async = ref.watch(reviewCurrentProvider);
  if (async.isLoading && !async.hasValue) return null;
  if (async.hasError && !async.hasValue) return null;
  return async.value;
}

class _PeriodSwitchComponent extends ComponentDescriptor<NoComponentConfig> {
  const _PeriodSwitchComponent();

  @override
  ComponentId get id => reviewPeriodSwitchId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return ReviewPeriodSwitch(
      selectedRange: ref.watch(reviewSurfaceRangeProvider),
      onRangeChanged: (range) => ref
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setRange(range),
    );
  }
}

class _CoverageStripComponent extends ComponentDescriptor<NoComponentConfig> {
  const _CoverageStripComponent();

  @override
  ComponentId get id => reviewCoverageStripId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final metrics = ref.watch(reviewSurfaceStateProvider).dataOrNull?.metrics;
    if (metrics == null || metrics.isEmpty) return null;
    return ReviewCoverageStrip(
      metrics: metrics,
      onTap: (kind) =>
          ref.read(reviewTrendDimensionProvider.notifier).select(kind),
    );
  }
}

class _NoteworthyComponent extends ComponentDescriptor<NoComponentConfig> {
  const _NoteworthyComponent();

  @override
  ComponentId get id => reviewNoteworthyId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return ReviewNoteworthySection(
      findings: dashboard.findings,
      l10n: AppLocalizations.of(context)!,
      startDate: dashboard.startDate,
      endDate: dashboard.endDate,
      range: dashboard.range,
    );
  }
}

class _RecordGuideComponent extends ComponentDescriptor<NoComponentConfig> {
  const _RecordGuideComponent();

  @override
  ComponentId get id => reviewRecordGuideId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    // 有进行中/最近事件时不出现。
    if (_currentReview(ref) != null) return null;
    if (!isReviewColdStart(dashboard)) return null;

    final observed = dashboard.metrics
        .map((metric) => metric.observedMetric?.observedCount ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    final expected =
        ref.watch(reviewSurfaceRangeProvider) == ReviewDashboardRange.last30Days
        ? 30
        : 7;
    return ReviewRecordGuideSection(
      observedCount: observed,
      expectedCount: expected,
      onGoRecord: () => context.go(Routes.record),
    );
  }
}

class _EventHeaderComponent extends ComponentDescriptor<NoComponentConfig> {
  const _EventHeaderComponent();

  @override
  ComponentId get id => reviewEventHeaderId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return switch (_currentReview(ref)) {
      final EventReview review => EventHeaderSection(
        event: review.event,
        todayCheckIn: review.coverage.checkIns.todayCheckIn,
        onGoTodayCheckIn: () => context.go(Routes.home),
      ),
      _ => null,
    };
  }
}

class _WhatHappenedComponent extends ComponentDescriptor<NoComponentConfig> {
  const _WhatHappenedComponent();

  @override
  ComponentId get id => reviewWhatHappenedId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return switch (_currentReview(ref)) {
      final EventReview review => WhatHappenedSection(
        section: review.sections.whatHappened,
      ),
      _ => null,
    };
  }
}

class _KeyChangesComponent extends ComponentDescriptor<NoComponentConfig> {
  const _KeyChangesComponent();

  @override
  ComponentId get id => reviewKeyChangesId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return switch (_currentReview(ref)) {
      final EventReview review => KeyChangesSection(
        section: review.sections.keyChanges,
      ),
      _ => null,
    };
  }
}

class _CompletedActionsComponent extends ComponentDescriptor<NoComponentConfig> {
  const _CompletedActionsComponent();

  @override
  ComponentId get id => reviewCompletedActionsId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return switch (_currentReview(ref)) {
      final EventReview review => CompletedActionsSection(
        section: review.sections.completedActions,
      ),
      _ => null,
    };
  }
}

class _NextStepComponent extends ComponentDescriptor<NoComponentConfig> {
  const _NextStepComponent();

  @override
  ComponentId get id => reviewNextStepId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return switch (_currentReview(ref)) {
      final EventReview review => NextStepSection(
        section: review.sections.nextStep,
      ),
      _ => null,
    };
  }
}

class _TrendComponent extends ComponentDescriptor<NoComponentConfig> {
  const _TrendComponent();

  @override
  ComponentId get id => reviewTrendId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null || dashboard.trends.isEmpty) return null;
    return ReviewTrendSection(
      key: const Key('review-trend-section'),
      trends: dashboard.trends,
      selectedQuery: ref.watch(reviewDashboardSelectedQueryProvider),
      onQueryChanged: (_) {},
      l10n: AppLocalizations.of(context)!,
      startDate: dashboard.startDate,
      showRangePill: false,
      selectedKind: ref.watch(reviewTrendDimensionProvider),
      onKindChanged: (kind) =>
          ref.read(reviewTrendDimensionProvider.notifier).select(kind),
    );
  }
}

class _HistoryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _HistoryComponent();

  @override
  ComponentId get id => reviewHistoryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    final historyStatus = ref.watch(reviewHistoryStatusProvider);
    return ReviewHistorySection(
      history: ref.watch(reviewHistoryProvider),
      onRetry: () => ref.invalidate(reviewHistoryProvider),
      selectedStatus: historyStatus,
      onStatusChanged: (status) =>
          ref.read(reviewHistoryStatusProvider.notifier).select(status),
      onEventTap: (event) =>
          context.push(Routes.reviewDetail.replaceAll(':eventId', event.id)),
      onLoadMore: (cursor) async {
        final result = await ref
            .read(reviewRepositoryProvider)
            .fetchHistory(status: historyStatus, cursor: cursor)
            .run();
        // Left 重抛，由 ReviewHistorySection 的既有 catch 投影为加载更多失败行。
        return result.fold((failure) => throw failure, (page) => page);
      },
    );
  }
}

class _AiSummaryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _AiSummaryComponent();

  @override
  ComponentId get id => reviewAiSummaryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (_currentReview(ref) == null) return null;

    final canAccessProtectedData = ref
        .watch(authSessionProvider)
        .canAccessProtectedData;
    final selectedRange = ref.watch(reviewAiSummarySelectedRangeProvider);
    final aiEnabled = ref.watch(
      userSettingsControllerProvider.select(
        (settings) => settings.asData?.value.aiSummariesEnabled,
      ),
    );
    return ReviewAiSummarySection(
      aiSummaryEnabled: aiEnabled ?? true,
      canAccessProtectedData: canAccessProtectedData,
      aiState: ref.watch(reviewAiSummaryControllerProvider(selectedRange)),
      selectedRange: selectedRange,
      onRangeChanged: (range) => ref
          .read(reviewAiSummarySelectedRangeProvider.notifier)
          .setRange(range),
      onGenerate: canAccessProtectedData
          ? () async {
              await ref
                  .read(reviewAiSummaryControllerProvider(selectedRange).notifier)
                  .generate();
            }
          : null,
      l10n: AppLocalizations.of(context)!,
    );
  }
}
class _PreviewOverviewComponent extends ComponentDescriptor<NoComponentConfig> {
  const _PreviewOverviewComponent();

  @override
  ComponentId get id => reviewPreviewOverviewId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 只在「无进行中事件」时出现，且有事件时不替代任何真实内容。
    if (_currentReview(ref) != null) return null;
    if (ref.watch(reviewSurfaceStateProvider).dataOrNull == null) return null;

    final l10n = AppLocalizations.of(context)!;
    return ReviewPreviewOverviewSection(
      key: const Key('review-preview-overview-card'),
      items: [
        (
          SemanticIcons.reportCoverage,
          l10n.reviewPreviewCoverageTitle,
          l10n.reviewPreviewCoverageBody,
        ),
        (
          SemanticIcons.reportInsight,
          l10n.reviewPreviewNoteworthyTitle,
          l10n.reviewPreviewNoteworthyBody,
        ),
        (
          SemanticIcons.reportTrend,
          l10n.reviewPreviewTrendTitle,
          l10n.reviewPreviewTrendBody,
        ),
        (
          SemanticIcons.reportHistory,
          l10n.reviewPreviewHistoryTitle,
          l10n.reviewPreviewHistoryBody,
        ),
      ],
    );
  }
}
class _NoEventExplanationComponent extends ComponentDescriptor<NoComponentConfig> {
  const _NoEventExplanationComponent();

  @override
  ComponentId get id => reviewNoEventExplanationId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    // 只在「确认无事件、且数据不算过稀」时出现；过稀时由记录引导卡替代。
    if (ref.watch(reviewSurfaceHasEventProvider)) return null;
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    if (isReviewColdStart(dashboard)) return null;

    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return FCard(
      key: const Key('review-no-event-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewReviewNoEventTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.reviewReviewNoEventDescription,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaleBannerComponent extends ComponentDescriptor<NoComponentConfig> {
  const _StaleBannerComponent();

  @override
  ComponentId get id => reviewStaleBannerId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget? build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    if (!ref.watch(reviewSurfaceStaleProvider)) return null;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const Key('review-stale-banner'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: SemanticColor.info.subtle(context),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              SemanticIcons.statusInfo,
              size: IconSizeTokens.sm,
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              l10n.reviewReviewStaleBanner,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
