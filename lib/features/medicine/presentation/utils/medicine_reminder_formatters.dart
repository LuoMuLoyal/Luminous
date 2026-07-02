import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

enum ReminderFrequency { daily, weekly, custom }

// ---------------------------------------------------------------------------
// Reminder helpers
// ---------------------------------------------------------------------------

List<MedicineReminderItem> remindersFor(
  List<MedicineReminderItem> reminders,
  String currentMedicineId,
) {
  return reminders
      .where((item) => item.currentMedicineId == currentMedicineId)
      .toList(growable: false)
    ..sort(compareReminderTime);
}

int compareReminderTime(MedicineReminderItem left, MedicineReminderItem right) {
  final hour = left.scheduledHour.compareTo(right.scheduledHour);
  if (hour != 0) return hour;
  return left.scheduledMinute.compareTo(right.scheduledMinute);
}

// ---------------------------------------------------------------------------
// Display helpers
// ---------------------------------------------------------------------------

String medicineDoseText(AppLocalizations l10n, CurrentMedicineItem medicine) {
  final text = [
    medicine.strengthText,
    medicine.doseText,
  ].whereType<String>().where((item) => item.trim().isNotEmpty).join(' · ');
  return text.isEmpty ? l10n.medicineDoseNotSet : text;
}

String frequencyLabel(
  AppLocalizations l10n,
  List<MedicineReminderItem> reminders,
) {
  if (reminders.isEmpty) return l10n.medicineScheduleNotSet;
  final days = reminders.first.daysOfWeek;
  if (days == null) return l10n.medicineReminderFrequencyDaily;
  if (days.length == 1) {
    return '${l10n.medicineReminderFrequencyWeekly} · ${weekdayLabel(l10n, days.single)}';
  }
  return '${l10n.medicineReminderFrequencyCustom} · ${days.map((day) => weekdayLabel(l10n, day)).join(' ')}';
}

String weekdayLabel(AppLocalizations l10n, int day) {
  return switch (day) {
    0 => l10n.recordWeekdaySun,
    1 => l10n.recordWeekdayMon,
    2 => l10n.recordWeekdayTue,
    3 => l10n.recordWeekdayWed,
    4 => l10n.recordWeekdayThu,
    5 => l10n.recordWeekdayFri,
    6 => l10n.recordWeekdaySat,
    _ => '$day',
  };
}

String dateLabel(AppLocalizations l10n, DateTime? value) {
  if (value == null) return l10n.medicineReminderDateNotSet;
  return formatDateInput(value);
}

String soundPreferenceLabel(
  AppLocalizations l10n,
  MedicineReminderSoundPreference value,
) {
  return switch (value) {
    MedicineReminderSoundPreference.defaultTone =>
      l10n.medicineReminderSoundDefault,
    MedicineReminderSoundPreference.gentle => l10n.medicineReminderSoundGentle,
    MedicineReminderSoundPreference.silent => l10n.medicineReminderSoundSilent,
  };
}

String deliveryChannelLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'local' => l10n.medicineReminderDeliveryChannelLocal,
    'push' => l10n.medicineReminderDeliveryChannelPush,
    'email' => l10n.medicineReminderDeliveryChannelEmail,
    'sms' => l10n.medicineReminderDeliveryChannelSms,
    _ => value,
  };
}

String deliveryStatusLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'scheduled' => l10n.medicineReminderDeliveryStatusScheduled,
    'delivered' => l10n.medicineReminderDeliveryStatusDelivered,
    'failed' => l10n.medicineReminderDeliveryStatusFailed,
    _ => value,
  };
}

IconData deliveryStatusIcon(String value) {
  return switch (value) {
    'delivered' => FLucideIcons.badgeCheck,
    'failed' => FLucideIcons.circleAlert,
    _ => FLucideIcons.clock3,
  };
}

Color deliveryStatusColor(String value, Object palette) {
  final destructive = switch (palette) {
    FColors colors => colors.destructive,
    Color color => color,
    _ => AppColorTokens.warningDeep,
  };
  final muted = switch (palette) {
    FColors colors => colors.mutedForeground,
    Color color => color,
    _ => AppColorTokens.warningDeep,
  };
  return switch (value) {
    'delivered' => AppColorTokens.cyanDeep,
    'failed' => destructive,
    'scheduled' => AppColorTokens.warningDeep,
    _ => muted,
  };
}

String dateTimeShortLabel(AppLocalizations l10n, String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final now = DateTime.now();
  final date = dateOnly(parsed);
  final today = dateOnly(now);
  final datePrefix = date == today
      ? l10n.recordTodayAction
      : formatDateInput(parsed);
  return '$datePrefix ${dateTimeTimeLabel(value)}';
}

String dateTimeTimeLabel(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Date helpers
// ---------------------------------------------------------------------------

DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return dateOnly(parsed);
}

String formatDateInput(DateTime? value) {
  if (value == null) return '';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

// ---------------------------------------------------------------------------
// String helpers
// ---------------------------------------------------------------------------

String? trimmedOrNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
