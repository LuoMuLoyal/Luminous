import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Centered dialog for picking a reminder time.
///
/// Shows a title, live preview of the selected time, the
/// [FTimePicker] wheel, and explicit cancel/confirm action buttons.
class ReminderTimePickerDialog extends HookWidget {
  const ReminderTimePickerDialog({super.key, required this.initial});

  /// The time pre-selected when the dialog opens.
  final FTime initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final locale = Localizations.localeOf(context);

    final timeController = useMemoized(
      () => FTimePickerController(time: initial),
    );
    useEffect(() => timeController.dispose, [timeController]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row with close button
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.medicineReminderTimePickerTitle,
                style: typography.body.xl2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FButton.icon(
              onPress: () => Navigator.of(context).pop(),
              variant: FButtonVariant.ghost,
              child: const Icon(SemanticIcons.actionClose),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level2),

        // Live preview of the currently selected time
        ValueListenableBuilder<FTime>(
          valueListenable: timeController,
          builder: (context, time, _) {
            return Text(
              formatTimeOfDay(
                TimeOfDay(hour: time.hour, minute: time.minute),
                locale,
              ),
              style: typography.body.xl3.copyWith(
                fontWeight: FontWeight.w800,
                color: SemanticColor.primary.solid(context),
              ),
            );
          },
        ),
        const SizedBox(height: Spacing.level4),

        // Time picker wheel
        SizedBox(
          height: 200,
          child: FTimePicker(
            control: FTimePickerControl.managed(controller: timeController),
          ),
        ),
        const SizedBox(height: Spacing.level4),

        // Cancel + Confirm action buttons
        Row(
          children: [
            Expanded(
              child: FButton(
                onPress: () => Navigator.of(context).pop(),
                variant: FButtonVariant.outline,
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: FButton(
                onPress: () => Navigator.of(context).pop(timeController.value),
                child: Text(l10n.commonConfirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
