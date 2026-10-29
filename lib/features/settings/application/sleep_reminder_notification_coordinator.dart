import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

/// Plays a scheduled local notification. Implements the platform edge
/// (`core/notifications/local_notification_gateway.dart`); the coordinator only
/// depends on this narrow interface so it stays framework-free.
abstract interface class SleepReminderNotificationScheduler {
  /// Whether the platform can schedule at all.
  Future<bool> ensureInitialized();

  /// Cancels a previously scheduled notification.
  Future<void> cancel(int id);

  /// Schedules a notification; false when the platform refused it.
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
  });
}

/// Persists the ids of the sleep-reminder notifications currently scheduled.
///
/// Implements the local key-value store (`core/storage/kv_store.dart`); kept as
/// an interface so the coordinator never imports `core`.
abstract interface class SleepReminderScheduledIdsStore {
  Future<List<String>> read();

  Future<void> write(List<String> ids);
}

class SleepReminderNotificationTexts {
  const SleepReminderNotificationTexts({
    required this.title,
    required this.body,
    required this.channelName,
    required this.channelDescription,
  });

  final String title;
  final String body;
  final String channelName;
  final String channelDescription;
}

/// Reconciles the on-device sleep reminders with the user's preferences.
///
/// Everything it needs arrives as arguments (gateway, id store, localised
/// texts, the resolved settings snapshot), so the class is plain Dart and can be
/// unit-tested without Riverpod or the notification plugin.
class SleepReminderNotificationCoordinator {
  SleepReminderNotificationCoordinator({
    required this.scheduler,
    required this.scheduledIds,
    this.horizonDays = 7,
  });

  /// Base ID for sleep reminder notifications. IDs are allocated as
  /// `_notificationIdBase + dayOffset` (0 .. horizonDays-1). Keep this
  /// range disjoint from other notification ID bases (e.g. medicine
  /// reminders use 2,000,000). If horizonDays is increased beyond
  /// 1000, update the base to avoid collisions.
  static const _notificationIdBase = 2_100_000;

  final SleepReminderNotificationScheduler scheduler;
  final SleepReminderScheduledIdsStore scheduledIds;
  final int horizonDays;

  Future<bool> resync({
    required bool enabled,
    required int? bedtimeMinutes,
    required NotificationPermissionState permissionState,
    required SleepReminderNotificationTexts texts,
    DateTime? now,
    bool dndEnabled = false,
    int dndStartMinutes = 22 * 60,
    int dndEndMinutes = 7 * 60,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
  }) async {
    final initialized = await scheduler.ensureInitialized();

    final previousIds = await scheduledIds.read();
    for (final value in previousIds) {
      final id = int.tryParse(value);
      if (id != null) await scheduler.cancel(id);
    }

    if (!initialized) {
      await scheduledIds.write(const <String>[]);
      return false;
    }

    if (!enabled ||
        permissionState != NotificationPermissionState.granted ||
        bedtimeMinutes == null) {
      await scheduledIds.write(const <String>[]);
      return true;
    }

    final referenceNow = now ?? DateTime.now();
    assert(
      horizonDays <= 1000,
      'horizonDays ($horizonDays) too large — risk of notification ID collision',
    );
    final plannedIds = <int>[];
    var allScheduled = true;
    for (var dayOffset = 0; dayOffset < horizonDays; dayOffset += 1) {
      final date = DateTime(
        referenceNow.year,
        referenceNow.month,
        referenceNow.day + dayOffset,
        bedtimeMinutes ~/ 60,
        bedtimeMinutes % 60,
      );
      if (!date.isAfter(referenceNow) ||
          (dndEnabled &&
              _isInDndWindow(
                date.hour * 60 + date.minute,
                dndStartMinutes,
                dndEndMinutes,
              ))) {
        continue;
      }

      final id = _notificationIdBase + dayOffset;
      plannedIds.add(id);
      final scheduled = await scheduler.schedule(
        id: id,
        title: texts.title,
        body: texts.body,
        scheduledAt: date,
        playSound: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        channelName: texts.channelName,
        channelDescription: texts.channelDescription,
        payload: 'sleep_reminder:${date.year}-${date.month}-${date.day}',
      );
      allScheduled = allScheduled && scheduled;
    }

    await scheduledIds.write(
      plannedIds.map((id) => id.toString()).toList(growable: false),
    );
    return allScheduled;
  }

  /// Whether [minute] (0–1439) falls inside the DND window.
  ///
  /// When [start] == [end] the window covers the entire day — this is
  /// intentional: it means the user explicitly set both times to the same
  /// value (e.g. 00:00–00:00), which the UI treats as "suppress all sleep
  /// reminders". This is distinct from DND being disabled (controlled by
  /// the `dndEnabled` flag in [resync]); if DND is enabled with identical
  /// start/end, every reminder is suppressed.
  bool _isInDndWindow(int minute, int start, int end) {
    if (start == end) return true;
    if (start < end) return minute >= start && minute < end;
    return minute >= start || minute < end;
  }
}

/// The settings/state the coordinator needs, resolved from the app's providers.
///
/// The presentation adapter fills this from
/// `notificationSettingsControllerProvider`, `authSessionProvider` and the
/// locale controller; keeping it a plain value keeps the coordinator pure.
class SleepReminderSettingsSnapshot {
  const SleepReminderSettingsSnapshot({
    required this.canAccessProtectedData,
    required this.preferences,
    required this.permissionState,
    required this.dndEnabled,
    required this.dndStartMinutes,
    required this.dndEndMinutes,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  /// False when the user is signed out — reminders are suppressed then.
  final bool canAccessProtectedData;
  final NotificationPreferences preferences;
  final NotificationPermissionState permissionState;
  final bool dndEnabled;
  final int dndStartMinutes;
  final int dndEndMinutes;
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// Sleep reminders are only meaningful when enabled, permitted and a bedtime
  /// is configured.
  bool get enabled =>
      canAccessProtectedData &&
      preferences.sleepReminderEnabled &&
      permissionState == NotificationPermissionState.granted &&
      preferences.sleepBedtimeMinutes != null;
}
