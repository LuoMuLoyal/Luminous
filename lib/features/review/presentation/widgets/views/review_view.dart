import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sections/coverage_strip.dart';
import 'package:luminous/features/review/presentation/widgets/sections/event_header.dart';
import 'package:luminous/features/review/presentation/widgets/sections/history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/review/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/review/presentation/widgets/sections/noteworthy.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period_switch.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview_locked.dart';
import 'package:luminous/features/review/presentation/widgets/sections/record_guide.dart';
import 'package:luminous/features/review/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 洞察优先的回顾首屏（移动端约束布局）。
///
/// 六种状态：
/// 1. loading —— 无数据时的骨架屏；
/// 2. active —— 事件头部提供「去今日 check-in」浅链接 + 四段；
/// 3. ended —— 事件头部展示 outcome + 四段；
/// 4. partial —— 个别段落 unknown，只显示简短缺失原因，无分数/红色告警；
/// 5. no-event —— 数据过稀时记录引导卡（去 record 补记），否则轻量解释卡 +
///    记录后预览预告卡；无事件时不生成周报、不渲染任何事件动作；
/// 6. error-with-cache —— 刷新失败但保留上次成功数据，顶部轻量提示；
///    无缓存的错误在 [StateErrorView] 中给出重试。
///
/// 事件动作（开始观察 / check-in / end）已收口 Today，本视图不承接任何
/// 事件动作回调；仅通过 [onGoTodayCheckIn] 提供「去今日 check-in」浅链接。
class ReviewView extends StatelessWidget {
  const ReviewView({
    super.key,
    required this.currentAsync,
    required this.cachedReview,
    required this.historyAsync,
    required this.canAccessProtectedData,
    required this.isPreview,
    required this.onRetry,
    required this.onGoRecord,
    required this.onGoTodayCheckIn,
    required this.onSignIn,
    this.onHistoryRetry,
    this.historyStatus,
    this.onHistoryStatusChanged,
    this.onEventTap,
    this.onHistoryLoadMore,
    this.trendSeries = const [],
    this.trendStartDate = '----.--.--',
    this.periodRange = ReviewDashboardRange.last7Days,
    this.onPeriodRangeChanged,
    this.coverageMetrics = const [],
    this.findings = const [],
    this.findingsWindowStart = '----.--.--',
    this.findingsWindowEnd = '----.--.--',
    this.selectedTrendKind,
    this.onTrendKindChanged,
    this.isColdStart = false,
    this.coldObserved = 0,
    this.coldExpected = 0,
  });

  final AsyncValue<EventReview?> currentAsync;
  final EventReview? cachedReview;
  final AsyncValue<ReviewEventPage> historyAsync;
  final bool canAccessProtectedData;
  final bool isPreview;
  final VoidCallback onRetry;
  final VoidCallback onGoRecord;
  final VoidCallback onGoTodayCheckIn;
  final VoidCallback onSignIn;

  /// 历史加载失败时卡片内的轻量重试回调；缺省时不显示重试按钮。
  final VoidCallback? onHistoryRetry;

  /// 历史 status 筛选的当前选中值与切换回调（页面装配层接到
  /// reviewHistoryStatusProvider）。缺省时筛选按钮禁用。
  final ReviewEventStatus? historyStatus;
  final ValueChanged<ReviewEventStatus?>? onHistoryStatusChanged;

  /// 历史行点击回调（push 详情页）；null 时历史行只读不可点。
  final ValueChanged<ReviewEvent>? onEventTap;

  /// 历史翻页回调；传入当前页的 nextCursor，返回下一页。
  /// null 时不显示「加载更多」按钮。
  final Future<ReviewEventPage> Function(String cursor)? onHistoryLoadMore;

  /// 纵向洞察折线图数据（饮水/睡眠/用药单折线图）。
  /// 数据来自 reviewDashboardProvider；空列表时不渲染折线图。
  final List<ReviewTrendSeries> trendSeries;

  /// 折线图的起始日期标签（YYYY-MM-DD 格式）。
  final String trendStartDate;

  /// 周期切换（周|月）当前选中的范围，映射 dashboard 查询。
  final ReviewDashboardRange periodRange;

  /// 周期切换回调；页面装配层接到 reviewDashboardSelectedQueryProvider。
  final ValueChanged<ReviewDashboardRange>? onPeriodRangeChanged;

  /// 覆盖率概览行数据（各健康维度的记录覆盖小卡），来自主路径 dashboard
  /// 的 metrics；空列表时不渲染概览行。
  final List<ReviewMetric> coverageMetrics;

  /// 值得注意区数据（dashboard findings），最多展示 2 张结构化卡；空列表
  /// 时展示弃权占位。
  final List<ReviewFinding> findings;

  /// 值得注意区的数据窗口（startDate–endDate）。
  final String findingsWindowStart;
  final String findingsWindowEnd;

  /// 当前选中的单维趋势维度（覆盖概览行与趋势卡 chips 联动）。
  final ReviewDataKind? selectedTrendKind;

  /// 维度切换回调；页面装配层接到 reviewTrendDimensionProvider。
  final ValueChanged<ReviewDataKind>? onTrendKindChanged;

  /// 冷启动态：无进行中事件且当前周期数据过稀时，展示记录引导卡而非
  /// 「开始观察」动作（事件动作收口 Today）。
  final bool isColdStart;

  /// 记录引导卡的已记录天数（observedMetric.observedCount）。
  final int coldObserved;

  /// 记录引导卡的范围天数（本周/本月）。
  final int coldExpected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (currentAsync.isLoading &&
        !currentAsync.hasValue &&
        cachedReview == null) {
      return const ReviewSkeletonView();
    }

    if (currentAsync.hasError && cachedReview == null) {
      return StateErrorView(
        title: l10n.reviewReviewErrorTitle,
        description: l10n.reviewReviewErrorDescription,
        icon: SemanticIcons.tabReview,
        actionLabel: l10n.todayRetryAction,
        onAction: onRetry,
        tone: StateTone.warning,
      );
    }

    // 刷新失败时保留上次成功数据（error-with-cache），只加一行轻量提示。
    final showStaleBanner = currentAsync.hasError && cachedReview != null;
    final review = currentAsync.asData?.value ?? cachedReview;

    final children = <Widget>[
      // P0-1 周期开关：顶栏下首行，周|月 FTabs；切换期间由页面层用旧数据
      // 承接（轻量加载态），不整页骨架。
      ReviewPeriodSwitch(
        selectedRange: periodRange,
        onRangeChanged: onPeriodRangeChanged ?? (_) {},
      ),
      if (isPreview) SignInHintBanner(onSignIn: onSignIn),
      if (showStaleBanner) const _StaleBanner(key: Key('review-stale-banner')),
      // 覆盖率概览行：各维度覆盖小卡，横滑；空列表时不渲染。
      if (coverageMetrics.isNotEmpty)
        ReviewCoverageStrip(
          metrics: coverageMetrics,
          onTap: onTrendKindChanged,
        ),
      // 值得注意区：findings 结构化卡；空时展示弃权占位。
      ReviewNoteworthySection(
        findings: findings,
        l10n: l10n,
        startDate: findingsWindowStart,
        endDate: findingsWindowEnd,
      ),
      if (review == null) ...[
        // P0-5：无进行中事件时不再提供「开始观察」动作（收口 Today）。
        // 数据过稀 → 记录引导卡（去 record 补记）；否则降级为轻量解释卡。
        if (isColdStart)
          ReviewRecordGuideSection(
            observedCount: coldObserved,
            expectedCount: coldExpected,
            onGoRecord: onGoRecord,
          )
        else
          const _NoEventExplanationCard(),
        ReviewPreviewOverviewSection(
          key: const Key('review-preview-overview-card'),
          items: [
            (
              SemanticIcons.reportAdherence,
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
        ),
      ] else ...[
        EventHeaderSection(
          event: review.event,
          todayCheckIn: review.coverage.checkIns.todayCheckIn,
          onGoTodayCheckIn: onGoTodayCheckIn,
        ),
        WhatHappenedSection(section: review.sections.whatHappened),
        KeyChangesSection(section: review.sections.keyChanges),
        CompletedActionsSection(section: review.sections.completedActions),
        NextStepSection(section: review.sections.nextStep),
      ],
      // 纵向洞察折线图：饮水/睡眠/用药三指标 FTab 切换单折线。
      if (trendSeries.isNotEmpty)
        ReviewTrendSection(
          key: const Key('review-trend-section'),
          trends: trendSeries,
          selectedQuery: ReviewDashboardQuery(range: periodRange),
          onQueryChanged: (_) {},
          l10n: l10n,
          startDate: trendStartDate,
          showRangePill: false,
          selectedKind: selectedTrendKind,
          onKindChanged: onTrendKindChanged,
        ),
      ReviewHistorySection(
        history: historyAsync,
        onRetry: onHistoryRetry,
        selectedStatus: historyStatus,
        onStatusChanged: onHistoryStatusChanged,
        onEventTap: onEventTap,
        onLoadMore: onHistoryLoadMore,
      ),
    ];

    return Column(
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.level4),
            child: child,
          ),
      ],
    );
  }
}

/// 刷新失败但仍有上次成功数据时的轻量提示条（非阻塞）。
class _StaleBanner extends StatelessWidget {
  const _StaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SemanticColor.info.subtle(context),
        borderRadius: context.theme.style.borderRadius.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level3,
        vertical: Spacing.level2,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(
              SemanticIcons.statusInfo,
              size: IconSizeTokens.level2,
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(width: Spacing.level2),
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

/// 无进行中事件的轻量解释卡（数据尚足但无事件时）。
///
/// P0-5 起不再提供「开始观察」动作（事件动作收口 Today）：仅保留解释文案，
/// 数据过稀时改由 [ReviewRecordGuideSection] 提供「去 record」入口。
class _NoEventExplanationCard extends StatelessWidget {
  const _NoEventExplanationCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return FCard(
      key: const Key('review-no-event-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reviewReviewNoEventTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level2),
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
