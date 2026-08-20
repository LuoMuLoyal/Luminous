import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/data/providers/notification_preferences.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
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

extension NotificationSettingsMinutes on NotificationSettingsState {
  int? get sleepBedtimeMinutes => _toMinutes(sleepBedtime);
  int? get sleepWakeTimeMinutes => _toMinutes(sleepWakeTime);

  static int? _toMinutes(TimeOfDay? time) =>
      time == null ? null : time.hour * 60 + time.minute;
}

class NotificationSettingsController
    extends AsyncNotifier<NotificationSettingsState> {
  Future<void> _remoteMutationTail = Future<void>.value();
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
  static const _legacyMigrationOwnerKey =
      PrefKeys.settingsNotificationsLegacyMigrationOwner;

  /// Every preference key cleared by [reset]. Kept in one list so adding a
  /// new setting cannot be forgotten in the reset path.
  static const _resetKeys = <String>[
    PrefKeys.settingsNotificationsMedicationReminders,
    PrefKeys.settingsNotificationsHealthAlerts,
    PrefKeys.settingsNotificationsWeeklySummary,
    PrefKeys.settingsNotificationsWaterReminders,
    PrefKeys.settingsNotificationsSleepReminders,
    PrefKeys.settingsNotificationsSleepReminderEnabled,
    PrefKeys.settingsNotificationsSleepBedtime,
    PrefKeys.settingsNotificationsSleepWakeTime,
    PrefKeys.settingsNotificationsDndEnabled,
    PrefKeys.settingsNotificationsDndStartTime,
    PrefKeys.settingsNotificationsDndEndTime,
    PrefKeys.settingsNotificationsSoundEnabled,
    PrefKeys.settingsNotificationsVibrationEnabled,
    PrefKeys.settingsNotificationsReminderAdvanceMinutes,
  ];

  static const _legacyRemoteKeys = <String>[
    PrefKeys.settingsNotificationsHealthAlerts,
    PrefKeys.settingsNotificationsWeeklySummary,
    PrefKeys.settingsNotificationsWaterReminders,
    PrefKeys.settingsNotificationsSleepReminderEnabled,
    PrefKeys.settingsNotificationsSleepBedtime,
    PrefKeys.settingsNotificationsSleepWakeTime,
  ];

  @override
  Future<NotificationSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final auth = ref.watch(authSessionProvider);
    final userId = auth.canAccessProtectedData ? auth.user?.id : null;
    final scoped = _ScopedPreferences(preferences, userId);
    final legacy = _ScopedPreferences(preferences, null);
    final legacyOwner = preferences.getString(_legacyMigrationOwnerKey);
    final canConsumeLegacy =
        userId != null && (legacyOwner == null || legacyOwner == userId);
    final permissionState = await ref
        .read(notificationPermissionServiceProvider)
        .getPermissionState();
    // Times are intentionally *not* defaulted here: a null `sleepBedtime` /
    // `dndStartTime` means "user never picked one". The list page renders
    // "未设置" for that case; the sub-page shows a placeholder until the
    // user toggles the feature on (which persists a default). This keeps the
    // two surfaces in sync instead of the previous behavior where the list
    // said "未设置" but the sub-page showed a phantom 22:00.
    final local = NotificationSettingsState(
      medicationReminders: legacy.getBool(_medicationKey) ?? true,
      healthAlerts:
          scoped.getBool(_healthAlertsKey) ??
          (canConsumeLegacy ? legacy.getBool(_healthAlertsKey) : null) ??
          true,
      weeklySummary:
          scoped.getBool(_weeklySummaryKey) ??
          (canConsumeLegacy ? legacy.getBool(_weeklySummaryKey) : null) ??
          false,
      waterReminders:
          scoped.getBool(_waterRemindersKey) ??
          (canConsumeLegacy ? legacy.getBool(_waterRemindersKey) : null) ??
          true,
      sleepReminders: legacy.getBool(_sleepRemindersKey) ?? true,
      sleepReminderEnabled:
          scoped.getBool(_sleepReminderEnabledKey) ??
          (canConsumeLegacy
              ? legacy.getBool(_sleepReminderEnabledKey)
              : null) ??
          false,
      sleepBedtime: _parseTime(
        scoped.getString(_sleepBedtimeKey) ??
            (canConsumeLegacy ? legacy.getString(_sleepBedtimeKey) : null),
      ),
      sleepWakeTime: _parseTime(
        scoped.getString(_sleepWakeTimeKey) ??
            (canConsumeLegacy ? legacy.getString(_sleepWakeTimeKey) : null),
      ),
      permissionState: permissionState,
      dndEnabled: legacy.getBool(_dndEnabledKey) ?? false,
      dndStartTime: _parseTime(legacy.getString(_dndStartTimeKey)),
      dndEndTime: _parseTime(legacy.getString(_dndEndTimeKey)),
      notificationSoundEnabled: legacy.getBool(_soundEnabledKey) ?? true,
      notificationVibrationEnabled:
          legacy.getBool(_vibrationEnabledKey) ?? true,
      reminderAdvanceMinutes: legacy.getInt(_reminderAdvanceMinutesKey) ?? 0,
    );

    if (userId == null) {
      return local;
    }

    try {
      final remote = await ref
          .read(notificationPreferencesRepositoryProvider)
          .getPreferences();
      if (!remote.configured) {
        final migrationCompleted =
            scoped.getBool(
              PrefKeys.settingsNotificationsRemoteMigrationCompleted,
            ) ??
            false;
        if (!migrationCompleted) {
          final migrated = await ref
              .read(notificationPreferencesRepositoryProvider)
              .patchPreferences(_toRemotePatch(local));
          await scoped.setBool(
            PrefKeys.settingsNotificationsRemoteMigrationCompleted,
            true,
          );
          await _claimLegacyMigration(
            preferences,
            userId,
            legacyOwner: legacyOwner,
          );
          await _cacheRemote(preferences, migrated, userId);
          return _applyRemote(local, migrated);
        }
        return local;
      }

      await scoped.setBool(
        PrefKeys.settingsNotificationsRemoteMigrationCompleted,
        true,
      );
      await _claimLegacyMigration(
        preferences,
        userId,
        legacyOwner: legacyOwner,
      );
      await _cacheRemote(preferences, remote, userId);
      return _applyRemote(local, remote);
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('NotificationSettingsController: remote sync failed: $error');
      // Keep local values and leave the migration marker unset so the next
      // authenticated build can retry a failed first sync.
      return local;
    }
  }

  Future<void> requestPermission() async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    final service = ref.read(notificationPermissionServiceProvider);
    final permissionState = await service.requestPermission();
    // If the system permanently denied notifications, the in-app request
    // dialog can never show again. Redirect the user to OS settings.
    if (permissionState == NotificationPermissionState.permanentlyDenied) {
      await service.openSystemSettings();
    }
    state = AsyncData(current.copyWith(permissionState: permissionState));
  }

  /// Directly opens OS app settings so the user can re-enable notifications
  /// after a permanent denial, then refreshes the permission state.
  Future<void> openSystemSettings() async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    final service = ref.read(notificationPermissionServiceProvider);
    await service.openSystemSettings();
    final permissionState = await service.getPermissionState();
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

  Future<void> setSleepReminders(bool enabled) async {
    final next = (state.asData?.value ?? const NotificationSettingsState())
        .copyWith(sleepReminders: enabled);
    await _save(
      next,
      update: (preferences) => preferences.setBool(_sleepRemindersKey, enabled),
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
          await preferences.setString(_dndStartTimeKey, _formatTime(start));
        }
        if (end != null) {
          await preferences.setString(_dndEndTimeKey, _formatTime(end));
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
          final scoped = _ScopedPreferences(preferences, userId);
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

  Future<void> _saveRemotePreference({
    required NotificationPreferencesPatch patch,
    required NotificationSettingsState Function(
      NotificationSettingsState current,
    )
    update,
  }) async {
    final operation = _remoteMutationTail.then<void>(
      (_) => _performRemotePreference(patch: patch, update: update),
    );
    _remoteMutationTail = operation.catchError((_) {});
    return operation;
  }

  Future<void> _performRemotePreference({
    required NotificationPreferencesPatch patch,
    required NotificationSettingsState Function(
      NotificationSettingsState current,
    )
    update,
  }) async {
    final current = state.asData?.value ?? const NotificationSettingsState();
    final next = update(current);
    final auth = ref.read(authSessionProvider);
    final userId = auth.canAccessProtectedData ? auth.user?.id : null;
    if (userId == null) {
      await _save(
        next,
        update: (preferences) =>
            _writeRemoteLocal(_ScopedPreferences(preferences, null), next),
      );
      return;
    }

    state = AsyncData(next);
    try {
      final remote = await ref
          .read(notificationPreferencesRepositoryProvider)
          .patchPreferences(patch);
      final preferences = await SharedPreferences.getInstance();
      await _cacheRemote(preferences, remote, userId);
      state = AsyncData(_applyRemote(next, remote));
    } catch (error) {
      final preferences = await SharedPreferences.getInstance();
      await _writeRemoteLocal(_ScopedPreferences(preferences, userId), current);
      state = AsyncData(current);
      rethrow;
    }
  }

  Future<void> _claimLegacyMigration(
    SharedPreferences preferences,
    String userId, {
    required String? legacyOwner,
  }) async {
    if (legacyOwner != null && legacyOwner != userId) return;

    final legacy = _ScopedPreferences(preferences, null);
    if (legacyOwner == null) {
      await preferences.setString(_legacyMigrationOwnerKey, userId);
    }
    for (final key in _legacyRemoteKeys) {
      await legacy.remove(key);
    }
    await legacy.remove(PrefKeys.settingsNotificationsRemoteMigrationCompleted);
  }

  NotificationPreferencesPatch _toRemotePatch(NotificationSettingsState value) {
    return NotificationPreferencesPatch(
      healthAlertsEnabled: value.healthAlerts,
      weeklyInsightEnabled: value.weeklySummary,
      waterRemindersEnabled: value.waterReminders,
      sleepReminderEnabled: value.sleepReminderEnabled,
      sleepBedtimeMinutes: _toMinutes(value.sleepBedtime),
      sleepWakeTimeMinutes: _toMinutes(value.sleepWakeTime),
    );
  }

  NotificationSettingsState _applyRemote(
    NotificationSettingsState local,
    NotificationPreferences remote,
  ) {
    return local.copyWith(
      healthAlerts: remote.healthAlertsEnabled,
      weeklySummary: remote.weeklyInsightEnabled,
      waterReminders: remote.waterRemindersEnabled,
      sleepReminderEnabled: remote.sleepReminderEnabled,
      sleepBedtime: _fromMinutes(remote.sleepBedtimeMinutes),
      sleepWakeTime: _fromMinutes(remote.sleepWakeTimeMinutes),
    );
  }

  Future<void> _cacheRemote(
    SharedPreferences preferences,
    NotificationPreferences remote,
    String userId,
  ) async {
    final value = _applyRemote(
      const NotificationSettingsState(sleepBedtime: null, sleepWakeTime: null),
      remote,
    );
    await _writeRemoteLocal(_ScopedPreferences(preferences, userId), value);
  }

  Future<void> _writeRemoteLocal(
    _ScopedPreferences scoped,
    NotificationSettingsState value,
  ) async {
    await scoped.setBool(_healthAlertsKey, value.healthAlerts);
    await scoped.setBool(_weeklySummaryKey, value.weeklySummary);
    await scoped.setBool(_waterRemindersKey, value.waterReminders);
    await scoped.setBool(_sleepReminderEnabledKey, value.sleepReminderEnabled);
    if (value.sleepBedtime == null) {
      await scoped.remove(_sleepBedtimeKey);
    } else {
      await scoped.setString(
        _sleepBedtimeKey,
        _formatTime(value.sleepBedtime!),
      );
    }
    if (value.sleepWakeTime == null) {
      await scoped.remove(_sleepWakeTimeKey);
    } else {
      await scoped.setString(
        _sleepWakeTimeKey,
        _formatTime(value.sleepWakeTime!),
      );
    }
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static int? _toMinutes(TimeOfDay? time) =>
      time == null ? null : time.hour * 60 + time.minute;

  static TimeOfDay? _fromMinutes(int? minutes) {
    if (minutes == null || minutes < 0 || minutes > 1439) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
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

class _ScopedPreferences {
  _ScopedPreferences(this._preferences, this._userId);

  final SharedPreferences _preferences;
  final String? _userId;

  String _key(String key) {
    final userId = _userId;
    return userId == null
        ? key
        : PrefKeys.settingsNotificationsScoped(key, userId);
  }

  bool? getBool(String key) => _preferences.getBool(_key(key));

  int? getInt(String key) => _preferences.getInt(_key(key));

  String? getString(String key) => _preferences.getString(_key(key));

  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(_key(key), value);

  Future<bool> setInt(String key, int value) =>
      _preferences.setInt(_key(key), value);

  Future<bool> setString(String key, String value) =>
      _preferences.setString(_key(key), value);

  Future<bool> remove(String key) => _preferences.remove(_key(key));
}
