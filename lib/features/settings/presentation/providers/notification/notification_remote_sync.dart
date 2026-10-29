part of 'notification.dart';

/// 远程同步偏好 setter 分组:健康提醒、周报、喝水、睡眠提醒与睡眠时间经
/// [notificationPreferencesRepositoryProvider] 写入远端,本地 SharedPreferences
/// 仅作缓存与离线回退。
///
/// 串行化与写回机制([_saveRemotePreference] / [_performRemotePreference] /
/// [_applyRemote] / [_cacheRemote] / [_writeRemoteLocal])保留在主文件类体中,
/// 本 mixin 只声明直接暴露给页面的远程 setter。
mixin NotificationRemoteSync on NotificationSettingsControllerCore {
  Future<void> setHealthAlerts(bool enabled) async {
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(healthAlertsEnabled: enabled),
      update: (current) => current.copyWith(healthAlerts: enabled),
    );
  }

  Future<void> setWeeklySummary(bool enabled) async {
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(weeklyInsightEnabled: enabled),
      update: (current) => current.copyWith(weeklySummary: enabled),
    );
  }

  Future<void> setWaterReminders(bool enabled) async {
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(waterRemindersEnabled: enabled),
      update: (current) => current.copyWith(waterReminders: enabled),
    );
  }

  Future<void> setSleepReminderEnabled(bool enabled) async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    // When turning the feature on for the first time, seed any unset times
    // with sane defaults so the sub-page never shows a placeholder while
    // the list page claims the feature is active.
    TimeOfDay? bedtime = current.sleepBedtime;
    TimeOfDay? wakeTime = current.sleepWakeTime;
    if (enabled) {
      bedtime ??= const TimeOfDay(hour: 23, minute: 0);
      wakeTime ??= const TimeOfDay(hour: 7, minute: 0);
    }
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(
        sleepReminderEnabled: enabled,
        sleepBedtimeMinutes: _toMinutes(bedtime),
        sleepWakeTimeMinutes: _toMinutes(wakeTime),
      ),
      update: (value) => value.copyWith(
        sleepReminderEnabled: enabled,
        sleepBedtime: bedtime,
        sleepWakeTime: wakeTime,
      ),
    );
  }

  Future<void> setSleepBedtime(TimeOfDay? time) async {
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(
        sleepBedtimeMinutes: _toMinutes(time),
        clearSleepBedtime: time == null,
      ),
      update: (current) => current.copyWith(sleepBedtime: time),
    );
  }

  Future<void> setSleepWakeTime(TimeOfDay? time) async {
    await _saveRemotePreference(
      patch: NotificationPreferencesPatch(
        sleepWakeTimeMinutes: _toMinutes(time),
        clearSleepWakeTime: time == null,
      ),
      update: (current) => current.copyWith(sleepWakeTime: time),
    );
  }
}
