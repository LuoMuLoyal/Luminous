import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/data/providers/notification_preferences.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/providers/notification_preferences.dart';
import 'package:luminous/features/settings/presentation/providers/notification_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_mapping.dart';

part 'notification.freezed.dart';
part 'notification_local_setters.dart';
part 'notification_remote_sync.dart';

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
  int? get sleepBedtimeMinutes => NotificationUtils.toMinutes(sleepBedtime);
  int? get sleepWakeTimeMinutes => NotificationUtils.toMinutes(sleepWakeTime);
}

// 偏好键常量:库级私有,主文件与 part 文件共享同一 scope,可直接无前缀访问。
const _medicationKey = PrefKeys.settingsNotificationsMedicationReminders;
const _healthAlertsKey = PrefKeys.settingsNotificationsHealthAlerts;
const _weeklySummaryKey = PrefKeys.settingsNotificationsWeeklySummary;
const _waterRemindersKey = PrefKeys.settingsNotificationsWaterReminders;
const _sleepRemindersKey = PrefKeys.settingsNotificationsSleepReminders;
const _sleepReminderEnabledKey =
    PrefKeys.settingsNotificationsSleepReminderEnabled;
const _sleepBedtimeKey = PrefKeys.settingsNotificationsSleepBedtime;
const _sleepWakeTimeKey = PrefKeys.settingsNotificationsSleepWakeTime;
const _dndEnabledKey = PrefKeys.settingsNotificationsDndEnabled;
const _dndStartTimeKey = PrefKeys.settingsNotificationsDndStartTime;
const _dndEndTimeKey = PrefKeys.settingsNotificationsDndEndTime;
const _soundEnabledKey = PrefKeys.settingsNotificationsSoundEnabled;
const _vibrationEnabledKey = PrefKeys.settingsNotificationsVibrationEnabled;
const _reminderAdvanceMinutesKey =
    PrefKeys.settingsNotificationsReminderAdvanceMinutes;
const _legacyMigrationOwnerKey =
    PrefKeys.settingsNotificationsLegacyMigrationOwner;

/// 由 [reset] 清空的全部偏好键。集中在一处,新增设置不会遗漏清理路径。
const _resetKeys = <String>[
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

const _legacyRemoteKeys = <String>[
  PrefKeys.settingsNotificationsHealthAlerts,
  PrefKeys.settingsNotificationsWeeklySummary,
  PrefKeys.settingsNotificationsWaterReminders,
  PrefKeys.settingsNotificationsSleepReminderEnabled,
  PrefKeys.settingsNotificationsSleepBedtime,
  PrefKeys.settingsNotificationsSleepWakeTime,
];

int? _toMinutes(TimeOfDay? time) => NotificationUtils.toMinutes(time);

TimeOfDay? _parseTime(String? value) => NotificationUtils.parseTime(value);

/// 抽象基类:持有通知偏好控制器的共享实例成员(setter mixin 与具体控制器
/// 都基于它),按职责拆成 part 文件后每个文件都低于 450 行。
abstract class NotificationSettingsControllerCore
    extends AsyncNotifier<NotificationSettingsState> {
  Future<void> _remoteMutationTail = Future<void>.value();

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
            _writeRemoteLocal(ScopedPreferences(preferences, null), next),
      );
      return;
    }

    state = AsyncData(next);
    try {
      final result = await ref
          .read(notificationPreferencesRepositoryProvider)
          .patchPreferences(patch)
          .run();
      final remote = result.fold((failure) => throw failure, (value) => value);
      final preferences = await SharedPreferences.getInstance();
      await _cacheRemote(preferences, remote, userId);
      state = AsyncData(_applyRemote(next, remote));
    } catch (error) {
      final preferences = await SharedPreferences.getInstance();
      await _writeRemoteLocal(ScopedPreferences(preferences, userId), current);
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

    final legacy = ScopedPreferences(preferences, null);
    if (legacyOwner == null) {
      await preferences.setString(_legacyMigrationOwnerKey, userId);
    }
    for (final key in _legacyRemoteKeys) {
      await legacy.remove(key);
    }
    await legacy.remove(PrefKeys.settingsNotificationsRemoteMigrationCompleted);
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
      sleepBedtime: NotificationUtils.fromMinutes(remote.sleepBedtimeMinutes),
      sleepWakeTime: NotificationUtils.fromMinutes(remote.sleepWakeTimeMinutes),
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
    await _writeRemoteLocal(ScopedPreferences(preferences, userId), value);
  }

  Future<void> _writeRemoteLocal(
    ScopedPreferences scoped,
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
        NotificationUtils.formatTime(value.sleepBedtime!),
      );
    }
    if (value.sleepWakeTime == null) {
      await scoped.remove(_sleepWakeTimeKey);
    } else {
      await scoped.setString(
        _sleepWakeTimeKey,
        NotificationUtils.formatTime(value.sleepWakeTime!),
      );
    }
  }
}

/// 通知偏好控制器:构建本地状态、执行远程同步,并暴露本地/远程两类 setter。
///
/// setter 方法以 mixin 形式分布在 part 文件
/// (`notification_local_setters.dart`、`notification_remote_sync.dart`)。
class NotificationSettingsController extends NotificationSettingsControllerCore
    with NotificationLocalSetters, NotificationRemoteSync {
  @override
  Future<NotificationSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final auth = ref.watch(authSessionProvider);
    final userId = auth.canAccessProtectedData ? auth.user?.id : null;
    final scoped = ScopedPreferences(preferences, userId);
    final legacy = ScopedPreferences(preferences, null);
    final legacyOwner = preferences.getString(_legacyMigrationOwnerKey);
    final canConsumeLegacy =
        userId != null && (legacyOwner == null || legacyOwner == userId);
    final permissionState = await ref
        .read(notificationPermissionServiceProvider)
        .getPermissionState();
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
      final result = await ref
          .read(notificationPreferencesRepositoryProvider)
          .getPreferences()
          .run();
      final remote = result.fold((failure) => throw failure, (value) => value);
      if (!remote.configured) {
        final migrationCompleted =
            scoped.getBool(
              PrefKeys.settingsNotificationsRemoteMigrationCompleted,
            ) ??
            false;
        if (!migrationCompleted) {
          final migrated = await ref
              .read(notificationPreferencesRepositoryProvider)
              .patchPreferences(
                buildRemotePatch(
                  healthAlerts: local.healthAlerts,
                  weeklySummary: local.weeklySummary,
                  waterReminders: local.waterReminders,
                  sleepReminderEnabled: local.sleepReminderEnabled,
                  sleepBedtime: local.sleepBedtime,
                  sleepWakeTime: local.sleepWakeTime,
                ),
              )
              .run();
          final migratedValue = migrated.fold(
            (failure) => throw failure,
            (value) => value,
          );
          await scoped.setBool(
            PrefKeys.settingsNotificationsRemoteMigrationCompleted,
            true,
          );
          await _claimLegacyMigration(
            preferences,
            userId,
            legacyOwner: legacyOwner,
          );
          await _cacheRemote(preferences, migratedValue, userId);
          return _applyRemote(local, migratedValue);
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
}

final notificationSettingsControllerProvider =
    AsyncNotifierProvider<
      NotificationSettingsController,
      NotificationSettingsState
    >(NotificationSettingsController.new);
