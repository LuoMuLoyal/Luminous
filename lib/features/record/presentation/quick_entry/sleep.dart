import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_sleep.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/quick_entry_providers.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/sleep_quick_entry_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// One-off sleep quick entry: prefill the sheet → open the sheet → write
/// **one** complete sleep record.
///
/// The pure half (prefill resolution + the write) lives in the application
/// layer's [SleepQuickEntryFlow]; this function owns the sheet and the toasts.
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
      onLogin: () => requestSignIn(context),
    );
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final flow = ref.read(sleepQuickEntryFlowProvider);
  final prefill = await flow.resolvePrefill(selectedDate);
  if (!context.mounted) return;

  final result = await showSleepQuickEntrySheet(
    context,
    recordDate: selectedDate,
    initialKind: prefill.kind,
    initialBedtime: prefill.bedtime,
    initialWakeTime: prefill.wakeTime,
  );
  if (result == null || !context.mounted) return;

  final outcome = await flow.saveDraft(
    recordDate: selectedDate,
    draft: SleepQuickEntryDraft(
      kind: result.kind,
      bedtime: result.bedtime,
      wakeTime: result.wakeTime,
      quality: result.quality,
      note: result.note,
    ),
  );
  if (!context.mounted) return;

  switch (outcome) {
    case SleepQuickEntryInvalidDraft():
      return;
    case SleepQuickEntryWriteFailed(:final error):
      ref
          .read(talkerProvider)
          .error('handleSleepQuickEntry create failed: $error');
      await Toast.show(context, l10n.recordCreateFailedToast);
    case SleepQuickEntrySaved(:final recordId):
      await Toast.showWithAction(
        context,
        l10n.recordQuickSavedToast,
        l10n.recordQuickUndoAction,
        // The undo action fires on a later user tap; the calling page may have
        // been popped in between, so guard before using the context (deactivated
        // context trips the `_dependents.isEmpty` assertion).
        () {
          if (!context.mounted) return;
          unawaited(
            undoDailyRecordQuickAction(
              context,
              ref,
              QuickEntryUndoAction.deleteDailyRecord(recordId: recordId),
            ),
          );
        },
      );
  }
}

/// Runs the "undo" command for a daily-record quick entry.
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
