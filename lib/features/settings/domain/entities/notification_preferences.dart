import 'package:meta/meta.dart';

@immutable
class NotificationPreferences {
  const NotificationPreferences({
    required this.isHealthAlertsEnabled,
    required this.isWeeklyInsightEnabled,
    required this.isWaterRemindersEnabled,
    required this.isSleepReminderEnabled,
    required this.sleepBedtimeMinutes,
    required this.sleepWakeTimeMinutes,
    required this.configured,
    required this.updatedAt,
  });

  const NotificationPreferences.defaults({required this.configured})
    : isHealthAlertsEnabled = true,
      isWeeklyInsightEnabled = false,
      isWaterRemindersEnabled = true,
      isSleepReminderEnabled = false,
      sleepBedtimeMinutes = null,
      sleepWakeTimeMinutes = null,
      updatedAt = null;

  final bool isHealthAlertsEnabled;
  final bool isWeeklyInsightEnabled;
  final bool isWaterRemindersEnabled;
  final bool isSleepReminderEnabled;
  final int? sleepBedtimeMinutes;
  final int? sleepWakeTimeMinutes;
  final bool configured;
  final String? updatedAt;

  NotificationPreferences copyWith({
    bool? isHealthAlertsEnabled,
    bool? isWeeklyInsightEnabled,
    bool? isWaterRemindersEnabled,
    bool? isSleepReminderEnabled,
    Object? sleepBedtimeMinutes = _keep,
    Object? sleepWakeTimeMinutes = _keep,
    bool? configured,
    Object? updatedAt = _keep,
  }) {
    return NotificationPreferences(
      isHealthAlertsEnabled:
          isHealthAlertsEnabled ?? this.isHealthAlertsEnabled,
      isWeeklyInsightEnabled:
          isWeeklyInsightEnabled ?? this.isWeeklyInsightEnabled,
      isWaterRemindersEnabled:
          isWaterRemindersEnabled ?? this.isWaterRemindersEnabled,
      isSleepReminderEnabled:
          isSleepReminderEnabled ?? this.isSleepReminderEnabled,
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
      isHealthAlertsEnabled: patch.isHealthAlertsEnabled,
      isWeeklyInsightEnabled: patch.isWeeklyInsightEnabled,
      isWaterRemindersEnabled: patch.isWaterRemindersEnabled,
      isSleepReminderEnabled: patch.isSleepReminderEnabled,
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
    this.isHealthAlertsEnabled,
    this.isWeeklyInsightEnabled,
    this.isWaterRemindersEnabled,
    this.isSleepReminderEnabled,
    this.sleepBedtimeMinutes,
    this.sleepWakeTimeMinutes,
    this.clearSleepBedtime = false,
    this.clearSleepWakeTime = false,
  });

  final bool? isHealthAlertsEnabled;
  final bool? isWeeklyInsightEnabled;
  final bool? isWaterRemindersEnabled;
  final bool? isSleepReminderEnabled;
  final int? sleepBedtimeMinutes;
  final int? sleepWakeTimeMinutes;
  final bool clearSleepBedtime;
  final bool clearSleepWakeTime;

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (isHealthAlertsEnabled != null) {
      json['isHealthAlertsEnabled'] = isHealthAlertsEnabled;
    }
    if (isWeeklyInsightEnabled != null) {
      json['isWeeklyInsightEnabled'] = isWeeklyInsightEnabled;
    }
    if (isWaterRemindersEnabled != null) {
      json['isWaterRemindersEnabled'] = isWaterRemindersEnabled;
    }
    if (isSleepReminderEnabled != null) {
      json['isSleepReminderEnabled'] = isSleepReminderEnabled;
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
