import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineReminderDeleteDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return showAppDialog<bool>(
    context: context,
    // 内容高度固定且很短:保留 scrollable: false(避免无谓的滚动层),
    // 按「标题 + 正文 + 按钮行 + 弹窗内边距」给出留裕量的上限,满足 DialogShell 断言。
    maxHeight: 400,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineReminderDeleteConfirmTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.medicineReminderDeleteConfirmBody,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        DialogActionRow(
          actions: [
            DialogActionButton(
              label: l10n.medicineReminderCancelAction,
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
            ),
            DialogActionButton(
              key: const Key('medicine-reminder-delete-confirm-button'),
              label: l10n.medicineReminderConfirmDeleteAction,
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
}
