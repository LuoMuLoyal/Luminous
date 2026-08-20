import 'package:flutter/foundation.dart';

@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.healthAlertsEnabled,
    required this.weeklyInsightEnabled,
    required this.waterRemindersEnabled,
    required this.sleepReminderEnabled,
    required this.sleepBedtimeMinutes,
    required this.sleepWakeTimeMinutes,
    required this.configured,
    required this.updatedAt,
  });

  const NotificationPreferences.defaults({required this.configured})
    : healthAlertsEnabled = true,
      weeklyInsightEnabled = false,
      waterRemindersEnabled = true,
      sleepReminderEnabled = false,
      sleepBedtimeMinutes = null,
      sleepWakeTimeMinutes = null,
      updatedAt = null;

  final bool healthAlertsEnabled;
  final bool weeklyInsightEnabled;
  final bool waterRemindersEnabled;
  final bool sleepReminderEnabled;
  final int? sleepBedtimeMinutes;
  final int? sleepWakeTimeMinutes;
  final bool configured;
  final String? updatedAt;

  NotificationPreferences copyWith({
    bool? healthAlertsEnabled,
    bool? weeklyInsightEnabled,
    bool? waterRemindersEnabled,
    bool? sleepReminderEnabled,
    Object? sleepBedtimeMinutes = _keep,
    Object? sleepWakeTimeMinutes = _keep,
    bool? configured,
    Object? updatedAt = _keep,
  }) {
    return NotificationPreferences(
      healthAlertsEnabled: healthAlertsEnabled ?? this.healthAlertsEnabled,
      weeklyInsightEnabled: weeklyInsightEnabled ?? this.weeklyInsightEnabled,
      waterRemindersEnabled:
          waterRemindersEnabled ?? this.waterRemindersEnabled,
      sleepReminderEnabled: sleepReminderEnabled ?? this.sleepReminderEnabled,
      sleepBedtimeMinutes: identical(sleepBedtimeMinutes, _keep)
          ? this.sleepBedtimeMinutes
          : sleepBedtimeMinutes as int?,
      sleepWakeTimeMinutes: identical(sleepWakeTimeMinutes, _keep)
          ? this.sleepWakeTimeMinutes
          : sleepWakeTimeMinutes as int?,
      configured: configured ?? this.configured,
      updatedAt: identical(updatedAt, _keep)
          ? this.updatedAt
          : updatedAt as String?,
    );
  }

  NotificationPreferences apply(NotificationPreferencesPatch patch) {
    return copyWith(
      healthAlertsEnabled: patch.healthAlertsEnabled,
      weeklyInsightEnabled: patch.weeklyInsightEnabled,
      waterRemindersEnabled: patch.waterRemindersEnabled,
      sleepReminderEnabled: patch.sleepReminderEnabled,
      sleepBedtimeMinutes: patch.clearSleepBedtime
          ? null
          : patch.sleepBedtimeMinutes ?? sleepBedtimeMinutes,
      sleepWakeTimeMinutes: patch.clearSleepWakeTime
          ? null
          : patch.sleepWakeTimeMinutes ?? sleepWakeTimeMinutes,
    );
  }

  static const _keep = Object();
}

@immutable
class NotificationPreferencesPatch {
  const NotificationPreferencesPatch({
    this.healthAlertsEnabled,
    this.weeklyInsightEnabled,
    this.waterRemindersEnabled,
    this.sleepReminderEnabled,
    this.sleepBedtimeMinutes,
    this.sleepWakeTimeMinutes,
    this.clearSleepBedtime = false,
    this.clearSleepWakeTime = false,
  });

  final bool? healthAlertsEnabled;
  final bool? weeklyInsightEnabled;
  final bool? waterRemindersEnabled;
  final bool? sleepReminderEnabled;
  final int? sleepBedtimeMinutes;
  final int? sleepWakeTimeMinutes;
  final bool clearSleepBedtime;
  final bool clearSleepWakeTime;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (healthAlertsEnabled != null) {
      json['healthAlertsEnabled'] = healthAlertsEnabled;
    }
    if (weeklyInsightEnabled != null) {
      json['weeklyInsightEnabled'] = weeklyInsightEnabled;
    }
    if (waterRemindersEnabled != null) {
      json['waterRemindersEnabled'] = waterRemindersEnabled;
    }
    if (sleepReminderEnabled != null) {
      json['sleepReminderEnabled'] = sleepReminderEnabled;
    }
    if (clearSleepBedtime || sleepBedtimeMinutes != null) {
      json['sleepBedtimeMinutes'] = clearSleepBedtime
          ? null
          : sleepBedtimeMinutes;
    }
    if (clearSleepWakeTime || sleepWakeTimeMinutes != null) {
      json['sleepWakeTimeMinutes'] = clearSleepWakeTime
          ? null
          : sleepWakeTimeMinutes;
    }
    return json;
  }
}
