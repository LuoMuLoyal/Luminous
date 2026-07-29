import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Save and delete action buttons for the record edit page.
class RecordEditActions extends StatelessWidget {
  const RecordEditActions({
    super.key,
    required this.l10n,
    required this.saving,
    required this.deleting,
    required this.onSave,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final bool saving;
  final bool deleting;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.level5),
        FButton(
          key: const Key('record-edit-save-action'),
          onPress: saving ? null : onSave,
          prefix: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: FCircularProgress(),
                )
              : null,
          child: Text(l10n.mineEditSaveAction),
        ),
        const SizedBox(height: Spacing.level3),
        FButton(
          key: const Key('record-edit-delete-action'),
          variant: FButtonVariant.destructive,
          onPress: deleting || saving ? null : onDelete,
          prefix: deleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: FCircularProgress(),
                )
              : const Icon(SemanticIcons.actionDelete, size: 18),
          child: Text(l10n.recordDeleteAction),
        ),
      ],
    );
  }
}
