import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/settings/application/sleep_reminder_notification_coordinator.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

import '../helpers/kv_test_store.dart';

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
      KvTestStore.install(
        seed: <String, Object>{
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
            '41',
          ],
        },
      );
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
        KvStore.instance.getOrNull<List<String>>(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ),
        hasLength(7),
      );
    },
  );

  test(
    'does not schedule while permission is denied and clears old plans',
    () async {
      KvTestStore.install(
        seed: <String, Object>{
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
            '41',
          ],
        },
      );
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
        KvStore.instance.getOrNull<List<String>>(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ),
        isEmpty,
      );
    },
  );

  test(
    'skips bedtime moments inside DND without creating a wake alarm',
    () async {
      KvTestStore.install(seed: const <String, Object>{});
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
      KvTestStore.install(
        seed: <String, Object>{
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds: <String>[
            '41',
          ],
        },
      );
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
        KvStore.instance.getOrNull<List<String>>(
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
