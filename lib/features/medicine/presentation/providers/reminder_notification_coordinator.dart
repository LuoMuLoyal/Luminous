import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/services/reminder_notification_planner.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reminder_notification_coordinator.g.dart';

const medicineReminderScheduledNotificationIdsStorageKey =
    'medicine.reminder.scheduledNotificationIds';

class MedicineReminderNotificationCoordinator {
  MedicineReminderNotificationCoordinator({
    required this.gateway,
    required this.planner,
  });

  final LocalNotificationGateway gateway;
  final MedicineReminderNotificationPlanner planner;

  Future<void> resync({
    required List<MedicineReminderItem> reminders,
    required bool remindersEnabled,
    required MedicineReminderSoundPreference sound,
    required MedicineReminderNotificationTexts texts,
    DateTime? now,
    int advanceMinutes = 0,
    bool dndEnabled = false,
    int dndStartHour = 22,
    int dndStartMinute = 0,
    int dndEndHour = 7,
    int dndEndMinute = 0,
    bool enableVibration = true,
    bool soundEnabled = true,
  }) async {
    if (!await gateway.ensureInitialized()) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final previousIds =
        preferences.getStringList(
          medicineReminderScheduledNotificationIdsStorageKey,
        ) ??
        const <String>[];

    for (final id in previousIds) {
      final parsedId = int.tryParse(id);
      if (parsedId == null) {
        continue;
      }
      await gateway.cancel(parsedId);
    }

    if (!remindersEnabled) {
      await preferences.setStringList(
        medicineReminderScheduledNotificationIdsStorageKey,
        const <String>[],
      );
      return;
    }

    final planned = planner.plan(
      reminders: reminders,
      remindersEnabled: remindersEnabled,
      sound: sound,
      texts: texts,
      now: now,
      advanceMinutes: advanceMinutes,
      dndEnabled: dndEnabled,
      dndStartHour: dndStartHour,
      dndStartMinute: dndStartMinute,
      dndEndHour: dndEndHour,
      dndEndMinute: dndEndMinute,
      enableVibration: enableVibration,
      soundEnabled: soundEnabled,
    );

    for (final notification in planned) {
      await gateway.schedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledAt: notification.scheduledAt,
        playSound: notification.playSound,
        enableVibration: notification.enableVibration,
        channelName: texts.channelName,
        channelDescription: texts.channelDescription,
        payload: notification.payload,
      );
    }

    await preferences.setStringList(
      medicineReminderScheduledNotificationIdsStorageKey,
      planned.map((item) => item.id.toString()).toList(growable: false),
    );
  }
}

@riverpod
MedicineReminderNotificationPlanner medicineReminderNotificationPlanner(
  Ref ref,
) {
  return const MedicineReminderNotificationPlanner();
}

@riverpod
MedicineReminderNotificationCoordinator medicineReminderNotificationCoordinator(
  Ref ref,
) {
  return MedicineReminderNotificationCoordinator(
    gateway: ref.watch(localNotificationGatewayProvider),
    planner: ref.watch(medicineReminderNotificationPlannerProvider),
  );
}

@riverpod
DateTime Function() medicineReminderNotificationNow(Ref ref) {
  return DateTime.now;
}

final medicineReminderNotificationSyncProvider = FutureProvider<void>((
  ref,
) async {
  final auth = ref.watch(authSessionProvider);
  if (auth.isLoading) {
    return;
  }

  final settings = ref
      .watch(notificationSettingsControllerProvider)
      .asData
      ?.value;
  if (settings == null) {
    return;
  }

  final coordinator = ref.watch(
    medicineReminderNotificationCoordinatorProvider,
  );
  final texts = _notificationTexts(ref);
  final now = ref.watch(medicineReminderNotificationNowProvider)();

  if (!auth.canAccessProtectedData) {
    await coordinator.resync(
      reminders: const <MedicineReminderItem>[],
      remindersEnabled: false,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );
    return;
  }

  final remindersEnabled =
      settings.medicationReminders &&
      settings.permissionState == NotificationPermissionState.granted;
  if (!remindersEnabled) {
    await coordinator.resync(
      reminders: const <MedicineReminderItem>[],
      remindersEnabled: false,
      sound: MedicineReminderSoundPreference.defaultTone,
      texts: texts,
      now: now,
    );
    return;
  }

  final sound = ref.watch(medicineReminderSoundProvider).asData?.value;
  if (sound == null) {
    return;
  }

  try {
    final reminders = await ref.watch(medicineReminderListProvider.future);
    await coordinator.resync(
      reminders: reminders,
      remindersEnabled: true,
      sound: sound,
      texts: texts,
      now: now,
      advanceMinutes: settings.reminderAdvanceMinutes,
      dndEnabled: settings.dndEnabled,
      dndStartHour: settings.dndStartTime?.hour ?? 22,
      dndStartMinute: settings.dndStartTime?.minute ?? 0,
      dndEndHour: settings.dndEndTime?.hour ?? 7,
      dndEndMinute: settings.dndEndTime?.minute ?? 0,
      enableVibration: settings.notificationVibrationEnabled,
      soundEnabled: settings.notificationSoundEnabled,
    );
  } catch (e) {
    ref
        .read(talkerProvider)
        .error('MedicineReminderNotificationCoordinator: resync failed: $e');
    return;
  }
});

MedicineReminderNotificationTexts _notificationTexts(Ref ref) {
  final currentLocale =
      ref.watch(appLocaleControllerProvider).asData?.value ?? AppLocale.system;
  final locale =
      currentLocale.flutterLocale ?? ui.PlatformDispatcher.instance.locale;
  final l10n = lookupAppLocalizations(locale);

  return MedicineReminderNotificationTexts(
    defaultTitle: l10n.medicineReminderNotificationDefaultTitle,
    defaultBody: l10n.medicineReminderNotificationDefaultBody,
    channelName: l10n.medicineReminderNotificationChannelName,
    channelDescription: l10n.medicineReminderNotificationChannelDescription,
  );
}
