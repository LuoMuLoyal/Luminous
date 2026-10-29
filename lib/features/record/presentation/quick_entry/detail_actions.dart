import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/application/usecases/record_detail_actions.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/quick_entry_providers.dart';
import 'package:luminous/features/record/presentation/routes.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/detail_labels.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Navigates to the record edit page for [recordId], showing an
/// auth-required dialog if the user is not signed in.
void editRecord(BuildContext context, String recordId) {
  unawaited(
    pushAuthRequiredRoute(context, RecordEditRoute(id: recordId).location),
  );
}

/// Deletes a daily record after user confirmation.
///
/// Shows a confirmation dialog, runs [DeleteRecordUseCase], invalidates the
/// detail provider, shows a toast, and pops [popCount] times.
Future<void> deleteRecord({
  required WidgetRef ref,
  required BuildContext context,
  required String recordId,
  required int popCount,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await _showDeleteConfirmDialog(context, l10n);
  if (confirmed != true) return;

  try {
    final outcome = await DeleteRecordUseCase(
      repository: ref.read(quickEntryDailyRecordWriterProvider),
      emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
    )(recordId);
    // A failed write is thrown by the writer; success is the only other state.
    assert(outcome is DeleteRecordSucceeded);
    ref.invalidate(dailyRecordDetailProvider(recordId));
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordDeletedToast);
    if (context.mounted) {
      for (var pop = 0; pop < popCount; pop++) {
        context.pop();
      }
    }
  } catch (e) {
    ref.read(talkerProvider).error('deleteRecord: failed: $e');
    if (context.mounted) {
      await Toast.show(context, l10n.recordDeleteFailedToast);
    }
  }
}

Future<bool?> _showDeleteConfirmDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showAppDialog<bool>(
    context: context,
    // Short content uses DialogShell default scrolling: no bottom overflow on
    // narrow screens with large text.
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordDeleteConfirmTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.recordDeleteConfirmMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        // Buttons are intrinsically sized: a Row would let them take their full
        // width and push the right edge out of the dialog.
        DialogActionRow(
          actions: [
            DialogActionButton(
              label: l10n.authCancelAction,
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
            ),
            DialogActionButton(
              key: const Key('record-delete-confirm-action'),
              label: l10n.recordDeleteAction,
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Re-runs AI analysis for a failed meal record the user wants to retry.
///
/// The server treats "a patch carrying exactly one image" as a new analysis
/// request (sourceRevision bumps and the job is re-enqueued), so the retry is
/// just re-submitting the record's existing image. On success the detail view
/// is refreshed in place; on failure the state is left untouched.
Future<void> retryMealAnalysis({
  required WidgetRef ref,
  required BuildContext context,
  required DailyRecordItem record,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final outcome = await RetryMealAnalysisUseCase(
    repository: ref.read(quickEntryDailyRecordWriterProvider),
    emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
  )(record);

  switch (outcome) {
    case RetryMealAnalysisNoImage():
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordMealAnalysisRetryFailedToast);
    case RetryMealAnalysisFailed(:final error):
      ref.read(talkerProvider).error('retryMealAnalysis: failed: $error');
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordMealAnalysisRetryFailedToast);
    case RetryMealAnalysisQueued():
      ref.invalidate(dailyRecordDetailProvider(record.id));
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordMealAnalysisRetryingToast);
  }
}

/// Copies a compact text summary of [record] to the clipboard and shows a
/// confirmation toast.
Future<void> copyRecordSummary(
  BuildContext context,
  AppLocalizations l10n,
  DailyRecordItem record,
) async {
  final sep = l10n.commonLabelValueSeparator;
  final lines = <String>[
    '${l10n.recordCreateFieldKind}$sep${kindLabel(l10n, record.kind)}',
    if (nonEmpty(record.value) != null)
      '${l10n.recordDetailValueLabel}$sep${valueWithUnit(record.value!, record.unit)}',
    if (moodLabel(l10n, record) != null)
      '${l10n.recordDetailMoodLabel}$sep${moodLabel(l10n, record)}',
    if (nonEmpty(record.note) != null)
      '${l10n.recordCreateFieldNote}$sep${record.note}',
    if (nonEmpty(record.source) != null)
      '${l10n.recordDetailSourceLabel}$sep${sourceLabel(l10n, record.source!)}',
    '${l10n.recordDetailUpdatedAtLabel}$sep${formatRecordDateTimeLabel(record.updatedAt)}',
  ];
  await Clipboard.setData(ClipboardData(text: lines.join('\n')));
  if (context.mounted) {
    await Toast.show(context, l10n.recordDetailCopiedToast);
  }
}
