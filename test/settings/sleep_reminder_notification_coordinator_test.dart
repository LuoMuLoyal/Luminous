import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/application/sleep_reminder_notification_coordinator.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

void main() {
  const texts = SleepReminderNotificationTexts(
    title: 'Sleep reminder',
    body: 'Time to wind down for sleep.',
    channelName: 'Sleep reminders',
    channelDescription: 'On-device bedtime reminders.',
  );

  late _FakeScheduler scheduler;
  late _FakeScheduledIds ids;

  setUp(() {
    scheduler = _FakeScheduler();
    ids = _FakeScheduledIds();
  });

  SleepReminderNotificationCoordinator coordinator() {
    return SleepReminderNotificationCoordinator(
      scheduler: scheduler,
      scheduledIds: ids,
    );
  }

  test(
    'cancels old plans and schedules bedtime only across the next week',
    () async {
      ids.stored = const ['41'];

      await expectLater(
        coordinator().resync(
          enabled: true,
          bedtimeMinutes: 23 * 60,
          permissionState: NotificationPermissionState.granted,
          texts: texts,
          now: DateTime(2026, 6, 10, 20),
        ),
        completion(isTrue),
      );

      expect(scheduler.cancelledIds, <int>[41]);
      expect(scheduler.scheduledCalls, hasLength(7));
      expect(
        scheduler.scheduledCalls.every((call) => call.scheduledAt.hour == 23),
        isTrue,
      );
      expect(
        scheduler.scheduledCalls.every((call) => call.scheduledAt.hour != 7),
        isTrue,
      );
      expect(ids.stored, hasLength(7));
    },
  );

  test(
    'does not schedule while permission is denied and clears old plans',
    () async {
      ids.stored = const ['41'];

      await coordinator().resync(
        enabled: true,
        bedtimeMinutes: 23 * 60,
        permissionState: NotificationPermissionState.denied,
        texts: texts,
        now: DateTime(2026, 6, 10, 20),
      );

      expect(scheduler.scheduledCalls, isEmpty);
      expect(ids.stored, isEmpty);
    },
  );

  test(
    'skips bedtime moments inside DND without creating a wake alarm',
    () async {
      await coordinator().resync(
        enabled: true,
        bedtimeMinutes: 23 * 60,
        permissionState: NotificationPermissionState.granted,
        dndEnabled: true,
        dndStartMinutes: 22 * 60,
        dndEndMinutes: 7 * 60,
        texts: texts,
        now: DateTime(2026, 6, 10, 20),
      );

      expect(scheduler.scheduledCalls, isEmpty);
    },
  );

  test(
    'clears stored plans when the local notification gateway is unavailable',
    () async {
      ids.stored = const ['41'];
      scheduler.initialized = false;

      await expectLater(
        coordinator().resync(
          enabled: false,
          bedtimeMinutes: null,
          permissionState: NotificationPermissionState.unsupported,
          texts: texts,
        ),
        completion(isFalse),
      );

      expect(scheduler.cancelledIds, <int>[41]);
      expect(ids.stored, isEmpty);
    },
  );

  test('the settings snapshot gates on session, flags and bedtime', () {
    SleepReminderSettingsSnapshot snapshot({
      bool signedIn = true,
      bool enabled = true,
      int? bedtime = 1380,
      NotificationPermissionState permission =
          NotificationPermissionState.granted,
    }) {
      return SleepReminderSettingsSnapshot(
        canAccessProtectedData: signedIn,
        preferences: NotificationPreferences(
          healthAlertsEnabled: true,
          weeklyInsightEnabled: false,
          waterRemindersEnabled: true,
          sleepReminderEnabled: enabled,
          sleepBedtimeMinutes: bedtime,
          sleepWakeTimeMinutes: 420,
          configured: true,
          updatedAt: null,
        ),
        permissionState: permission,
        dndEnabled: false,
        dndStartMinutes: 1320,
        dndEndMinutes: 420,
        soundEnabled: true,
        vibrationEnabled: true,
      );
    }

    expect(snapshot().enabled, isTrue);
    expect(snapshot(signedIn: false).enabled, isFalse);
    expect(snapshot(enabled: false).enabled, isFalse);
    expect(snapshot(bedtime: null).enabled, isFalse);
    expect(
      snapshot(permission: NotificationPermissionState.denied).enabled,
      isFalse,
    );
  });
}

class _FakeScheduler implements SleepReminderNotificationScheduler {
  bool initialized = true;
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
    required bool vibrationEnabled,
    required String channelName,
    required String channelDescription,
    required String payload,
  }) async {
    scheduledCalls.add(_ScheduledCall(id: id, scheduledAt: scheduledAt));
    return true;
  }
}

class _FakeScheduledIds implements SleepReminderScheduledIdsStore {
  List<String> stored = const [];

  @override
  Future<List<String>> read() async => stored;

  @override
  Future<void> write(List<String> ids) async => stored = ids;
}

class _ScheduledCall {
  const _ScheduledCall({required this.id, required this.scheduledAt});

  final int id;
  final DateTime scheduledAt;
}
