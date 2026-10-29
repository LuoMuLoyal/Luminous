import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/services/water_quick_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/quick_entry/quick_entry_providers.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/water_quick_entry_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Executes a one-tap water quick-entry from the Today quick-actions surface.
///
/// The record-write flow is the record feature's application-layer
/// [WaterQuickEntryFlow]; this function owns the auth gate, the amount sheet,
/// the toasts and the undo wiring.
Future<void> executeTodayWaterQuickEntry(
  BuildContext context,
  WidgetRef ref,
) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    if (session.isLoading) return;
    await showAuthRequiredDialog(
      context,
      onLogin: () {
        if (context.mounted) {
          unawaited(context.push(loginRouteForCurrentLocation(context)));
        }
      },
    );
    return;
  }

  final preferences =
      ref.read(quickEntryPreferencesProvider).asData?.value ??
      const QuickEntryPreferences();

  // Show the water amount sheet; the user picks a preset or enters a custom
  // ml amount. Dismissing the sheet records nothing.
  final result = await showWaterQuickEntrySheet(context);
  if (result == null || !context.mounted) return;

  QuickEntryUndoAction? undoAction;
  try {
    await WaterQuickEntryFlow(
      createRecord: ref.read(createDailyRecordProvider),
      emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
      registerUndo: (action) => undoAction = action,
    ).record(
      QuickEntryRecordContext(
        occurredAt: formatTodayDateKey(DateTime.now()),
        occurredTime: formatTodayTimeValue(DateTime.now()),
      ),
      preferences.copyWith(
        waterDefault: QuickEntryWaterDefault.custom,
        waterCustomMl: result.amountMl,
      ),
    );
  } catch (e, st) {
    ref
        .read(talkerProvider)
        .error('executeTodayWaterQuickEntry: failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(
      context,
      AppLocalizations.of(context)!.recordCreateFailedToast,
    );
    return;
  }

  final action = undoAction;
  if (!context.mounted || action == null) return;

  final l10n = AppLocalizations.of(context)!;
  await Toast.showWithAction(
    context,
    l10n.recordQuickSavedToast,
    l10n.recordQuickUndoAction,
    () {
      if (!context.mounted) return;
      unawaited(_undo(context, ref, action));
    },
  );
}

/// The record day (`yyyy-MM-dd`) for a Today tap.
String formatTodayDateKey(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

/// The record time (`HH:mm`) for a Today tap.
String formatTodayTimeValue(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

Future<void> _undo(
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
    ref
        .read(talkerProvider)
        .error('executeTodayWaterQuickEntry: undo failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(
      context,
      AppLocalizations.of(context)!.recordQuickUndoFailedToast,
    );
  }
}
