import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/sleep_quick_entry_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 没有历史睡眠记录时的兜底预填时段（小睡默认时段由 sheet 在切换类型时给出）。
const _defaultBedtime = TimeOfDay(hour: 23, minute: 0);
const _defaultWakeTime = TimeOfDay(hour: 7, minute: 0);

/// 一次性的睡眠快速录入：预填时段 → 打开 sheet → 落**一条**完整睡眠记录。
///
/// 记录归属日（`occurredAt`）为所选日期、时刻为起床时刻，即 wake-date 约定；
/// 时长由 sheet 里的就寝/起床时刻算出，随 payload 一起写入。
Future<void> handleSleepQuickEntry(
  BuildContext context,
  WidgetRef ref, {
  required DateTime selectedDate,
  required bool canAccessProtectedData,
  required bool isAuthLoading,
}) async {
  if (!canAccessProtectedData) {
    if (isAuthLoading) return;
    await showAuthRequiredDialog(
      context,
      onLogin: () => context.push(loginRouteForCurrentLocation(context)),
    );
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final prefill = await _resolvePrefill(ref, selectedDate);
  if (!context.mounted) return;

  final result = await showSleepQuickEntrySheet(
    context,
    recordDate: selectedDate,
    initialKind: prefill.kind,
    initialBedtime: prefill.bedtime,
    initialWakeTime: prefill.wakeTime,
  );
  if (result == null || !context.mounted) return;

  final payload = buildSleepPayload(
    recordDate: selectedDate,
    bedtime: result.bedtime,
    wakeTime: result.wakeTime,
    kind: result.kind,
    quality: result.quality,
  );
  if (payload == null) return;

  final repository = ref.read(dailyRecordRepositoryProvider);
  late final QuickEntryUndoAction undoAction;
  try {
    final item = await repository
        .create(
          DailyRecordCreateInput(
            kind: DailyRecordKind.sleep,
            occurredAt: formatRecordDate(selectedDate),
            occurredTime: formatHourMinute(
              result.wakeTime.hour,
              result.wakeTime.minute,
            ),
            note: result.note,
            payload: payload,
          ),
        )
        .run()
        .then((either) => either.fold((failure) => throw failure, (i) => i));
    undoAction = QuickEntryUndoAction.deleteDailyRecord(recordId: item.id);
  } catch (e, st) {
    ref
        .read(talkerProvider)
        .error('handleSleepQuickEntry create failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordCreateFailedToast);
    return;
  }

  ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
  if (!context.mounted) return;
  await Toast.showWithAction(
    context,
    l10n.recordQuickSavedToast,
    l10n.recordQuickUndoAction,
    // The undo action fires on a later user tap; the calling page may have
    // been popped in between, so guard before using the context (deactivated
    // context trips the `_dependents.isEmpty` assertion).
    () {
      if (!context.mounted) return;
      unawaited(undoDailyRecordQuickAction(context, ref, undoAction));
    },
  );
}

Future<void> undoDailyRecordQuickAction(
  BuildContext context,
  WidgetRef ref,
  QuickEntryUndoAction action,
) async {
  try {
    final repository = ref.read(dailyRecordRepositoryProvider);
    await QuickEntryUndoService(
      deleteDailyRecord: (recordId) async =>
          (await repository.delete(recordId).run()).fold(
            (failure) => throw failure,
            (_) {},
          ),
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
    ).undo(action);
  } catch (e, st) {
    ref.read(talkerProvider).error('undoDailyRecordQuickAction failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(
      context,
      AppLocalizations.of(context)!.recordQuickUndoFailedToast,
    );
  }
}

/// 预填时段：沿用所选日期（或其前一天）最近一条睡眠记录的类型与时刻；
/// 无历史时回落到夜间 23:00–07:00。读取失败只记日志，不阻断录入。
Future<({SleepEntryKind kind, TimeOfDay bedtime, TimeOfDay wakeTime})>
_resolvePrefill(WidgetRef ref, DateTime selectedDate) async {
  const fallback = (
    kind: SleepEntryKind.nightSleep,
    bedtime: _defaultBedtime,
    wakeTime: _defaultWakeTime,
  );

  List<DailyRecordItem> records;
  try {
    records = await _fetchRecentSleepRecords(ref, selectedDate);
  } catch (e, st) {
    ref.read(talkerProvider).error('sleep prefill fetch failed: $e', st);
    return fallback;
  }

  for (final record in records) {
    final bedtime = _clockOf(record.payload?['startedAt']);
    final wakeTime = _clockOf(record.payload?['endedAt']);
    if (bedtime != null && wakeTime != null) {
      return (
        kind: SleepEntryKind.fromPayload(record.payload?['sleepType']),
        bedtime: bedtime,
        wakeTime: wakeTime,
      );
    }
  }
  return fallback;
}

/// 所选日期与其前一天的睡眠记录，按事件时刻由新到旧排序。
Future<List<DailyRecordItem>> _fetchRecentSleepRecords(
  WidgetRef ref,
  DateTime selectedDate,
) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  final dates = [selectedDate.subtract(const Duration(days: 1)), selectedDate];
  final items = <DailyRecordItem>[];
  for (final date in dates) {
    final result = await repository
        .fetchRecords(
          formatRecordDate(date),
          kind: DailyRecordKind.sleep.name,
          pageSize: 20,
        )
        .run();
    result.fold((failure) => throw failure, (data) => items.addAll(data.items));
  }
  items.sort((a, b) => _eventAt(b).compareTo(_eventAt(a)));
  return items;
}

DateTime _eventAt(DailyRecordItem record) {
  for (final key in const ['endedAt', 'startedAt']) {
    // payload 是本地写入的 JSON，但类型仍可能被旧版本/异常数据写坏；
    // 非 String 时按"该键无值"处理，让循环落到下一个候选。
    final raw = record.payload?[key];
    final parsed = DateTime.tryParse(raw is String ? raw : '');
    if (parsed != null) return parsed;
  }
  return parseRecordDateTime(
        record.occurredAt,
        occurredTime: record.occurredTime,
      ) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

TimeOfDay? _clockOf(Object? value) {
  if (value is! String) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  final local = parsed.toLocal();
  return TimeOfDay(hour: local.hour, minute: local.minute);
}
