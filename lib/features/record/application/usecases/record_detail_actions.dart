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
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/presentation/routes.dart';
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
