import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/data/providers/notification_permission_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
    SharedPreferences.setMockInitialValues(
      initialValues ?? const <String, Object>{},
    );
    final c = ProviderContainer(
      overrides: [
        notificationPermissionServiceProvider.overrideWithValue(
          _FakeNotificationPermissionService(),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('build – initial load', () {
    test('uses default values when no preferences are stored', () async {
      container = buildContainer();

      final state = await container.read(
        notificationSettingsControllerProvider.future,
      );

      expect(state.medicationReminders, isTrue);
      expect(state.healthAlerts, isTrue);
      expect(state.weeklySummary, isFalse);
      expect(state.waterReminders, isTrue);
      expect(state.sleepReminders, isTrue);
      expect(state.sleepReminderEnabled, isFalse);
      expect(state.sleepBedtime, const TimeOfDay(hour: 23, minute: 0));
      expect(state.sleepWakeTime, const TimeOfDay(hour: 7, minute: 0));
    });

    test('loads persisted sleep reminder values', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.notifications.sleepReminderEnabled': true,
          'settings.notifications.sleepBedtime': '22:30',
          'settings.notifications.sleepWakeTime': '06:45',
        },
      );

      final state = await container.read(
        notificationSettingsControllerProvider.future,
      );

      expect(state.sleepReminderEnabled, isTrue);
      expect(state.sleepBedtime, const TimeOfDay(hour: 22, minute: 30));
      expect(state.sleepWakeTime, const TimeOfDay(hour: 6, minute: 45));
    });

    test('falls back to defaults for malformed time strings', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.notifications.sleepBedtime': 'invalid',
          'settings.notifications.sleepWakeTime': 'ab:cd',
        },
      );

      final state = await container.read(
        notificationSettingsControllerProvider.future,
      );

      expect(state.sleepBedtime, const TimeOfDay(hour: 23, minute: 0));
      expect(state.sleepWakeTime, const TimeOfDay(hour: 7, minute: 0));
    });
  });

  group('setSleepReminderEnabled', () {
    test('toggles sleep reminder and persists the value', () async {
      container = buildContainer();

      await container.read(notificationSettingsControllerProvider.future);

      await container
          .read(notificationSettingsControllerProvider.notifier)
          .setSleepReminderEnabled(true);

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.value?.sleepReminderEnabled, isTrue);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool('settings.notifications.sleepReminderEnabled'),
        isTrue,
      );
    });
  });

  group('setSleepBedtime', () {
    test('saves selected bedtime as HH:mm', () async {
      container = buildContainer();

      await container.read(notificationSettingsControllerProvider.future);

      await container
          .read(notificationSettingsControllerProvider.notifier)
          .setSleepBedtime(const TimeOfDay(hour: 22, minute: 0));

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.value?.sleepBedtime, const TimeOfDay(hour: 22, minute: 0));

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('settings.notifications.sleepBedtime'),
        '22:00',
      );
    });

    test('clears stored bedtime when set to null', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.notifications.sleepBedtime': '22:00',
        },
      );

      await container.read(notificationSettingsControllerProvider.future);

      await container
          .read(notificationSettingsControllerProvider.notifier)
          .setSleepBedtime(null);

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.value?.sleepBedtime, isNull);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.containsKey('settings.notifications.sleepBedtime'),
        isFalse,
      );
    });
  });

  group('setSleepWakeTime', () {
    test('saves selected wake time as HH:mm', () async {
      container = buildContainer();

      await container.read(notificationSettingsControllerProvider.future);

      await container
          .read(notificationSettingsControllerProvider.notifier)
          .setSleepWakeTime(const TimeOfDay(hour: 7, minute: 30));

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.value?.sleepWakeTime, const TimeOfDay(hour: 7, minute: 30));

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('settings.notifications.sleepWakeTime'),
        '07:30',
      );
    });
  });

  group('reset', () {
    test('clears all notification preference keys', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'settings.notifications.medicationReminders': false,
          'settings.notifications.healthAlerts': false,
          'settings.notifications.weeklySummary': true,
          'settings.notifications.waterReminders': false,
          'settings.notifications.sleepReminders': false,
          'settings.notifications.sleepReminderEnabled': true,
          'settings.notifications.sleepBedtime': '22:00',
          'settings.notifications.sleepWakeTime': '07:00',
        },
      );

      await container.read(notificationSettingsControllerProvider.future);

      await container
          .read(notificationSettingsControllerProvider.notifier)
          .reset();

      final state = container.read(notificationSettingsControllerProvider);
      expect(state.value?.medicationReminders, isTrue);
      expect(state.value?.healthAlerts, isTrue);
      expect(state.value?.weeklySummary, isFalse);
      expect(state.value?.waterReminders, isTrue);
      expect(state.value?.sleepReminders, isTrue);
      expect(state.value?.sleepReminderEnabled, isFalse);
      expect(state.value?.sleepBedtime, const TimeOfDay(hour: 23, minute: 0));
      expect(state.value?.sleepWakeTime, const TimeOfDay(hour: 7, minute: 0));

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.containsKey('settings.notifications.medicationReminders'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.healthAlerts'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.weeklySummary'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.waterReminders'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.sleepReminders'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.sleepReminderEnabled'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.sleepBedtime'),
        isFalse,
      );
      expect(
        preferences.containsKey('settings.notifications.sleepWakeTime'),
        isFalse,
      );
    });
  });
}

class _FakeNotificationPermissionService extends NotificationPermissionService {
  _FakeNotificationPermissionService() : super(plugin: null);

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    return NotificationPermissionState.unsupported;
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    return NotificationPermissionState.unsupported;
  }
}
