import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineReminderDeleteDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showAppDialog<bool>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineReminderDeleteConfirmTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.medicineReminderDeleteConfirmBody,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.medicineReminderCancelAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              variant: FButtonVariant.destructive,
              key: const Key('medicine-reminder-delete-confirm-button'),
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.medicineReminderConfirmDeleteAction),
            ),
          ],
        ),
      ],
    ),
  );
}
