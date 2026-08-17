import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Executes a one-tap water quick-entry from the Today quick-actions surface.
///
/// The flow reuses [WaterQuickEntryFlow] from the record feature's application
/// layer so the create/emit/undo semantics stay identical to the record-page
/// quick entry. It is gated by authentication: signed-out users see the auth
/// dialog instead of creating a record.
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
  final repository = ref.read(dailyRecordRepositoryProvider);

  QuickEntryUndoAction? undoAction;
  try {
    await WaterQuickEntryFlow(
      createRecord: repository.create,
      emitDataChange: (topic) {
        ref.read(dataChangeBusProvider.notifier).emit(topic);
      },
      registerUndo: (action) => undoAction = action,
    ).record(
      QuickEntryRecordContext(
        occurredAt: _formatDate(DateTime.now()),
        occurredTime: _formatTime(DateTime.now()),
      ),
      preferences,
    );
  } catch (e, st) {
    _logError('executeTodayWaterQuickEntry: failed: $e', st);
    if (!context.mounted) return;
    final l10n = _l10n(context);
    await Toast.show(context, l10n.recordCreateFailedToast);
    return;
  }

  final action = undoAction;
  if (!context.mounted || action == null) return;

  final l10n = _l10n(context);
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

Future<void> _undo(
  BuildContext context,
  WidgetRef ref,
  QuickEntryUndoAction action,
) async {
  try {
    final repository = ref.read(dailyRecordRepositoryProvider);
    await QuickEntryUndoService(
      deleteDailyRecord: repository.delete,
      emitDataChange: (topic) {
        ref.read(dataChangeBusProvider.notifier).emit(topic);
      },
    ).undo(action);
  } catch (e, st) {
    _logError('executeTodayWaterQuickEntry: undo failed: $e', st);
    if (!context.mounted) return;
    final l10n = _l10n(context);
    await Toast.show(context, l10n.recordQuickUndoFailedToast);
  }
}

String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

void _logError(String message, StackTrace? stackTrace) {
  // Keep the import light: log via debugPrint when assertions are enabled.
  assert(() {
    debugPrint(message);
    if (stackTrace != null) debugPrint(stackTrace.toString());
    return true;
  }());
}

AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;
