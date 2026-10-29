import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/settings/application/sleep_reminder_notification_coordinator.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Adapts the local-notification gateway onto the coordinator's scheduler
/// interface.
class GatewaySleepReminderScheduler
    implements SleepReminderNotificationScheduler {
  GatewaySleepReminderScheduler(this._gateway);

  final LocalNotificationGateway _gateway;

  @override
  Future<bool> ensureInitialized() => _gateway.ensureInitialized();

  @override
  Future<void> cancel(int id) => _gateway.cancel(id);

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
  }) {
    return _gateway.schedule(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      playSound: playSound,
      enableVibration: vibrationEnabled,
      channelName: channelName,
      channelDescription: channelDescription,
      payload: payload,
    );
  }
}

/// Adapts the app key-value store onto the coordinator's id store.
class KvSleepReminderScheduledIds implements SleepReminderScheduledIdsStore {
  const KvSleepReminderScheduledIds();

  @override
  Future<List<String>> read() async {
    return KvStore.instance.getOrNull<List<String>>(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ) ??
        const <String>[];
  }

  @override
  Future<void> write(List<String> ids) {
    return KvStore.instance.set(
      PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
      ids,
    );
  }
}

final sleepReminderNotificationCoordinatorProvider =
    Provider<SleepReminderNotificationCoordinator>((ref) {
      return SleepReminderNotificationCoordinator(
        scheduler: GatewaySleepReminderScheduler(
          ref.watch(localNotificationGatewayProvider),
        ),
        scheduledIds: const KvSleepReminderScheduledIds(),
      );
    });

/// Reconciles sleep reminders whenever the session, the notification settings
/// or the locale change.
final sleepReminderNotificationSyncProvider = FutureProvider<void>((ref) async {
  final auth = ref.watch(authSessionProvider);
  final preferences = ref
      .watch(notificationSettingsControllerProvider)
      .asData
      ?.value;
  if (preferences == null) return;

  final localeSetting =
      ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;
  final locale =
      localeSetting.flutterLocale ?? ui.PlatformDispatcher.instance.locale;
  final l10n = lookupAppLocalizations(locale);
  final texts = SleepReminderNotificationTexts(
    title: l10n.settingsNotificationsSleepReminderTitle,
    body: l10n.sleepReminderNotificationBody,
    channelName: l10n.sleepReminderNotificationChannelName,
    channelDescription: l10n.sleepReminderNotificationChannelDescription,
  );
  final coordinator = ref.watch(sleepReminderNotificationCoordinatorProvider);
  await coordinator.resync(
    // The coordinator enforces the permission/bedtime gates itself; the
    // session gate is the only piece that lives here.
    enabled: auth.canAccessProtectedData && preferences.sleepReminderEnabled,
    bedtimeMinutes: preferences.sleepBedtimeMinutes,
    permissionState: preferences.permissionState,
    dndEnabled: preferences.dndEnabled,
    dndStartMinutes:
        (preferences.dndStartTime?.hour ?? 22) * 60 +
        (preferences.dndStartTime?.minute ?? 0),
    dndEndMinutes:
        (preferences.dndEndTime?.hour ?? 7) * 60 +
        (preferences.dndEndTime?.minute ?? 0),
    soundEnabled: preferences.notificationSoundEnabled,
    vibrationEnabled: preferences.notificationVibrationEnabled,
    texts: texts,
  );
});
