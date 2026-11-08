import 'package:flutter/material.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/presentation/providers/notification/notification_utils.dart';

/// Pure mapping between notification setting fields and remote
/// [NotificationPreferencesPatch].
///
/// This file has NO import of the controller library to avoid circular deps.
/// Callers pass individual field values.

NotificationPreferencesPatch buildRemotePatch({
  required bool healthAlerts,
  required bool weeklySummary,
  required bool waterReminders,
  required bool isSleepReminderEnabled,
  required TimeOfDay? sleepBedtime,
  required TimeOfDay? sleepWakeTime,
}) {
  return NotificationPreferencesPatch(
    isHealthAlertsEnabled: healthAlerts,
    isWeeklyInsightEnabled: weeklySummary,
    isWaterRemindersEnabled: waterReminders,
    isSleepReminderEnabled: isSleepReminderEnabled,
    sleepBedtimeMinutes: NotificationUtils.toMinutes(sleepBedtime),
    sleepWakeTimeMinutes: NotificationUtils.toMinutes(sleepWakeTime),
  );
}
