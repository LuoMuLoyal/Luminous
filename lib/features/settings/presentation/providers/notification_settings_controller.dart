import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.medicationReminders = true,
    this.healthAlerts = true,
    this.weeklySummary = false,
    this.waterReminders = true,
    this.sleepReminders = true,
    this.permissionState = NotificationPermissionState.unsupported,
  });

  final bool medicationReminders;
  final bool healthAlerts;
  final bool weeklySummary;
  final bool waterReminders;
  final bool sleepReminders;
  final NotificationPermissionState permissionState;

  NotificationSettingsState copyWith({
    bool? medicationReminders,
    bool? healthAlerts,
    bool? weeklySummary,
    bool? waterReminders,
    bool? sleepReminders,
    NotificationPermissionState? permissionState,
  }) {
    return NotificationSettingsState(
      medicationReminders: medicationReminders ?? this.medicationReminders,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      waterReminders: waterReminders ?? this.waterReminders,
      sleepReminders: sleepReminders ?? this.sleepReminders,
      permissionState: permissionState ?? this.permissionState,
    );
  }
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
