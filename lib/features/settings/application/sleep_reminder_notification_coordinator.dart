import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SleepReminderNotificationCoordinator {
  SleepReminderNotificationCoordinator({
    required this.gateway,
    this.horizonDays = 7,
  });

  static const _notificationIdBase = 2_100_000;

  final LocalNotificationGateway gateway;
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
    final initialized = await gateway.ensureInitialized();

    final preferences = await SharedPreferences.getInstance();
    final previousIds =
        preferences.getStringList(
          PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
        ) ??
        const <String>[];
    for (final value in previousIds) {
      final id = int.tryParse(value);
      if (id != null) await gateway.cancel(id);
    }

    if (!initialized) {
      await _writeIds(preferences, const <int>[]);
      return false;
    }

    if (!enabled ||
        permissionState != NotificationPermissionState.granted ||
        bedtimeMinutes == null) {
      await _writeIds(preferences, const <int>[]);
      return true;
    }

    final referenceNow = now ?? DateTime.now();
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
      final scheduled = await gateway.schedule(
        id: id,
        title: texts.title,
        body: texts.body,
        scheduledAt: date,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        channelName: texts.channelName,
        channelDescription: texts.channelDescription,
        payload: 'sleep_reminder:${date.year}-${date.month}-${date.day}',
      );
      allScheduled = allScheduled && scheduled;
    }

    await _writeIds(preferences, plannedIds);
    return allScheduled;
  }

  bool _isInDndWindow(int minute, int start, int end) {
    if (start == end) return true;
    if (start < end) return minute >= start && minute < end;
    return minute >= start || minute < end;
  }

  Future<void> _writeIds(SharedPreferences preferences, List<int> ids) {
    return preferences.setStringList(
      PrefKeys.settingsNotificationsSleepScheduledNotificationIds,
      ids.map((id) => id.toString()).toList(growable: false),
    );
  }
}

final sleepReminderNotificationCoordinatorProvider =
    Provider<SleepReminderNotificationCoordinator>((ref) {
      return SleepReminderNotificationCoordinator(
        gateway: ref.watch(localNotificationGatewayProvider),
      );
    });

final sleepReminderNotificationSyncProvider = FutureProvider<void>((ref) async {
  final auth = ref.watch(authSessionProvider);
  final settings = ref
      .watch(notificationSettingsControllerProvider)
      .asData
      ?.value;
  if (settings == null) return;

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
    enabled: auth.canAccessProtectedData && settings.sleepReminderEnabled,
    bedtimeMinutes: settings.sleepBedtimeMinutes,
    permissionState: settings.permissionState,
    dndEnabled: settings.dndEnabled,
    dndStartMinutes:
        (settings.dndStartTime?.hour ?? 22) * 60 +
        (settings.dndStartTime?.minute ?? 0),
    dndEndMinutes:
        (settings.dndEndTime?.hour ?? 7) * 60 +
        (settings.dndEndTime?.minute ?? 0),
    soundEnabled: settings.notificationSoundEnabled,
    vibrationEnabled: settings.notificationVibrationEnabled,
    texts: texts,
  );
});
