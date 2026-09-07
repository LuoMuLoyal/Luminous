import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
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
/// Shows a confirmation dialog, calls the repository, invalidates
/// the detail provider, emits a [DataChangeTopic.dailyRecords] event,
/// shows a toast, and pops [popCount] times.
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
    final result = await ref
        .read(dailyRecordRepositoryProvider)
        .delete(recordId)
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(dailyRecordDetailProvider(recordId));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordDeletedToast);
    if (context.mounted) {
      for (var i = 0; i < popCount; i++) {
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
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordDeleteConfirmTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.recordDeleteConfirmMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.authCancelAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('record-delete-confirm-action'),
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordDeleteAction),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Confirms the meal-analysis result in place, reusing the same PATCH
/// `analysisStatus='confirmed'` chain as the edit page. On success the
/// detail provider is invalidated so the badge flips to confirmed and the
/// DataChangeBus broadcasts [DataChangeTopic.dailyRecords] so keepAlive
/// dashboards (e.g. the record timeline) refresh; on failure the state is
/// untouched and an error toast is shown.
Future<void> confirmMealAnalysis({
  required WidgetRef ref,
  required BuildContext context,
  required String recordId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final result = await ref
        .read(dailyRecordRepositoryProvider)
        .update(
          recordId,
          const DailyRecordUpdateInput(
            payload: <String, dynamic>{
              'mealAnalysis': <String, dynamic>{'analysisStatus': 'confirmed'},
            },
          ),
        )
        .run();
    result.fold((failure) => throw failure, (_) {});
    if (!context.mounted) return;
    ref.invalidate(dailyRecordDetailProvider(recordId));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
    await Toast.show(context, l10n.recordCreateSavedToast);
  } catch (e, st) {
    ref.read(talkerProvider).error('_confirmMealAnalysis: failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordMealConfirmFailedToast);
  }
}

/// Copies a compact text summary of [record] to the clipboard and shows a
/// confirmation toast.
Future<void> copyRecordSummary(
  BuildContext context,
  AppLocalizations l10n,
  DailyRecordItem record,
) async {
  final lines = <String>[
    '${l10n.recordCreateFieldKind}：${kindLabel(l10n, record.kind)}',
    if (nonEmpty(record.value) != null)
      '${l10n.recordDetailValueLabel}：${valueWithUnit(record.value!, record.unit)}',
    if (moodLabel(l10n, record) != null)
      '${l10n.recordDetailMoodLabel}：${moodLabel(l10n, record)}',
    if (nonEmpty(record.note) != null)
      '${l10n.recordCreateFieldNote}：${record.note}',
    if (nonEmpty(record.source) != null)
      '${l10n.recordDetailSourceLabel}：${sourceLabel(l10n, record.source!)}',
    '${l10n.recordDetailUpdatedAtLabel}：${formatRecordDateTimeLabel(record.updatedAt)}',
  ];
  await Clipboard.setData(ClipboardData(text: lines.join('\n')));
  if (context.mounted) {
    await Toast.show(context, l10n.recordDetailCopiedToast);
  }
}
