/// Pure reminder helpers shared by the data and presentation layers.
///
/// These carry no `BuildContext`, `Locale` or ARB lookup, so the medicine
/// `data/` layer may use them. The localized labels stay in
/// `core/utils/reminder_format.dart`.
library;

import 'package:luminous/features/medicine/domain/entities/reminder.dart';

/// How a reminder repeats; used by the edit form and the slot planner.
enum ReminderFrequency { daily, weekly, custom }

/// The reminders that belong to [currentMedicineId], sorted by scheduled time.
List<MedicineReminderItem> remindersFor(
  List<MedicineReminderItem> reminders,
  String currentMedicineId,
) {
  return reminders
      .where((item) => item.currentMedicineId == currentMedicineId)
      .toList(growable: false)
    ..sort(compareReminderTime);
}

/// Orders reminders by their scheduled wall-clock time.
int compareReminderTime(MedicineReminderItem left, MedicineReminderItem right) {
  final hour = left.scheduledHour.compareTo(right.scheduledHour);
  if (hour != 0) return hour;
  return left.scheduledMinute.compareTo(right.scheduledMinute);
}

/// Trims [value] and maps the empty string to `null`.
String? trimmedOrNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Midnight of [value]; the slot planner compares days, not instants.
DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

/// Parses a `yyyy-MM-dd` value into its date at midnight; `null` on bad input.
DateTime? parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return dateOnly(parsed);
}

/// Formats [value] as a `yyyy-MM-dd` input value (`''` when null).
String formatDateInput(DateTime? value) {
  if (value == null) return '';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
