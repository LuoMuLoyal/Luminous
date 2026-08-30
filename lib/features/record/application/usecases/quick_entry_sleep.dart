import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/sleep_flow.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/sleep_merge.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

String sleepEventLabel(DailyRecordItem record) {
  final eventAt = SleepQuickEntryFlow.eventAtForRecord(record);
  if (eventAt == null) {
    return formatRecordDateTimeLabel(
      record.occurredAt,
      occurredTime: record.occurredTime,
    );
  }
  return formatRecordDateTimeLabel(
    formatRecordDate(eventAt.toLocal()),
    occurredTime: formatRecordTimeValue(eventAt.toLocal()),
  );
}

String formatSleepDuration(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h${l10n.todayVitalSleepUnit}';
  return '$h${l10n.todayVitalSleepUnit} $m${l10n.recordSleepMinutesUnit}';
}

Future<List<DailyRecordItem>> fetchSleepQuickCandidates(
  WidgetRef ref,
  DateTime selectedDate,
) async {
  final repository = ref.read(dailyRecordRepositoryProvider);
  final dates = [selectedDate.subtract(const Duration(days: 1)), selectedDate];
  final lists = await Future.wait(
    dates.map((date) async {
      final result = await repository
          .fetchRecords(
            formatRecordDate(date),
            kind: DailyRecordKind.sleep.name,
            pageSize: 100,
          )
          .run();
      return result.fold((failure) => throw failure, (data) => data);
    }),
  );
  return [for (final list in lists) ...list.items];
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

Future<SleepQuickEntryStartOptions?> showSleepTypeSelectionDialog(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context)!;
  final durationController = TextEditingController();
  var sleepType = 'nightSleep';
  String? quality;
  try {
    return await showAppDialog<SleepQuickEntryStartOptions>(
      context: context,
      maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
      scrollable: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordQuickSleepTypeTitle,
              style: dialogContext.theme.typography.body.lg,
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    key: const Key('record-quick-sleep-night-type'),
                    variant: sleepType == 'nightSleep'
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    onPress: () =>
                        setDialogState(() => sleepType = 'nightSleep'),
                    child: Text(l10n.recordQuickSleepNightAction),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: FButton(
                    key: const Key('record-quick-sleep-nap-type'),
                    variant: sleepType == 'nap'
                        ? FButtonVariant.primary
                        : FButtonVariant.outline,
                    onPress: () => setDialogState(() => sleepType = 'nap'),
                    child: Text(l10n.recordQuickSleepNapAction),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            FTextField(
              key: const Key('record-quick-sleep-approximate-duration'),
              control: FTextFieldControl.managed(
                controller: durationController,
              ),
              label: Text(l10n.recordQuickSleepApproximateDurationLabel),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: Spacing.level3),
            FSelect<String>.rich(
              key: const Key('record-quick-sleep-quality'),
              label: Text(l10n.recordSleepQualityLabel),
              hint: l10n.recordSleepQualityLabel,
              format: (value) => sleepQualityOptions(
                l10n,
              ).firstWhere((option) => option.key == value).label,
              control: FSelectControl.lifted(
                value: quality,
                onChange: (value) => setDialogState(() => quality = value),
              ),
              children: sleepQualityOptions(l10n)
                  .map(
                    (option) => FSelectItem.item(
                      title: Text(option.label),
                      value: option.key,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  onPress: () {
                    final parsed = int.tryParse(durationController.text.trim());
                    Navigator.of(dialogContext).pop(
                      SleepQuickEntryStartOptions(
                        sleepType: sleepType,
                        approximateDurationMinutes: parsed != null && parsed > 0
                            ? parsed
                            : null,
                        quality: quality,
                      ),
                    );
                  },
                  child: Text(l10n.commonConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } finally {
    durationController.dispose();
  }
}

Future<void> showSleepStartSelectionDialog(
  BuildContext context, {
  required SleepQuickEntryFlow flow,
  required SleepQuickEntryContext contextData,
  required List<DailyRecordItem> openStarts,
  required WidgetRef ref,
}) async {
  final l10n = AppLocalizations.of(context)!;
  var saving = false;

  await showAppDialog<void>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    scrollable: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordQuickSleepSelectStartTitle,
              style: dialogContext.theme.typography.body.lg,
            ),
            const SizedBox(height: Spacing.level4),
            for (final start in openStarts) ...[
              FButton(
                key: Key('record-quick-sleep-start-${start.id}'),
                variant: FButtonVariant.outline,
                onPress: saving
                    ? null
                    : () async {
                        setDialogState(() => saving = true);
                        late final SleepQuickEntryOutcome outcome;
                        try {
                          outcome = await flow.recordWakeForStart(
                            context: contextData,
                            startRecord: start,
                          );
                        } catch (e, st) {
                          ref
                              .read(talkerProvider)
                              .error('recordWakeForStart failed: $e', st);
                          if (!dialogContext.mounted) return;
                          setDialogState(() => saving = false);
                          unawaited(
                            Toast.show(context, l10n.recordCreateFailedToast),
                          );
                          return;
                        }
                        if (!dialogContext.mounted) return;
                        if (outcome.type ==
                            SleepQuickEntryOutcomeType.invalidDuration) {
                          setDialogState(() => saving = false);
                          unawaited(
                            Toast.show(
                              context,
                              l10n.recordQuickSleepInvalidDurationToast,
                            ),
                          );
                          return;
                        }
                        final merge = outcome.merge;
                        Navigator.of(dialogContext).pop();
                        if (merge != null && context.mounted) {
                          await showSleepMergeDialog(
                            context,
                            flow: flow,
                            merge: merge,
                            ref: ref,
                          );
                        }
                      },
                child: Text(sleepEventLabel(start)),
              ),
              const SizedBox(height: Spacing.level3),
            ],
            if (saving) ...[
              const SizedBox(height: Spacing.level2),
              const Center(child: FProgress()),
            ],
            const SizedBox(height: Spacing.level2),
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
              ],
            ),
          ],
        );
      },
    ),
  );
}

Future<void> showSleepMergeDialog(
  BuildContext context, {
  required SleepQuickEntryFlow flow,
  required SleepQuickEntryMerge merge,
  required WidgetRef ref,
}) async {
  final l10n = AppLocalizations.of(context)!;
  var saving = false;

  await showAppDialog<void>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    scrollable: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordQuickSleepMergeTitle,
              style: dialogContext.theme.typography.body.lg,
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              l10n.recordQuickSleepMergeBody,
              style: dialogContext.theme.typography.body.sm,
            ),
            const SizedBox(height: Spacing.level4),
            SleepMergeSummaryRow(
              label: l10n.recordQuickSleepStartLabel,
              value: sleepEventLabel(merge.startRecord),
            ),
            const SizedBox(height: Spacing.level2),
            SleepMergeSummaryRow(
              label: l10n.recordQuickSleepWakeLabel,
              value: sleepEventLabel(merge.wakeRecord),
            ),
            const SizedBox(height: Spacing.level2),
            SleepMergeSummaryRow(
              label: l10n.recordSleepDurationLabel,
              value: formatSleepDuration(merge.durationMinutes, l10n),
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
                  child: Text(l10n.recordQuickSleepKeepSeparateAction),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  onPress: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          try {
                            await flow.confirmMerge(merge);
                          } catch (e, st) {
                            ref
                                .read(talkerProvider)
                                .error('confirmMerge failed: $e', st);
                            if (!dialogContext.mounted) return;
                            setDialogState(() => saving = false);
                            unawaited(
                              Toast.show(context, l10n.recordCreateFailedToast),
                            );
                            return;
                          }
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          unawaited(
                            Toast.show(context, l10n.recordCreateSavedToast),
                          );
                        },
                  child: Text(l10n.recordQuickSleepMergeAction),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

Future<void> handleSleepQuickAction(
  BuildContext context,
  WidgetRef ref, {
  required DateTime selectedDate,
  required DateTime now,
  required String occurredAt,
  required String occurredTime,
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
  final repository = ref.read(dailyRecordRepositoryProvider);
  QuickEntryUndoAction? undoAction;
  final flow = SleepQuickEntryFlow(
    createRecord: (input) async => (await repository.create(input).run()).fold(
      (failure) => throw failure,
      (item) => item,
    ),
    deleteRecord: (recordId) async => (await repository.delete(recordId).run())
        .fold((failure) => throw failure, (_) {}),
    emitDataChange: (topic) =>
        ref.read(dataChangeBusProvider.notifier).emit(topic),
    registerUndo: (action) => undoAction = action,
  );

  late final List<DailyRecordItem> records;
  try {
    records = await fetchSleepQuickCandidates(ref, selectedDate);
  } catch (e, st) {
    ref.read(talkerProvider).error('fetchSleepQuickCandidates failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordQuickSleepLoadFailedToast);
    return;
  }

  var sleepType = 'nightSleep';
  int? approximateDurationMinutes;
  String? quality;
  if (SleepQuickEntryFlow.findOpenStarts(records).isEmpty) {
    if (!context.mounted) return;
    final selectedOptions = await showSleepTypeSelectionDialog(context);
    if (!context.mounted || selectedOptions == null) return;
    sleepType = selectedOptions.sleepType;
    approximateDurationMinutes = selectedOptions.approximateDurationMinutes;
    quality = selectedOptions.quality;
  }

  late final SleepQuickEntryOutcome outcome;
  try {
    outcome = await flow.handleTap(
      context: SleepQuickEntryContext(
        occurredAt: occurredAt,
        occurredTime: occurredTime,
        now: now,
        sleepType: sleepType,
        approximateDurationMinutes: approximateDurationMinutes,
        quality: quality,
      ),
      candidateRecords: records,
    );
  } catch (e, st) {
    ref.read(talkerProvider).error('sleep flow handleTap failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordCreateFailedToast);
    return;
  }

  if (!context.mounted) return;
  switch (outcome.type) {
    case SleepQuickEntryOutcomeType.started:
      final action = undoAction;
      if (action == null) {
        await Toast.show(context, l10n.recordQuickSleepStartedToast);
        return;
      }
      await Toast.showWithAction(
        context,
        l10n.recordQuickSleepStartedToast,
        l10n.recordQuickUndoAction,
        // The undo action fires on a later user tap; the calling page
        // may have been popped in between, so guard before using the
        // context (deactivated context trips the
        // `_dependents.isEmpty` assertion).
        () {
          if (!context.mounted) return;
          unawaited(undoDailyRecordQuickAction(context, ref, action));
        },
      );
    case SleepQuickEntryOutcomeType.wakeRecorded:
      final merge = outcome.merge;
      if (merge == null) return;
      await showSleepMergeDialog(context, flow: flow, merge: merge, ref: ref);
    case SleepQuickEntryOutcomeType.needsStartSelection:
      await showSleepStartSelectionDialog(
        context,
        flow: flow,
        contextData: SleepQuickEntryContext(
          occurredAt: occurredAt,
          occurredTime: occurredTime,
          now: now,
        ),
        openStarts: outcome.openStarts,
        ref: ref,
      );
    case SleepQuickEntryOutcomeType.invalidDuration:
      await Toast.show(context, l10n.recordQuickSleepInvalidDurationToast);
  }
}
