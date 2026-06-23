import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_settings_controller.freezed.dart';

@freezed
abstract class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState({
    @Default(true) bool medicationReminders,
    @Default(true) bool healthAlerts,
    @Default(false) bool weeklySummary,
    @Default(true) bool waterReminders,
    @Default(true) bool sleepReminders,
    @Default(NotificationPermissionState.unsupported)
    NotificationPermissionState permissionState,
  }) = _NotificationSettingsState;
}

class NotificationSettingsController
    extends AsyncNotifier<NotificationSettingsState> {
  static const _medicationKey = 'settings.notifications.medicationReminders';
  static const _healthAlertsKey = 'settings.notifications.healthAlerts';
  static const _weeklySummaryKey = 'settings.notifications.weeklySummary';
  static const _waterRemindersKey = 'settings.notifications.waterReminders';
  static const _sleepRemindersKey = 'settings.notifications.sleepReminders';

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
      permissionState: permissionState,
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
}

final notificationSettingsControllerProvider =
    AsyncNotifierProvider<
      NotificationSettingsController,
      NotificationSettingsState
    >(NotificationSettingsController.new);
