import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineReminderDeleteDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showFDialog<bool>(
    context: context,
    builder: (dialogContext, style, animation) => FDialog(
      title: Text(l10n.medicineReminderDeleteConfirmTitle),
      body: Text(l10n.medicineReminderDeleteConfirmBody),
      actions: [
        FButton(
          variant: FButtonVariant.ghost,
          onPress: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.medicineReminderCancelAction),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          key: const Key('medicine-reminder-delete-confirm-button'),
          onPress: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.medicineReminderConfirmDeleteAction),
        ),
      ],
    ),
  );
}
