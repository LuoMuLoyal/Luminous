import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/report/presentation/widgets/sections/event_header.dart';
import 'package:luminous/features/report/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/report/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/report/presentation/widgets/sections/review_history.dart';
import 'package:luminous/features/report/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
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
    this.onHistoryRetry,
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

  /// 历史加载失败时卡片内的轻量重试回调；缺省时不显示重试按钮。
  final VoidCallback? onHistoryRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (currentAsync.isLoading &&
        !currentAsync.hasValue &&
        cachedReview == null) {
      return const ReportSkeletonView();
    }

    if (currentAsync.hasError && cachedReview == null) {
      return StateErrorView(
        title: l10n.reportReviewErrorTitle,
        description: l10n.reportReviewErrorDescription,
        icon: SemanticIcons.tabReport,
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
      if (review == null)
        _StartObservationCard(
          onStartObservation: onStartObservation,
          showStartAction: canAccessProtectedData,
        )
      else ...[
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
      ],
      ReviewHistorySection(history: historyAsync, onRetry: onHistoryRetry),
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
    final colors = context.theme.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: SemanticColor.info.subtle(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
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
              size: Spacing.level4,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(
              l10n.reportReviewStaleBanner,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
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
    final colors = context.theme.colors;

    return FCard(
      key: const Key('review-no-event-card'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reportReviewNoEventTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.reportReviewNoEventDescription,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
            ),
            if (showStartAction) ...[
              const SizedBox(height: Spacing.level4),
              FButton(
                key: const Key('review-start-observation-action'),
                onPress: onStartObservation,
                child: Text(l10n.reportReviewStartObservationAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
