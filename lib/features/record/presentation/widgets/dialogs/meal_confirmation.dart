import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealQuickConfirmationDialog extends StatefulWidget {
  const MealQuickConfirmationDialog({
    super.key,
    required this.flow,
    required this.draft,
  });

  final MealQuickEntryFlow flow;
  final MealQuickEntryDraft draft;

  @override
  State<MealQuickConfirmationDialog> createState() =>
      _MealQuickConfirmationDialogState();
}

class _MealQuickConfirmationDialogState
    extends State<MealQuickConfirmationDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _noteController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title ?? '');
    _valueController = TextEditingController(text: widget.draft.value ?? '');
    _noteController = TextEditingController(text: widget.draft.note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final image = widget.draft.image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordQuickMealConfirmTitle,
          style: context.theme.typography.body.lg,
        ),
        if (image != null) ...[
          const SizedBox(height: Spacing.level4),
          ClipRRect(
            borderRadius: context.theme.style.borderRadius.sm,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(image.bytes, fit: BoxFit.cover),
            ),
          ),
        ],
        const SizedBox(height: Spacing.level4),
        FTextField(
          key: const Key('record-quick-meal-title-field'),
          control: FTextFieldControl.managed(controller: _titleController),
          label: Text(l10n.recordCreateFieldTitle),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.level3),
        FTextField(
          key: const Key('record-quick-meal-value-field'),
          control: FTextFieldControl.managed(controller: _valueController),
          label: Text(l10n.recordCreateValueMeal),
          enabled: !_saving,
        ),
        const SizedBox(height: Spacing.level3),
        FTextField(
          key: const Key('record-quick-meal-note-field'),
          control: FTextFieldControl.managed(controller: _noteController),
          label: Text(l10n.recordCreateFieldNote),
          maxLines: 2,
          enabled: !_saving,
        ),
        if (_saving) ...[
          const SizedBox(height: Spacing.level4),
          const Center(child: FProgress()),
        ],
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: _saving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('record-quick-meal-confirm-action'),
              onPress: _saving ? null : _save,
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await widget.flow.saveDraft(
        widget.draft.copyWith(
          title: _titleController.text,
          value: _valueController.text,
          note: _noteController.text,
        ),
      );
    } catch (e, st) {
      appTalker.error('MealQuickConfirmation: saveDraft failed: $e', st);
      if (!mounted) return;
      setState(() => _saving = false);
      unawaited(Toast.show(context, l10n.recordCreateFailedToast));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    unawaited(Toast.show(context, l10n.recordCreateSavedToast));
  }
}
