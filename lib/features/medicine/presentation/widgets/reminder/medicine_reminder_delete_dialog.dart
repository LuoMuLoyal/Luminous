import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineReminderDeleteDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.medicineReminderDeleteConfirmTitle),
        content: Text(l10n.medicineReminderDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.medicineReminderCancelAction),
          ),
          FilledButton(
            key: const Key('medicine-reminder-delete-confirm-button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.medicineReminderConfirmDeleteAction),
          ),
        ],
      );
    },
  );
}
