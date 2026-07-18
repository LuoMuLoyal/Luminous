import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification.freezed.dart';

@freezed
abstract class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState({
    @Default(true) bool medicationReminders,
    @Default(true) bool healthAlerts,
    @Default(false) bool weeklySummary,
    @Default(true) bool waterReminders,
    @Default(true) bool sleepReminders,
    @Default(false) bool sleepReminderEnabled,
    @Default(TimeOfDay(hour: 23, minute: 0)) TimeOfDay? sleepBedtime,
    @Default(TimeOfDay(hour: 7, minute: 0)) TimeOfDay? sleepWakeTime,
    @Default(NotificationPermissionState.unsupported)
    NotificationPermissionState permissionState,
    // -- 通知增强 --
    @Default(false) bool dndEnabled,
    @Default(TimeOfDay(hour: 22, minute: 0)) TimeOfDay? dndStartTime,
    @Default(TimeOfDay(hour: 7, minute: 0)) TimeOfDay? dndEndTime,
    @Default(true) bool notificationSoundEnabled,
    @Default(true) bool notificationVibrationEnabled,
    @Default(0) int reminderAdvanceMinutes,
  }) = _NotificationSettingsState;
}

class NotificationSettingsController
    extends AsyncNotifier<NotificationSettingsState> {
  static const _medicationKey =
      PrefKeys.settingsNotificationsMedicationReminders;
  static const _healthAlertsKey = PrefKeys.settingsNotificationsHealthAlerts;
  static const _weeklySummaryKey = PrefKeys.settingsNotificationsWeeklySummary;
  static const _waterRemindersKey =
      PrefKeys.settingsNotificationsWaterReminders;
  static const _sleepRemindersKey =
      PrefKeys.settingsNotificationsSleepReminders;
  static const _sleepReminderEnabledKey =
      PrefKeys.settingsNotificationsSleepReminderEnabled;
  static const _sleepBedtimeKey = PrefKeys.settingsNotificationsSleepBedtime;
  static const _sleepWakeTimeKey = PrefKeys.settingsNotificationsSleepWakeTime;
  static const _dndEnabledKey = PrefKeys.settingsNotificationsDndEnabled;
  static const _dndStartTimeKey = PrefKeys.settingsNotificationsDndStartTime;
  static const _dndEndTimeKey = PrefKeys.settingsNotificationsDndEndTime;
  static const _soundEnabledKey = PrefKeys.settingsNotificationsSoundEnabled;
  static const _vibrationEnabledKey =
      PrefKeys.settingsNotificationsVibrationEnabled;
  static const _reminderAdvanceMinutesKey =
      PrefKeys.settingsNotificationsReminderAdvanceMinutes;

  @override
  Future<NotificationSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final permissionState = await ref
        .read(notificationPermissionServiceProvider)
        .getPermissionState();
    return NotificationSettingsState(
      medicationReminders: preferences.getBool(_medicationKey) ?? true,
      healthAlerts: preferences.getBool(_healthAlertsKey) ?? true,
      weeklySummary: preferences.getBool(_weeklySummaryKey) ?? false,
      waterReminders: preferences.getBool(_waterRemindersKey) ?? true,
      sleepReminders: preferences.getBool(_sleepRemindersKey) ?? true,
      sleepReminderEnabled:
          preferences.getBool(_sleepReminderEnabledKey) ?? false,
      sleepBedtime:
          _parseTime(preferences.getString(_sleepBedtimeKey)) ??
          const TimeOfDay(hour: 23, minute: 0),
      sleepWakeTime:
          _parseTime(preferences.getString(_sleepWakeTimeKey)) ??
          const TimeOfDay(hour: 7, minute: 0),
      permissionState: permissionState,
      dndEnabled: preferences.getBool(_dndEnabledKey) ?? false,
      dndStartTime:
          _parseTime(preferences.getString(_dndStartTimeKey)) ??
          const TimeOfDay(hour: 22, minute: 0),
      dndEndTime:
          _parseTime(preferences.getString(_dndEndTimeKey)) ??
          const TimeOfDay(hour: 7, minute: 0),
      notificationSoundEnabled: preferences.getBool(_soundEnabledKey) ?? true,
      notificationVibrationEnabled:
          preferences.getBool(_vibrationEnabledKey) ?? true,
      reminderAdvanceMinutes:
          preferences.getInt(_reminderAdvanceMinutesKey) ?? 0,
    );
  }

  Future<void> requestPermission() async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    final permissionState = await ref
        .read(notificationPermissionServiceProvider)
        .requestPermission();
    state = AsyncData(current.copyWith(permissionState: permissionState));
  }

  Future<void> setMedicationReminders(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(medicationReminders: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_medicationKey, enabled),
    );
  }

  Future<void> setHealthAlerts(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(healthAlerts: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_healthAlertsKey, enabled),
    );
  }

  Future<void> setWeeklySummary(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(weeklySummary: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_weeklySummaryKey, enabled),
    );
  }

  Future<void> setWaterReminders(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(waterReminders: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_waterRemindersKey, enabled),
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

  Future<void> setSleepReminderEnabled(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(sleepReminderEnabled: enabled);
    await _save(
      next,
      update: (preferences) =>
          preferences.setBool(_sleepReminderEnabledKey, enabled),
    );
  }

  Future<void> setSleepBedtime(TimeOfDay? time) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(sleepBedtime: time);
    await _save(
      next,
      update: (preferences) async {
        if (time == null) {
          await preferences.remove(_sleepBedtimeKey);
        } else {
          await preferences.setString(_sleepBedtimeKey, _formatTime(time));
        }
      },
    );
  }

  Future<void> setSleepWakeTime(TimeOfDay? time) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(sleepWakeTime: time);
    await _save(
      next,
      update: (preferences) async {
        if (time == null) {
          await preferences.remove(_sleepWakeTimeKey);
        } else {
          await preferences.setString(_sleepWakeTimeKey, _formatTime(time));
        }
      },
    );
  }

  Future<void> setDndEnabled(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(dndEnabled: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_dndEnabledKey, enabled),
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
          await preferences.setString(_dndStartTimeKey, _formatTime(time));
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
          await preferences.setString(_dndEndTimeKey, _formatTime(time));
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
    await _save(
      NotificationSettingsState(
        permissionState:
            state.asData?.value.permissionState ??
            NotificationPermissionState.unsupported,
      ),
      update: (preferences) async {
        await preferences.remove(_medicationKey);
        await preferences.remove(_healthAlertsKey);
        await preferences.remove(_weeklySummaryKey);
        await preferences.remove(_waterRemindersKey);
        await preferences.remove(_sleepRemindersKey);
        await preferences.remove(_sleepReminderEnabledKey);
        await preferences.remove(_sleepBedtimeKey);
        await preferences.remove(_sleepWakeTimeKey);
        await preferences.remove(_dndEnabledKey);
        await preferences.remove(_dndStartTimeKey);
        await preferences.remove(_dndEndTimeKey);
        await preferences.remove(_soundEnabledKey);
        await preferences.remove(_vibrationEnabledKey);
        await preferences.remove(_reminderAdvanceMinutesKey);
      },
    );
  }

  Future<void> _save(
    NotificationSettingsState next, {
    required Future<void> Function(SharedPreferences preferences) update,
  }) async {
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await update(preferences);
    // medicineReminderNotificationSyncProvider watches this controller and
    // handles reminder rescheduling after the schedule data layer is available.
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

final notificationSettingsControllerProvider =
    AsyncNotifierProvider<
      NotificationSettingsController,
      NotificationSettingsState
    >(NotificationSettingsController.new);
