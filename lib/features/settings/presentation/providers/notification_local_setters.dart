part of 'notification.dart';

/// 本地偏好 setter 分组:写入 SharedPreferences 的本地设置项。
///
/// 与远程同步相关的 setter 在 [NotificationRemoteSync] 中,本 mixin 只负责
/// 纯本地持久化的设置(药物提醒、睡眠提醒、免打扰、声音/震动、提前时间)与
/// [reset]。与主文件共享同一 library scope,可直接访问私有常量与
/// [NotificationSettingsControllerCore._save]。
mixin NotificationLocalSetters on NotificationSettingsControllerCore {
  Future<void> setMedicationReminders(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(medicationReminders: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_medicationKey, enabled),
    );
  }

  Future<void> setSleepReminders(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(sleepReminders: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_sleepRemindersKey, enabled),
    );
  }

  Future<void> setDndEnabled(bool enabled) async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    // Mirror `setSleepReminderEnabled`: seed defaults when first enabled so
    // the sub-page and list page agree on a concrete time range.
    TimeOfDay? start = current.dndStartTime;
    TimeOfDay? end = current.dndEndTime;
    if (enabled) {
      start ??= const TimeOfDay(hour: 22, minute: 0);
      end ??= const TimeOfDay(hour: 7, minute: 0);
    }
    final next = current.copyWith(
      dndEnabled: enabled,
      dndStartTime: start,
      dndEndTime: end,
    );
    await _save(
      next,
      update: (preferences) async {
        await preferences.setBool(_dndEnabledKey, enabled);
        if (start != null) {
          await preferences.setString(
            _dndStartTimeKey,
            NotificationUtils.formatTime(start),
          );
        }
        if (end != null) {
          await preferences.setString(
            _dndEndTimeKey,
            NotificationUtils.formatTime(end),
          );
        }
      },
    );
  }

  Future<void> setDndStartTime(TimeOfDay? time) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(dndStartTime: time);
    await _save(
      next,
      update: (preferences) async {
        if (time == null) {
          await preferences.remove(_dndStartTimeKey);
        } else {
          await preferences.setString(
            _dndStartTimeKey,
            NotificationUtils.formatTime(time),
          );
        }
      },
    );
  }

  Future<void> setDndEndTime(TimeOfDay? time) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(dndEndTime: time);
    await _save(
      next,
      update: (preferences) async {
        if (time == null) {
          await preferences.remove(_dndEndTimeKey);
        } else {
          await preferences.setString(
            _dndEndTimeKey,
            NotificationUtils.formatTime(time),
          );
        }
      },
    );
  }

  Future<void> setNotificationSoundEnabled(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(notificationSoundEnabled: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_soundEnabledKey, enabled),
    );
  }

  Future<void> setNotificationVibrationEnabled(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(notificationVibrationEnabled: enabled);
    await _save(
      next,
      update: (preferences) =>
          preferences.setBool(_vibrationEnabledKey, enabled),
    );
  }

  Future<void> setReminderAdvanceMinutes(int minutes) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(reminderAdvanceMinutes: minutes);
    await _save(
      next,
      update: (preferences) =>
          preferences.setInt(_reminderAdvanceMinutesKey, minutes),
    );
  }

  Future<void> reset() async {
    final auth = ref.read(authSessionProvider);
    if (auth.canAccessProtectedData && auth.user?.id != null) {
      await _saveRemotePreference(
        patch: const NotificationPreferencesPatch(
          healthAlertsEnabled: true,
          weeklyInsightEnabled: false,
          waterRemindersEnabled: true,
          sleepReminderEnabled: false,
          clearSleepBedtime: true,
          clearSleepWakeTime: true,
        ),
        update: (current) => current.copyWith(
          healthAlerts: true,
          weeklySummary: false,
          waterReminders: true,
          sleepReminderEnabled: false,
          sleepBedtime: null,
          sleepWakeTime: null,
        ),
      );
    }
    await _save(
      NotificationSettingsState(
        permissionState:
            state.asData?.value.permissionState ??
            NotificationPermissionState.unsupported,
        // Explicitly null out the time fields so the list page renders
        // "未设置" after a reset, instead of inheriting the freezed
        // `@Default(TimeOfDay(...))` which would desync from the sub-page.
        sleepBedtime: null,
        sleepWakeTime: null,
        dndStartTime: null,
        dndEndTime: null,
      ),
      update: (preferences) async {
        for (final key in _resetKeys) {
          await preferences.remove(key);
        }
        final userId = ref.read(authSessionProvider).user?.id;
        if (userId != null) {
          final scoped = ScopedPreferences(preferences, userId);
          for (final key in _legacyRemoteKeys) {
            await scoped.remove(key);
          }
          await scoped.remove(
            PrefKeys.settingsNotificationsRemoteMigrationCompleted,
          );
        }
      },
    );
  }
}
