import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';
import 'package:luminous/features/review/presentation/providers/trend.dart';
import 'package:luminous/features/review/presentation/utils/export_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/more_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/share_management.dart';
import 'package:luminous/features/review/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 第五 Tab 的 Review 页：以纵向洞察为主单位的洞察优先回顾首屏。
///
/// 主路径装配 周期开关 → 覆盖率概览 → 值得注意 → 单维趋势 → 事件回顾；
/// 数据来自 [reviewDashboardProvider]（metrics/trends/findings +
/// observedMetric 覆盖率）与 [reviewCurrentProvider] / [reviewLastCurrentProvider]
/// / [reviewHistoryProvider]。事件动作（开始观察 / check-in / 结束）已收口
/// Today（`health_event` + Today 装配），本页只做被动事件回顾与「去今日
/// check-in」浅链接；落库后由 DataChangeBus 驱动 review providers 自动刷新。
///
/// 旧 dashboard 视图（`dashboard_view.dart` 及其 sections、
/// `widgets/shared/top_bar.dart` 的 7/30 天切换）已从主路径移除（Task 7
/// 收尾），代码按兼容期保留、不再由本页装配——地位与保留范围见各文件头
/// 的 LEGACY 标注。
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(reviewCurrentProvider);
    ref.invalidate(reviewHistoryProvider);
    // 失败处理约定：page 层刷新不做 toast 也不重试——三个 provider 的
    // 失败已由各自 AsyncValue.error 承接并投影到对应 section 的错误视图；
    // 这里仅把异常落日志，避免下拉刷新在 500/断网时完全静默不可观测。
    final talker = ref.read(talkerProvider);
    await Future.wait([
      ref
          .read(reviewCurrentProvider.future)
          .then(
            (_) {},
            onError: (Object e, StackTrace st) =>
                talker.error('reviewCurrent refresh failed', e, st),
          ),
      ref
          .read(reviewHistoryProvider.future)
          .then(
            (_) {},
            onError: (Object e, StackTrace st) =>
                talker.error('reviewHistory refresh failed', e, st),
          ),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final canAccessProtectedData = session.canAccessProtectedData;
    final isPreview = session.isConfirmedSignedOut;

    final currentAsync = ref.watch(reviewCurrentProvider);
    final cachedReview = ref.watch(reviewLastCurrentProvider);
    final historyAsync = ref.watch(reviewHistoryProvider);
    final historyStatus = ref.watch(reviewHistoryStatusProvider);

    final dashboardQuery = ref.watch(reviewDashboardSelectedQueryProvider);
    final dashboardAsync = ref.watch(reviewDashboardProvider(dashboardQuery));

    // 将每次成功结果写入 reviewLastDashboardProvider 缓存。
    ref.listen<AsyncValue<ReviewDashboard>>(
      reviewDashboardProvider(dashboardQuery),
      (_, next) {
        next.whenData((dashboard) {
          ref.read(reviewLastDashboardProvider.notifier).set(dashboard);
        });
      },
    );
    final cachedDashboard = ref.watch(reviewLastDashboardProvider);

    // 加载中且无新数据时，展示上次成功缓存（stale），避免整页骨架。
    final effectiveDashboardAsync =
        dashboardAsync.isLoading &&
            !dashboardAsync.hasValue &&
            cachedDashboard != null
        ? AsyncValue<ReviewDashboard>.data(cachedDashboard)
        : dashboardAsync;

    final trendSeries =
        effectiveDashboardAsync.asData?.value.trends ?? const [];
    final dashboardStartDate =
        effectiveDashboardAsync.asData?.value.startDate ?? '----.--.--';
    // 覆盖率概览行数据：dashboard metrics（各健康维度覆盖小卡）。
    final coverageMetrics =
        effectiveDashboardAsync.asData?.value.metrics ?? const <ReviewMetric>[];
    // 值得注意区数据：dashboard findings 与数据窗口。
    final findings =
        effectiveDashboardAsync.asData?.value.findings ??
        const <ReviewFinding>[];
    final findingsWindowStart =
        effectiveDashboardAsync.asData?.value.startDate ?? '----.--.--';
    final findingsWindowEnd =
        effectiveDashboardAsync.asData?.value.endDate ?? '----.--.--';
    // 单维趋势卡当前选中的维度（覆盖概览行点击联动）。
    final selectedTrendKind = ref.watch(reviewTrendDimensionProvider);
    // 冷启动判定：无进行中事件且当前周期数据过稀（metrics 空 / 无足量覆盖
    // / 趋势全空）时，用记录引导卡替代「开始观察」动作（动作收口 Today）。
    final coldObserved = coverageMetrics
        .map((m) => m.observedMetric?.observedCount ?? 0)
        .fold(0, (a, b) => a > b ? a : b);
    final coldExpected = dashboardQuery.range == ReviewDashboardRange.last30Days
        ? 30
        : 7;
    final hasUsableCoverage = coverageMetrics.any(
      (m) =>
          m.observedMetric != null &&
          m.observedMetric!.coverage != ReviewObservedMetricCoverage.none &&
          m.observedMetric!.observedCount >= 2,
    );
    final isColdStart =
        coverageMetrics.isEmpty || (!hasUsableCoverage && trendSeries.isEmpty);

    return ShellDeferredContent(
      child: _ReviewOpenedTracker(
        child: _ReportMobileShell(
          onRefresh: () => _refresh(ref),
          header: _ReviewTopBar(
            onMore: () => unawaited(
              showReviewMoreActionsSheet(
                context,
                // 就诊摘要走共享导出处理的 clinicShare 分支（含登录守卫），
                // 与 PDF/打印保持一致，不另设副本。
                onVisitSummary: () => handleReviewExportAction(
                  context,
                  ref,
                  ReviewExportKind.clinicShare,
                ),
                onShareManagement: () async {
                  if (!ref.read(authSessionProvider).canAccessProtectedData) {
                    unawaited(pushAuthRequiredRoute(context, '/review'));
                    return;
                  }
                  await showShareManagementSheet(context);
                },
                onPdf: () => handleReviewExportAction(
                  context,
                  ref,
                  ReviewExportKind.monthly,
                ),
                onPrint: () => handleReviewExportAction(
                  context,
                  ref,
                  ReviewExportKind.print,
                ),
                onLegacyReport: () async {
                  await context.push(Routes.reviewLegacyDashboard);
                },
              ),
            ),
          ),
          child: ReviewView(
            currentAsync: currentAsync,
            cachedReview: cachedReview,
            historyAsync: historyAsync,
            historyStatus: historyStatus,
            onHistoryStatusChanged: (status) =>
                ref.read(reviewHistoryStatusProvider.notifier).select(status),
            canAccessProtectedData: canAccessProtectedData,
            isPreview: isPreview,
            onRetry: () => ref.invalidate(reviewCurrentProvider),
            onGoRecord: () => context.go(Routes.record),
            isColdStart: isColdStart,
            coldObserved: coldObserved,
            coldExpected: coldExpected,
            onGoTodayCheckIn: () => context.go(Routes.home),
            onSignIn: () => context.push(loginRouteForCurrentLocation(context)),
            onHistoryRetry: () => ref.invalidate(reviewHistoryProvider),
            onEventTap: (event) => context.push(
              Routes.reviewDetail.replaceAll(':eventId', event.id),
            ),
            onHistoryLoadMore: (cursor) async {
              final result = await ref
                  .read(reviewRepositoryProvider)
                  .fetchHistory(status: historyStatus, cursor: cursor)
                  .run();
              // Left 重抛，由 ReviewHistorySection 的既有 catch 投影为
              // 加载更多失败行（widget 不导入 fpdart、不读 code/status）。
              return result.fold((failure) => throw failure, (page) => page);
            },
            // 纵向洞察折线图：饮水/睡眠/用药单折线图。
            trendSeries: trendSeries,
            trendStartDate: dashboardStartDate,
            periodRange: dashboardQuery.range,
            onPeriodRangeChanged: (range) => ref
                .read(reviewDashboardSelectedQueryProvider.notifier)
                .setRange(range),
            coverageMetrics: coverageMetrics,
            findings: findings,
            findingsWindowStart: findingsWindowStart,
            findingsWindowEnd: findingsWindowEnd,
            selectedTrendKind: selectedTrendKind,
            onTrendKindChanged: (kind) =>
                ref.read(reviewTrendDimensionProvider.notifier).select(kind),
          ),
        ),
      ),
    );
  }
}

/// Records `review_opened` when the review data is actually presented to the
/// user — not on navigation taps, and never while the page is hidden.
///
/// Mechanism: the widget watches [reviewCurrentProvider]; flutter_riverpod
/// pauses widget subscriptions while the subtree is ticker-muted (inactive
/// shell branch), so this build only runs while the page is presented.
/// Each distinct [AsyncValue] instance (one per fetch completion, including
/// the confirmed no-event state) records at most once here — rebuilds with
/// the same instance (theme / history-filter rebuilds) do not re-emit — and
/// [ProductEventService.trackReviewOpened] further dedupes per session.
/// A fetch completing while the tab is hidden is buffered by the paused
/// subscription and delivered on the first visible build, so the user-visible
/// presentation still records.
class _ReviewOpenedTracker extends ConsumerStatefulWidget {
  const _ReviewOpenedTracker({required this.child});

  final Widget child;

  @override
  ConsumerState<_ReviewOpenedTracker> createState() =>
      _ReviewOpenedTrackerState();
}

class _ReviewOpenedTrackerState extends ConsumerState<_ReviewOpenedTracker> {
  /// The last [AsyncValue] instance already reported — identity comparison
  /// prevents rebuild re-emission.
  AsyncValue<EventReview?>? _lastPresented;

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(reviewCurrentProvider);
    // Muted tickers mean this subtree is not presented (hidden shell branch).
    // Riverpod already pauses the watch subscription there, but the explicit
    // check keeps offstage edge cases safe. Signed-out previews are excluded.
    if (TickerMode.valuesOf(context).enabled &&
        current.asData != null &&
        !identical(current, _lastPresented) &&
        ref.read(authSessionProvider).canAccessProtectedData) {
      _lastPresented = current;
      unawaited(ref.read(productEventServiceProvider).trackReviewOpened());
    }
    return widget.child;
  }
}

class _ReviewTopBar extends ConsumerWidget {
  const _ReviewTopBar({required this.onMore});

  /// 右上角「更多」入口：就诊摘要 / 分享管理 / PDF / 打印下载 / 兼容历史报告。
  final VoidCallback onMore;

  /// 顶栏 [问助手] 入口：与 today 顶栏助手入口同一语义——登录直接 push
  /// assistant，未登录走登录守卫（preview 沿用 assistant 未登录预览行为）。
  void _openAssistant(BuildContext context, WidgetRef ref) {
    final session = ref.read(authSessionProvider);
    if (session.canAccessProtectedData) {
      unawaited(context.push(Routes.assistant));
      return;
    }
    if (session.isLoading) {
      return;
    }
    unawaited(
      showAuthRequiredDialog(
        context,
        onLogin: () => context.push(loginRouteForReturnTo('/assistant')),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return FHeader.nested(
      title: Text(l10n.tabReview),
      suffixes: [
        FTooltip(
          tipBuilder: (context, controller) => Text(l10n.assistantEntryTitle),
          child: FButton.icon(
            key: const Key('review-assistant-entry'),
            onPress: () => _openAssistant(context, ref),
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            // 图标按钮无可见文字：给 TalkBack/VoiceOver 显式 label。
            semanticsLabel: l10n.assistantEntryTitle,
            child: SemanticIconSvg.aiEntry(),
          ),
        ),
        FTooltip(
          tipBuilder: (context, controller) => Text(l10n.reviewMoreTitle),
          child: FButton.icon(
            key: const Key('review-more-action'),
            onPress: onMore,
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.sm,
            // 图标按钮无可见文字：给 TalkBack/VoiceOver 显式 label，
            // 否则语义树里是空 label 的不可读按钮（Task 9 a11y 校验）。
            semanticsLabel: l10n.reviewMoreTitle,
            child: const Icon(SemanticIcons.actionMore),
          ),
        ),
      ],
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
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 顶栏语义后置（Task 9 a11y 顺序）：要求「事件标题 → 状态/结果 →
          // 四段 → 历史 → More」。Semantics sortKey 只调整语义遍历顺序，
          // 不影响视觉布局、焦点顺序与点击命中。
          Semantics(
            container: true,
            sortKey: const OrdinalSortKey(1),
            child: header,
          ),
          Expanded(
            child: Semantics(
              container: true,
              sortKey: const OrdinalSortKey(0),
              child: RefreshIndicator(
                onRefresh: onRefresh,
                // 桌面/平板端约束内容最大宽度，消除宽屏全宽长条；padding
                // 交由 ListView 自身管理，避免双重水平边距。
                child: ResponsiveContentFrame(
                  padding: EdgeInsets.zero,
                  child: ListView(
                    key: const PageStorageKey<String>('report-mobile-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.lg,
                      Spacing.lg,
                      Spacing.xl6,
                    ),
                    children: [child],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
