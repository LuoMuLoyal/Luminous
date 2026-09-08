import 'package:flutter/material.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/presentation/providers/notification_utils.dart';

/// Pure mapping between notification setting fields and remote
/// [NotificationPreferencesPatch].
///
/// This file has NO import of the controller library to avoid circular deps.
/// Callers pass individual field values.

NotificationPreferencesPatch buildRemotePatch({
  required bool healthAlerts,
  required bool weeklySummary,
  required bool waterReminders,
  required bool sleepReminderEnabled,
  required TimeOfDay? sleepBedtime,
  required TimeOfDay? sleepWakeTime,
}) {
  return NotificationPreferencesPatch(
    healthAlertsEnabled: healthAlerts,
    weeklyInsightEnabled: weeklySummary,
    waterRemindersEnabled: waterReminders,
    sleepReminderEnabled: sleepReminderEnabled,
    sleepBedtimeMinutes: NotificationUtils.toMinutes(sleepBedtime),
    sleepWakeTimeMinutes: NotificationUtils.toMinutes(sleepWakeTime),
  );
}
