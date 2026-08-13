import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/local_date.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/providers/review.dart';
import 'package:luminous/features/report/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
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
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(reviewCurrentProvider);
    ref.invalidate(reviewHistoryProvider);
    await Future.wait([
      ref.read(reviewCurrentProvider.future).then((_) {}, onError: (_) {}),
      ref.read(reviewHistoryProvider.future).then((_) {}, onError: (_) {}),
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
      final today = DateTime.parse(
        localDateKey(DateTime.now(), timeZoneName: userTimezone),
      );
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

    return ShellDeferredContent(
      child: _ReportMobileShell(
        onRefresh: () => _refresh(ref),
        header: const _ReviewTopBar(),
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
          onStartObservation: () => _openStart(context, ref),
          onCheckIn: review == null
              ? () {}
              : () => _openCheckIn(context, ref, review),
          onEndEvent: review == null
              ? () {}
              : () => _openEnd(context, ref, review),
          onSignIn: () => context.push(loginRouteForCurrentLocation(context)),
          onHistoryRetry: () => ref.invalidate(reviewHistoryProvider),
        ),
      ),
    );
  }
}

class _ReviewTopBar extends StatelessWidget {
  const _ReviewTopBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FHeader.nested(title: Text(l10n.tabReport));
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
