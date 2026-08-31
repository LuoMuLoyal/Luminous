import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/presentation/quick_entry/medication_flow.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<void> undoMedicationQuickAction(
  BuildContext context,
  WidgetRef ref,
  QuickEntryUndoAction action,
  String date,
) async {
  try {
    final repository = ref.read(dailyRecordRepositoryProvider);
    await QuickEntryUndoService(
      deleteDailyRecord: (recordId) async =>
          (await repository.delete(recordId).run()).fold(
            (failure) => throw failure,
            (_) {},
          ),
      deleteDoseLog: (doseLogId) async {
        final result = await ref
            .read(doseLogRepositoryProvider)
            .delete(doseLogId, date: date)
            .run();
        result.fold((failure) => throw failure, (_) {});
      },
      updateDoseLogStatus: (doseLogId, status) async {
        final result = await ref
            .read(doseLogRepositoryProvider)
            .update(doseLogId, status)
            .run();
        result.fold((failure) => throw failure, (_) {});
      },
      emitDataChange: (topic) =>
          ref.read(dataChangeBusProvider.notifier).emit(topic),
    ).undo(action);
  } catch (e, st) {
    ref.read(talkerProvider).error('undoMedicationQuickAction failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(
      context,
      AppLocalizations.of(context)!.recordQuickUndoFailedToast,
    );
  }
}

Future<void> showNoMedicationPrompt(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final add = await showAppDialog<bool>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    scrollable: false,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordQuickMedicationNoMedicinesTitle,
          style: context.theme.typography.body.lg,
        ),
        const SizedBox(height: Spacing.level3),
        Text(
          l10n.recordQuickMedicationNoMedicinesBody,
          style: context.theme.typography.body.sm,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: () => Navigator.of(context).pop(true),
              child: Text(l10n.recordQuickMedicationAddAction),
            ),
          ],
        ),
      ],
    ),
  );

  if (add == true && context.mounted) {
    unawaited(context.push(Routes.medicineSearch));
  }
}

Future<void> showMedicationSelectionDialog(
  BuildContext context, {
  required MedicationQuickEntryFlow flow,
  required MedicationQuickEntryContext contextData,
  required MedicationQuickSelection selection,
  required Future<void> Function(QuickEntryUndoAction action) onUndo,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final selected = {...selection.defaultSelectedIds};
  var saving = false;

  await showAppDialog<void>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    scrollable: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final selectedChoices = selection.choices
            .where((choice) => selected.contains(choice.id))
            .toList(growable: false);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordQuickMedicationSelectTitle,
              style: dialogContext.theme.typography.body.lg,
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                for (final choice in selection.choices)
                  FButton(
                    variant: selected.contains(choice.id)
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    onPress: saving
                        ? null
                        : () => setDialogState(() {
                            if (selected.contains(choice.id)) {
                              selected.remove(choice.id);
                            } else {
                              selected.add(choice.id);
                            }
                          }),
                    child: Text(choice.name),
                  ),
              ],
            ),
            if (saving) ...[
              const SizedBox(height: Spacing.level4),
              const Center(child: FProgress()),
            ],
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  onPress: saving || selectedChoices.isEmpty
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          final result = await flow.recordConfirmedSelection(
                            context: contextData,
                            choices: selectedChoices,
                          );
                          if (!dialogContext.mounted) return;
                          if (result.failed.isEmpty) {
                            final batchUndo = result.undoActions.isEmpty
                                ? null
                                : QuickEntryUndoAction.batch(
                                    actions: result.undoActions,
                                  );
                            Navigator.of(dialogContext).pop();
                            if (!context.mounted) return;
                            if (batchUndo == null) {
                              unawaited(
                                Toast.show(
                                  context,
                                  l10n.recordCreateSavedToast,
                                ),
                              );
                            } else {
                              unawaited(
                                Toast.showWithAction(
                                  context,
                                  l10n.recordQuickMedicationTemporaryToast,
                                  l10n.recordQuickUndoAction,
                                  // The undo action fires on a later user
                                  // tap; the dialog may have been
                                  // dismissed in between, so guard before
                                  // using the context (deactivated context
                                  // trips the `_dependents.isEmpty`
                                  // assertion).
                                  () {
                                    if (!context.mounted) return;
                                    unawaited(onUndo(batchUndo));
                                  },
                                ),
                              );
                            }
                            return;
                          }
                          final failedIds = result.failed
                              .map((choice) => choice.id)
                              .toSet();
                          setDialogState(() {
                            saving = false;
                            selected
                              ..clear()
                              ..addAll(failedIds);
                          });
                          unawaited(
                            Toast.show(
                              context,
                              l10n.recordQuickMedicationPartialFailedToast(
                                result.succeeded.length,
                                result.failed.length,
                              ),
                            ),
                          );
                        },
                  child: Text(l10n.commonConfirm),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

Future<void> handleMedicationQuickAction(
  BuildContext context,
  WidgetRef ref, {
  required DateTime now,
  required String occurredAt,
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
  final prefs =
      ref.read(quickEntryPreferencesProvider).asData?.value ??
      const QuickEntryPreferences();
  QuickEntryUndoAction? undoAction;
  final flow = MedicationQuickEntryFlow(
    markDose: (input) async {
      final result = await ref
          .read(doseLogRepositoryProvider)
          .mark(
            currentMedicineId: input.currentMedicineId,
            status: input.status,
            date: input.date,
            reminderId: input.reminderId,
            scheduledTime: input.scheduledTime,
          )
          .run();
      return result.fold((failure) => throw failure, (item) => item);
    },
    emitDataChange: (topic) =>
        ref.read(dataChangeBusProvider.notifier).emit(topic),
    registerUndo: (action) => undoAction = action,
  );

  late final MedicationQuickEntryOutcome outcome;
  try {
    final snapshot = await ref.read(healthContextSnapshotProvider.future);
    final remindersResult = await ref
        .read(reminderRepositoryProvider)
        .fetchAll()
        .run();
    final reminders = remindersResult.fold(
      (failure) => throw failure,
      (items) => items,
    );
    final todayLogsResult = await ref
        .read(doseLogRepositoryProvider)
        .fetchForDate(occurredAt)
        .run();
    final todayLogs = todayLogsResult.fold(
      (failure) => throw failure,
      (logs) => logs,
    );
    outcome = await flow.handleTap(
      context: MedicationQuickEntryContext(date: occurredAt, now: now),
      currentMedicines: snapshot.currentMedicines,
      reminders: reminders,
      todayLogs: todayLogs,
      autoRecordSingle: prefs.medicationAutoRecordSingle,
    );
  } catch (e, st) {
    ref
        .read(talkerProvider)
        .error('handleMedicationQuickAction load failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordQuickMedicationLoadFailedToast);
    return;
  }

  if (!context.mounted) return;
  switch (outcome.type) {
    case MedicationQuickEntryOutcomeType.noCurrentMedicines:
      await showNoMedicationPrompt(context);
    case MedicationQuickEntryOutcomeType.alreadyRecorded:
      if (prefs.medicationShowAlreadyRecordedHint) {
        await Toast.show(
          context,
          l10n.recordQuickMedicationAlreadyRecordedToast,
        );
      }
    case MedicationQuickEntryOutcomeType.recordedSingle:
      final action = undoAction;
      if (action == null) {
        await Toast.show(context, l10n.recordQuickSavedToast);
        return;
      }
      await Toast.showWithAction(
        context,
        l10n.recordQuickSavedToast,
        l10n.recordQuickUndoAction,
        // The undo action fires on a later user tap; the calling page
        // may have been popped in between, so guard before using the
        // context (deactivated context trips the
        // `_dependents.isEmpty` assertion).
        () {
          if (!context.mounted) return;
          unawaited(
            undoMedicationQuickAction(context, ref, action, occurredAt),
          );
        },
      );
    case MedicationQuickEntryOutcomeType.recordedTemporary:
      final action = undoAction;
      if (action == null) {
        await Toast.show(context, l10n.recordQuickMedicationTemporaryToast);
        return;
      }
      await Toast.showWithAction(
        context,
        l10n.recordQuickMedicationTemporaryToast,
        l10n.recordQuickUndoAction,
        // The undo action fires on a later user tap; the calling page
        // may have been popped in between, so guard before using the
        // context (deactivated context trips the
        // `_dependents.isEmpty` assertion).
        () {
          if (!context.mounted) return;
          unawaited(
            undoMedicationQuickAction(context, ref, action, occurredAt),
          );
        },
      );
    case MedicationQuickEntryOutcomeType.needsSelection:
      final selection = outcome.selection;
      if (selection == null) return;
      await showMedicationSelectionDialog(
        context,
        flow: flow,
        contextData: MedicationQuickEntryContext(date: occurredAt, now: now),
        selection: selection,
        onUndo: (action) =>
            undoMedicationQuickAction(context, ref, action, occurredAt),
      );
  }
}
