import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/report/presentation/providers/review.dart';
import 'package:luminous/features/report/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/report/presentation/widgets/sections/event_header.dart';
import 'package:luminous/features/report/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/report/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/report/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 单个历史事件的完整回顾详情页（`/report/review/:eventId`）。
///
/// 从 Review 页历史行点入，复用 [ReviewView] 的事件头部 + 四段渲染
/// widgets，接 [reviewDetailProvider]（autoDispose family，按事件 ID
/// 隔离；`ref.invalidate(reviewDetailProvider(eventId))` 即重试）。
/// 详情数据成功呈现后上报 `review_opened`（复用
/// [ProductEventService.trackReviewOpened] 的 session 去重语义，重复
/// 调用安全）。
class ReportReviewDetailPage extends ConsumerWidget {
  const ReportReviewDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(reviewDetailProvider(eventId));

    return PageScaffold(
      title: l10n.reportReviewDetailTitle,
      child: detailAsync.when(
        // ReportSkeletonView 是 Report 页骨架屏，内容高度超过一屏，需放在
        // 可滚动容器内复用（与 ReviewView 的骨架屏展示语义一致）。
        loading: () => const SingleChildScrollView(child: ReportSkeletonView()),
        error: (_, __) => StateErrorView(
          title: l10n.reportReviewErrorTitle,
          description: l10n.reportReviewErrorDescription,
          icon: SemanticIcons.tabReport,
          tone: StateTone.warning,
          actionLabel: l10n.todayRetryAction,
          onAction: () => ref.invalidate(reviewDetailProvider(eventId)),
        ),
        data: (review) => _ReviewDetailOpenedTracker(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventHeaderSection(
                  event: review.event,
                  todayCheckIn: review.coverage.checkIns.todayCheckIn,
                  // 详情页只读：不提供今日 check-in 与结束入口。
                  showCheckInAction: false,
                  showEndAction: false,
                  onCheckIn: () {},
                  onEndEvent: () {},
                ),
                const SizedBox(height: Spacing.level4),
                WhatHappenedSection(section: review.sections.whatHappened),
                const SizedBox(height: Spacing.level4),
                KeyChangesSection(section: review.sections.keyChanges),
                const SizedBox(height: Spacing.level4),
                CompletedActionsSection(
                  section: review.sections.completedActions,
                ),
                const SizedBox(height: Spacing.level4),
                NextStepSection(section: review.sections.nextStep),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 详情数据首次呈现后上报一次 `review_opened`。
///
/// 只存在于 data 分支内，因此只在数据可用时构建；post-frame 调用保证
/// 不在 build 期间触发副作用，`mounted` 守卫防卸载后回调。
/// [ProductEventService.trackReviewOpened] 自带 session 去重，重建/重试
/// 不会重复上报。
class _ReviewDetailOpenedTracker extends ConsumerStatefulWidget {
  const _ReviewDetailOpenedTracker({required this.child});

  final Widget child;

  @override
  ConsumerState<_ReviewDetailOpenedTracker> createState() =>
      _ReviewDetailOpenedTrackerState();
}

class _ReviewDetailOpenedTrackerState
    extends ConsumerState<_ReviewDetailOpenedTracker> {
  bool _reported = false;

  @override
  Widget build(BuildContext context) {
    if (!_reported) {
      _reported = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(ref.read(productEventServiceProvider).trackReviewOpened());
      });
    }
    return widget.child;
  }
}
