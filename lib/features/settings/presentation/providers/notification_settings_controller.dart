import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.medicationReminders = true,
    this.healthAlerts = true,
    this.weeklySummary = false,
  });

  final bool medicationReminders;
  final bool healthAlerts;
  final bool weeklySummary;

  NotificationSettingsState copyWith({
    bool? medicationReminders,
    bool? healthAlerts,
    bool? weeklySummary,
  }) {
    return NotificationSettingsState(
      medicationReminders: medicationReminders ?? this.medicationReminders,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }
}

class NotificationSettingsController
    extends AsyncNotifier<NotificationSettingsState> {
  static const _medicationKey = 'settings.notifications.medicationReminders';
  static const _healthAlertsKey = 'settings.notifications.healthAlerts';
  static const _weeklySummaryKey = 'settings.notifications.weeklySummary';

  @override
  Future<NotificationSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    return NotificationSettingsState(
      medicationReminders: preferences.getBool(_medicationKey) ?? true,
      healthAlerts: preferences.getBool(_healthAlertsKey) ?? true,
      weeklySummary: preferences.getBool(_weeklySummaryKey) ?? false,
    );
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

  Future<void> reset() async {
    await _save(
      const NotificationSettingsState(),
      update: (preferences) async {
        await preferences.remove(_medicationKey);
        await preferences.remove(_healthAlertsKey);
        await preferences.remove(_weeklySummaryKey);
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
  }
}

final notificationSettingsControllerProvider =
    AsyncNotifierProvider<
      NotificationSettingsController,
      NotificationSettingsState
    >(NotificationSettingsController.new);
