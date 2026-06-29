import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/domain/services/medicine_reminder_notification_planner.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/settings/data/services/notification_permission_service.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    );

    for (final notification in planned) {
      await gateway.schedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledAt: notification.scheduledAt,
        playSound: notification.playSound,
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

final medicineReminderNotificationPlannerProvider =
    Provider<MedicineReminderNotificationPlanner>((ref) {
      return const MedicineReminderNotificationPlanner();
    });

final medicineReminderNotificationCoordinatorProvider =
    Provider<MedicineReminderNotificationCoordinator>((ref) {
      return MedicineReminderNotificationCoordinator(
        gateway: ref.watch(localNotificationGatewayProvider),
        planner: ref.watch(medicineReminderNotificationPlannerProvider),
      );
    });

final medicineReminderNotificationNowProvider = Provider<DateTime Function()>((
  ref,
) {
  return DateTime.now;
});

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
    );
  } catch (_) {
    // Keep the existing on-device schedule when reminder data cannot be fetched.
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
