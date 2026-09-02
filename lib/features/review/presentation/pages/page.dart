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
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/core/utils/local_date.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/providers/ai_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';
import 'package:luminous/features/review/presentation/utils/export_actions.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/range_picker_dialog.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/suggestion_history_detail_sheet.dart';
import 'package:luminous/features/review/presentation/widgets/sections/suggestion_history.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/more_actions.dart';
import 'package:luminous/features/review/presentation/widgets/sheets/share_management.dart';
import 'package:luminous/features/review/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/features/today/data/providers/suggestion.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 第五 Tab 的 Review 页：以健康事件为主单位的回顾首屏。
///
/// 数据来自 [reviewCurrentProvider] / [reviewLastCurrentProvider] /
/// [reviewHistoryProvider]；事件交互（开始观察 / check-in / 结束）复用
/// health_event 的 ActiveHealthEvent notifier 与 bottom sheet，服务端
/// 成功后由 DataChangeBus 驱动 review providers 自动刷新。
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
    // 建议历史是 fetch 型数据源，纳入下拉刷新；AI 总结卡是用户触发的
    // 生成结果（生成成本高），保持独立生命周期——invalidate 会清掉已
    // 生成的摘要迫使用户重新生成，不纳入刷新范围（有意取舍）。
    ref.invalidate(suggestionHistoryProvider);
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
      ref
          .read(suggestionHistoryProvider.future)
          .then(
            (_) {},
            onError: (Object e, StackTrace st) =>
                talker.error('suggestionHistory refresh failed', e, st),
          ),
    ]);
  }

  /// 「开始健康观察」入口（无事件时）。
  ///
  /// 与 today 的 `_openStart` 对齐：从 health context snapshot 预读当前用药
  /// 选项、按用户时区的今天预读症状记录选项，并随创建请求转发
  /// `reasonRecordId` / `currentMedicineIds`。选项加载失败时静默降级为
  /// 空列表，不阻塞开始观察。创建成功后由 DataChangeBus（healthEvents
  /// topic）驱动 review providers 自动刷新，无需手动 refresh。
  Future<void> _openStart(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // 两类选项并行读取（happy path 等待减半），最坏等待取两条链路的
    // 较大值而非之和；读取失败时各自静默降级为空列表，不阻塞开始观察。
    final (currentMedicineOptions, reasonRecordOptions) = await (
      _readCurrentMedicineOptions(ref),
      _readReasonRecordOptions(ref),
    ).wait;
    if (!context.mounted) return;
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => StartEventSheet(
        heading: l10n.todayHealthEventStartTitle,
        shortTitleLabel: l10n.todayHealthEventTitleLabel,
        hint: l10n.todayHealthEventTitleHint,
        currentMedicineLabel: l10n.todayHealthEventCurrentMedicineLabel,
        currentMedicineOptions: currentMedicineOptions,
        reasonRecordLabel: l10n.todayHealthEventReasonRecordLabel,
        reasonRecordOptions: reasonRecordOptions,
        cancelLabel: l10n.todayHealthEventCancelAction,
        submitLabel: l10n.todayHealthEventStartAction,
        submittingLabel: l10n.todayHealthEventSaveAction,
        requiredMessage: l10n.todayHealthEventTitleRequired,
        submitErrorLabel: l10n.todayHealthEventSaveFailed,
        onSubmit:
            ({
              required shortTitle,
              reasonRecordId,
              required currentMedicineIds,
            }) async {
              await ref
                  .read(activeHealthEventProvider.notifier)
                  .create(
                    title: shortTitle,
                    reasonRecordId: reasonRecordId,
                    currentMedicineIds: currentMedicineIds,
                  );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
      ),
    );
  }

  Future<List<HealthEventAssociationOption>> _readCurrentMedicineOptions(
    WidgetRef ref,
  ) async {
    try {
      final snapshot = await ref
          .read(healthContextSnapshotProvider.future)
          .timeout(const Duration(seconds: 2));
      return snapshot.currentMedicines
          .where((medicine) => medicine.isCurrent)
          .map(
            (medicine) => HealthEventAssociationOption(
              id: medicine.id,
              label: medicine.displayName,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<HealthEventAssociationOption>> _readReasonRecordOptions(
    WidgetRef ref,
  ) async {
    try {
      // 时区读取单独加 2s 客户端上限：这是有意的快速降级取舍——选项读取
      // 失败只影响「开始观察」弹窗里的可选关联项，静默降级为空列表即可，
      // 不应被 health context provider 自身的 5s 超时拖住整个弹窗。
      final userTimezone = await readUserTimezone(
        ref,
      ).timeout(const Duration(seconds: 2));
      // localDateKey 返回 `yyyy-MM-dd` 日期键；不再裸用 DateTime.parse——
      // FormatException 会被外层 catch 整体吞掉、丢掉已读到的选项数据，
      // 改为可空解析并在 null 时与 catch 同口径降级为空选项列表。
      final today = parseDateTimeOrNull(
        localDateKey(DateTime.now(), timeZoneName: userTimezone),
      );
      if (today == null) return const [];
      final records = await ref
          .read(dailyRecordListForDateProvider(today).future)
          .timeout(const Duration(seconds: 2));
      return records.items
          .where((record) => record.kind == DailyRecordKind.symptom)
          .map((record) {
            final label = [record.title, record.value, record.note]
                .map((value) => value?.trim())
                .whereType<String>()
                .firstWhere((value) => value.isNotEmpty, orElse: () => '');
            return (record: record, label: label);
          })
          .where((item) => item.label.isNotEmpty)
          .map(
            (item) => HealthEventAssociationOption(
              id: item.record.id,
              label: item.label,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _openCheckIn(
    BuildContext context,
    WidgetRef ref,
    EventReview review,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => CheckInSheet(
        heading: l10n.todayHealthEventCheckInTitle,
        subtitle: l10n.todayHealthEventCheckInSubtitle,
        improvedLabel: l10n.todayHealthEventImproved,
        unchangedLabel: l10n.todayHealthEventUnchanged,
        worsenedLabel: l10n.todayHealthEventWorsened,
        cancelLabel: l10n.todayHealthEventCancelAction,
        submitLabel: l10n.todayHealthEventCheckInAction,
        submittingLabel: l10n.todayHealthEventSaveAction,
        requiredMessage: l10n.todayHealthEventOutcomeRequired,
        submitErrorLabel: l10n.todayHealthEventSaveFailed,
        onSubmit: (outcome) async {
          final userTimezone = await readUserTimezone(ref);
          await ref
              .read(activeHealthEventProvider.notifier)
              .checkIn(
                eventId: review.event.id,
                date: localDateKey(DateTime.now(), timeZoneName: userTimezone),
                outcome: outcome,
              );
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> _openEnd(
    BuildContext context,
    WidgetRef ref,
    EventReview review,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => EndEventSheet(
        heading: l10n.todayHealthEventEndTitle,
        subtitle: l10n.todayHealthEventEndSubtitle,
        improvedLabel: l10n.todayHealthEventImproved,
        unchangedLabel: l10n.todayHealthEventUnchanged,
        worsenedLabel: l10n.todayHealthEventWorsened,
        cancelLabel: l10n.todayHealthEventCancelAction,
        submitLabel: l10n.todayHealthEventEndAction,
        submittingLabel: l10n.todayHealthEventSaveAction,
        requiredMessage: l10n.todayHealthEventOutcomeRequired,
        submitErrorLabel: l10n.todayHealthEventSaveFailed,
        onSubmit: (outcome) async {
          await ref
              .read(activeHealthEventProvider.notifier)
              .end(eventId: review.event.id, outcome: outcome);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  /// AI 总结范围切换：7/30 天直接生效；「自定义」先弹日历选区间，取消则
  /// 保持原范围（不产生“选了自定义却无区间”的死路）。选中的区间写入
  /// [reviewDashboardSelectedQueryProvider]——该 provider 同时是 legacy
  /// 报表的日期状态，主路径不装配 legacy 报表，写入无副作用；AI 生成请求
  /// 从这里读取自定义区间的起止日期。
  Future<void> _changeAiSummaryRange(
    BuildContext context,
    WidgetRef ref,
    ReviewAiSummaryRange range,
  ) async {
    if (range != ReviewAiSummaryRange.custom) {
      ref.read(reviewAiSummarySelectedRangeProvider.notifier).setRange(range);
      return;
    }
    final picked = await showReviewCalendarPicker(
      context,
      selectedQuery: ref.read(reviewDashboardSelectedQueryProvider),
    );
    if (picked == null || !context.mounted) return;
    final startDate = picked.startDate;
    final endDate = picked.endDate;
    if (startDate == null || endDate == null) return;
    ref
        .read(reviewDashboardSelectedQueryProvider.notifier)
        .setCustomRange(startDate, endDate);
    ref
        .read(reviewAiSummarySelectedRangeProvider.notifier)
        .setRange(ReviewAiSummaryRange.custom);
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
    final review = currentAsync.asData?.value ?? cachedReview;

    // AI 总结 providers——仅登录用户可见。
    final aiSummariesEnabled = canAccessProtectedData
        ? ref.watch(
            userSettingsControllerProvider.select(
              (s) => s.asData?.value.aiSummariesEnabled,
            ),
          )
        : null;
    final aiSummarySelectedRange = canAccessProtectedData
        ? ref.watch(reviewAiSummarySelectedRangeProvider)
        : null;
    final aiSummaryState = canAccessProtectedData
        ? ref.watch(reviewAiSummaryControllerProvider(aiSummarySelectedRange!))
        : null;

    // 建议历史 providers——仅登录用户可见。去重与截断展示由 section 承担，
    // 这里传去重后的全量列表。
    final suggestionHistoryAsync = canAccessProtectedData
        ? ref.watch(suggestionHistoryProvider)
        : null;
    final suggestionHistory = canAccessProtectedData
        ? dedupeTodaySuggestions(
            suggestionHistoryAsync?.asData?.value?.items ?? const [],
          )
        : const <TodaySuggestionHistoryItem>[];
    final isSuggestionHistoryLoading =
        suggestionHistoryAsync?.isLoading ?? false;

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
            aiSummaryState: aiSummaryState,
            aiSummarySelectedRange: aiSummarySelectedRange,
            aiSummariesEnabled: aiSummariesEnabled,
            onAiSummaryRangeChanged: (range) =>
                unawaited(_changeAiSummaryRange(context, ref, range)),
            onGenerateAiSummary: () async {
              await ref
                  .read(
                    reviewAiSummaryControllerProvider(
                      aiSummarySelectedRange!,
                    ).notifier,
                  )
                  .generate();
            },
            suggestionHistory: suggestionHistory,
            isSuggestionHistoryLoading: isSuggestionHistoryLoading,
            onSuggestionTap: (item) =>
                showSuggestionHistoryDetailSheet(context, suggestion: item),
            onRetry: () => ref.invalidate(reviewCurrentProvider),
            onStartObservation: () => _openStart(context, ref),
            onCheckIn: review == null
                ? () {}
                : () => _openCheckIn(context, ref, review),
            onEndEvent: review == null
                ? () {}
                : () => _openEnd(context, ref, review),
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

class _ReviewTopBar extends StatelessWidget {
  const _ReviewTopBar({required this.onMore});

  /// 右上角「更多」入口：就诊摘要 / 分享管理 / PDF / 打印下载 / 兼容历史报告。
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FHeader.nested(
      title: Text(l10n.tabReview),
      suffixes: [
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
                      Spacing.level4,
                      Spacing.level4,
                      Spacing.level4,
                      Spacing.level10,
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
