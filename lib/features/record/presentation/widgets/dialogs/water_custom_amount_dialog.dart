import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a dialog prompting for a custom water amount in ml.
///
/// Returns the parsed positive amount, or `null` when the user cancels.
Future<int?> showWaterCustomAmountDialog(
  BuildContext context, {
  required int initialMl,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showAppDialog<int>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    builder: (dialogContext) =>
        _WaterCustomAmountBody(l10n: l10n, initialMl: initialMl),
  );
}

/// Shared handler for water-default [FSelect] changes.
///
/// Preset options are persisted directly; picking
/// [QuickEntryWaterDefault.custom] first prompts for an ml amount and only
/// then persists the custom choice together with the entered value.
Future<void> handleWaterDefaultSelect(
  BuildContext context, {
  required QuickEntryWaterDefault value,
  required QuickEntryPreferences prefs,
  required QuickEntryPreferencesController controller,
}) async {
  if (value != QuickEntryWaterDefault.custom) {
    await controller.setWaterDefault(value);
    return;
  }
  final ml = await showWaterCustomAmountDialog(
    context,
    initialMl: prefs.waterCustomMl,
  );
  if (ml == null) return;
  await controller.setWaterCustomMl(ml);
  await controller.setWaterDefault(QuickEntryWaterDefault.custom);
}

class _WaterCustomAmountBody extends StatefulWidget {
  const _WaterCustomAmountBody({required this.l10n, required this.initialMl});

  final AppLocalizations l10n;
  final int initialMl;

  @override
  State<_WaterCustomAmountBody> createState() => _WaterCustomAmountBodyState();
}

class _WaterCustomAmountBodyState extends State<_WaterCustomAmountBody> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialMl.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final ml = int.tryParse(_controller.text.trim());
    if (ml == null || ml <= 0) {
      setState(
        () => _errorText =
            widget.l10n.recordQuickSettingsWaterCustomDialogInvalid,
      );
      return;
    }
    Navigator.of(context).pop(ml);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final typography = context.theme.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordQuickSettingsWaterCustomDialogTitle,
          style: typography.body.lg,
        ),
        const SizedBox(height: Spacing.level3),
        Text(
          l10n.recordQuickSettingsWaterCustomDialogHint,
          style: typography.body.sm,
        ),
        const SizedBox(height: Spacing.level4),
        FTextField(
          key: const Key('water-custom-ml-field'),
          control: FTextFieldControl.managed(controller: _controller),
          label: Text(l10n.recordQuickSettingsWaterCustomDialogLabel),
          hint: l10n.recordQuickSettingsWaterCustomDialogHint,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          error: _errorText == null ? null : Text(_errorText!),
          onSubmit: (_) => _submit(),
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('water-custom-ml-confirm'),
              onPress: _submit,
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      ],
    );
  }
}
