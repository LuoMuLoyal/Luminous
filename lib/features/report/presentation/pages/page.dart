import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_event/presentation/providers/active_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/providers/review.dart';
import 'package:luminous/features/report/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

/// 第五 Tab 的 Review 页：以健康事件为主单位的回顾首屏。
///
/// 数据来自 [reviewCurrentProvider] / [reviewLastCurrentProvider] /
/// [reviewHistoryProvider]；事件交互（开始观察 / check-in / 结束）复用
/// health_event 的 ActiveHealthEvent notifier 与 bottom sheet，服务端
/// 成功后由 DataChangeBus 驱动 review providers 自动刷新。
///
/// 旧 dashboard 视图（DashboardView 及其 section widgets）保留在各自文件中，
/// 但已不再从本页装配（Task 7 负责移除主路径引用并收尾）。
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
  /// 跟进项（Task 7/8 与 today 对齐）：当前只转发标题到 create，不提供
  /// 关联触发症状（reasonRecordId）与关联当前用药（currentMedicineIds）
  /// 的选项——today 的 `_openStart` 会从 health context snapshot 与当日
  /// 记录预读选项并转发参数，此处保持轻量，待 Review 交互与 More 收尾时
  /// 补齐（见 migration log 2026-08-13 Review Task 6 修复条目）。
  Future<void> _openStart(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    await showAppDialog<void>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => StartEventSheet(
        heading: l10n.todayHealthEventStartTitle,
        shortTitleLabel: l10n.todayHealthEventTitleLabel,
        hint: l10n.todayHealthEventTitleHint,
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
                  .create(title: shortTitle);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
      ),
    );
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
          final userTimezone = await _readUserTimezone(ref);
          await ref
              .read(activeHealthEventProvider.notifier)
              .checkIn(
                eventId: review.event.id,
                date: _localDateKey(DateTime.now(), timeZoneName: userTimezone),
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
    final review = currentAsync.asData?.value ?? cachedReview;

    return ShellDeferredContent(
      child: _ReportMobileShell(
        onRefresh: () => _refresh(ref),
        header: const _ReviewTopBar(),
        child: ReviewView(
          currentAsync: currentAsync,
          cachedReview: cachedReview,
          historyAsync: historyAsync,
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

Future<String?> _readUserTimezone(WidgetRef ref) async {
  final cached = ref.read(healthContextSnapshotProvider);
  if (cached.hasValue) return cached.value!.profile.timezone;
  try {
    return (await ref.read(
      healthContextSnapshotProvider.future,
    )).profile.timezone;
  } catch (_) {
    return null;
  }
}

String _localDateKey(DateTime date, {String? timeZoneName}) {
  const fallbackTimeZoneName = 'Asia/Shanghai';
  var value = date.toLocal();
  try {
    timezone_data.initializeTimeZones();
    value = timezone.TZDateTime.from(
      date.toUtc(),
      timezone.getLocation(
        timeZoneName == null || timeZoneName.isEmpty
            ? fallbackTimeZoneName
            : timeZoneName,
      ),
    );
  } catch (_) {
    // Keep the backend's default timezone when the bundled timezone data is
    // unavailable, rather than using a potentially different device date.
    value = date.toUtc().add(const Duration(hours: 8));
  }
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
