import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';

/// Shows a forui calendar date-picker dialog and returns the picked [DateTime].
///
/// Returns `null` if the user dismisses the dialog without selecting a date.
/// The selected date is truncated to a day-only [DateTime] (no time component).
///
/// This is the shared version of the pattern used across the app (record,
/// medicine reminders, health forms). All date-picker entry points should
/// delegate here instead of re-implementing `showFDialog + FCalendar.grid`.
Future<DateTime?> showForuiDatePicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) => showFDialog<DateTime?>(
  context: context,
  builder: (dialogContext, style, animation) => AppDialogShell(
    maxWidth: LayoutScaleResolver.dialogMaxWidth,
    padding: const EdgeInsets.all(Spacing.level4),
    builder: (_) => SizedBox(
      height: 360,
      child: FCalendar.grid(
        control: FGridCalendarControl(start: first, end: last),
        selectionControl: FDateSelectionControl.lifted(
          selected: (date) => _dateOnly(date) == _dateOnly(initial),
          select: (date) => Navigator.of(dialogContext).pop(_dateOnly(date)),
        ),
      ),
    ),
  ),
);

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
