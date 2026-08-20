import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/settings/application/sleep_reminder_notification_coordinator.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const texts = SleepReminderNotificationTexts(
    title: 'Sleep reminder',
    body: 'Time to wind down for sleep.',
    channelName: 'Sleep reminders',
    channelDescription: 'On-device bedtime reminders.',
  );

  test(
    'cancels old plans and schedules bedtime only across the next week',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
          '41',
        ],
      });
      final gateway = _FakeLocalNotificationGateway();
      final coordinator = SleepReminderNotificationCoordinator(
        gateway: gateway,
      );

      await expectLater(
        coordinator.resync(
          enabled: true,
          bedtimeMinutes: 23 * 60,
          permissionState: NotificationPermissionState.granted,
          texts: texts,
          now: DateTime(2026, 6, 10, 20),
        ),
        completion(isTrue),
      );

      expect(gateway.cancelledIds, <int>[41]);
      expect(gateway.scheduledCalls, hasLength(7));
      expect(
        gateway.scheduledCalls.every((call) => call.scheduledAt.hour == 23),
        isTrue,
      );
      expect(
        gateway.scheduledCalls.every((call) => call.scheduledAt.hour != 7),
        isTrue,
      );
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ),
        hasLength(7),
      );
    },
  );

  test(
    'does not schedule while permission is denied and clears old plans',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
          '41',
        ],
      });
      final gateway = _FakeLocalNotificationGateway();
      final coordinator = SleepReminderNotificationCoordinator(
        gateway: gateway,
      );

      await coordinator.resync(
        enabled: true,
        bedtimeMinutes: 23 * 60,
        permissionState: NotificationPermissionState.denied,
        texts: texts,
        now: DateTime(2026, 6, 10, 20),
      );

      expect(gateway.scheduledCalls, isEmpty);
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ),
        isEmpty,
      );
    },
  );

  test(
    'skips bedtime moments inside DND without creating a wake alarm',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final gateway = _FakeLocalNotificationGateway();
      final coordinator = SleepReminderNotificationCoordinator(
        gateway: gateway,
      );

      await coordinator.resync(
        enabled: true,
        bedtimeMinutes: 23 * 60,
        permissionState: NotificationPermissionState.granted,
        dndEnabled: true,
        dndStartMinutes: 22 * 60,
        dndEndMinutes: 7 * 60,
        texts: texts,
        now: DateTime(2026, 6, 10, 20),
      );

      expect(gateway.scheduledCalls, isEmpty);
    },
  );

  test(
    'clears stored plans when the local notification gateway is unavailable',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
          '41',
        ],
      });
      final gateway = _FakeLocalNotificationGateway(initialized: false);
      final coordinator = SleepReminderNotificationCoordinator(
        gateway: gateway,
      );

      await expectLater(
        coordinator.resync(
          enabled: false,
          bedtimeMinutes: null,
          permissionState: NotificationPermissionState.unsupported,
          texts: texts,
        ),
        completion(isFalse),
      );

      expect(gateway.cancelledIds, <int>[41]);
      expect(
        (await SharedPreferences.getInstance()).getStringList(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ),
        isEmpty,
      );
    },
  );
}

class _FakeLocalNotificationGateway extends LocalNotificationGateway {
  _FakeLocalNotificationGateway({this.initialized = true});

  final bool initialized;
  final cancelledIds = <int>[];
  final scheduledCalls = <_ScheduledCall>[];

  @override
  Future<bool> ensureInitialized() async => initialized;

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<bool> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool playSound,
    required String channelName,
    required String channelDescription,
    String? payload,
    bool enableVibration = true,
  }) async {
    scheduledCalls.add(_ScheduledCall(id: id, scheduledAt: scheduledAt));
    return true;
  }
}

class _ScheduledCall {
  const _ScheduledCall({required this.id, required this.scheduledAt});

  final int id;
  final DateTime scheduledAt;
}
