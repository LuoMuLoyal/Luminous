import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sections/event_header.dart';
import 'package:luminous/features/review/presentation/widgets/sections/history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/review/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview_locked.dart';
import 'package:luminous/features/review/presentation/widgets/sections/review_ai_summary.dart';
import 'package:luminous/features/review/presentation/widgets/sections/review_suggestion_history.dart';
import 'package:luminous/features/review/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/features/review/presentation/widgets/shared/constrained_action_button.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 事件优先的回顾首屏（移动端约束布局）。
///
/// 六种状态：
/// 1. loading —— 无数据时的骨架屏；
/// 2. active —— 事件头部提供今日 check-in + 四段；
/// 3. ended —— 事件头部展示 outcome + 四段；
/// 4. partial —— 个别段落 unknown，只显示简短缺失原因，无分数/红色告警；
/// 5. no-event —— 开始观察入口 + 最近事件历史，无事件时轻量解释，不生成周报；
/// 6. error-with-cache —— 刷新失败但保留上次成功数据，顶部轻量提示；
///    无缓存的错误在 [StateErrorView] 中给出重试。
///
/// 所有事件交互（check-in / 结束 / 开始观察）通过回调上抛给页面装配层。
class ReviewView extends StatelessWidget {
  const ReviewView({
    super.key,
    required this.currentAsync,
    required this.cachedReview,
    required this.historyAsync,
    required this.canAccessProtectedData,
    required this.isPreview,
    required this.onRetry,
    required this.onStartObservation,
    required this.onCheckIn,
    required this.onEndEvent,
    required this.onSignIn,
    this.aiSummaryState,
    this.aiSummarySelectedRange,
    this.aiSummariesEnabled,
    this.onAiSummaryRangeChanged,
    this.onGenerateAiSummary,
    this.suggestionHistory,
    this.isSuggestionHistoryLoading = false,
    this.onSuggestionTap,
    this.onHistoryRetry,
    this.historyStatus,
    this.onHistoryStatusChanged,
    this.onEventTap,
    this.onHistoryLoadMore,
  });

  final AsyncValue<EventReview?> currentAsync;
  final EventReview? cachedReview;
  final AsyncValue<ReviewEventPage> historyAsync;
  final bool canAccessProtectedData;
  final bool isPreview;
  final VoidCallback onRetry;
  final VoidCallback onStartObservation;
  final VoidCallback onCheckIn;
  final VoidCallback onEndEvent;
  final VoidCallback onSignIn;

  /// AI 总结状态与控制回调。缺省时不渲染 AI 总结段落。
  final ReviewAiSummaryCardState? aiSummaryState;
  final ReviewAiSummaryRange? aiSummarySelectedRange;
  final bool? aiSummariesEnabled;
  final ValueChanged<ReviewAiSummaryRange>? onAiSummaryRangeChanged;
  final Future<void> Function()? onGenerateAiSummary;

  /// 建议历史数据与回调。缺省时不渲染建议历史段落。
  final List<TodaySuggestionHistoryItem>? suggestionHistory;
  final bool isSuggestionHistoryLoading;
  final ValueChanged<TodaySuggestionHistoryItem>? onSuggestionTap;

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
      if (isPreview) SignInHintBanner(onSignIn: onSignIn),
      if (showStaleBanner) const _StaleBanner(key: Key('review-stale-banner')),
      if (review == null) ...[
        _StartObservationCard(
          onStartObservation: onStartObservation,
          showStartAction: canAccessProtectedData,
        ),
        ReviewPreviewLockedSection(
          icon: SemanticIcons.recordSymptom,
          title: l10n.reviewPreviewWhatHappenedTitle,
          body: l10n.reviewPreviewWhatHappenedBody,
        ),
        ReviewPreviewLockedSection(
          icon: SemanticIcons.reportTrend,
          title: l10n.reviewPreviewKeyChangesTitle,
          body: l10n.reviewPreviewKeyChangesBody,
        ),
        ReviewPreviewLockedSection(
          icon: SemanticIcons.recordClipboard,
          title: l10n.reviewPreviewCompletedActionsTitle,
          body: l10n.reviewPreviewCompletedActionsBody,
        ),
        ReviewPreviewLockedSection(
          icon: SemanticIcons.reportInsight,
          title: l10n.reviewPreviewNextStepTitle,
          body: l10n.reviewPreviewNextStepBody,
        ),
        ReviewPreviewLockedSection(
          icon: SemanticIcons.aiEntry,
          title: l10n.reviewPreviewAiSummaryTitle,
          body: l10n.reviewPreviewAiSummaryBody,
        ),
      ] else ...[
        EventHeaderSection(
          event: review.event,
          todayCheckIn: review.coverage.checkIns.todayCheckIn,
          showCheckInAction:
              canAccessProtectedData &&
              review.availableActions.contains(ReviewAction.checkIn),
          showEndAction:
              canAccessProtectedData &&
              review.availableActions.contains(ReviewAction.endEvent),
          onCheckIn: onCheckIn,
          onEndEvent: onEndEvent,
        ),
        WhatHappenedSection(section: review.sections.whatHappened),
        KeyChangesSection(section: review.sections.keyChanges),
        CompletedActionsSection(section: review.sections.completedActions),
        NextStepSection(section: review.sections.nextStep),
        if (aiSummaryState != null &&
            aiSummarySelectedRange != null &&
            aiSummariesEnabled != null)
          ReviewAiSummarySection(
            aiSummaryEnabled: aiSummariesEnabled!,
            canAccessProtectedData: canAccessProtectedData,
            aiState: aiSummaryState!,
            selectedRange: aiSummarySelectedRange!,
            onRangeChanged: onAiSummaryRangeChanged,
            onGenerate: onGenerateAiSummary,
            l10n: l10n,
          ),
        if (suggestionHistory != null && canAccessProtectedData)
          ReviewSuggestionHistorySection(
            suggestions: suggestionHistory!,
            l10n: l10n,
            isLoading: isSuggestionHistoryLoading,
            onSuggestionTap: onSuggestionTap,
          ),
      ],
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

/// 无事件时的入口卡片：开始健康观察 + 轻量解释。
///
/// 最近事件由下方的 [ReviewHistorySection] 承接；完全没有事件时不生成
/// 任何周报或泛化内容。未登录（预览）时隐藏开始按钮，由上方的
/// [SignInHintBanner] 引导登录。
class _StartObservationCard extends StatelessWidget {
  const _StartObservationCard({
    required this.onStartObservation,
    required this.showStartAction,
  });

  final VoidCallback onStartObservation;
  final bool showStartAction;

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
            if (showStartAction) ...[
              const SizedBox(height: Spacing.level4),
              ConstrainedActionButton(
                key: const Key('review-start-observation-action'),
                onPress: onStartObservation,
                label: l10n.reviewReviewStartObservationAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
