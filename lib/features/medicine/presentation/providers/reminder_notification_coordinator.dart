import 'dart:async';
import 'dart:ui' as ui;

import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_local_preferences.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/domain/services/reminder_notification_planner.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reminder_notification_coordinator.g.dart';

class MedicineReminderNotificationCoordinator {
  MedicineReminderNotificationCoordinator({
    required this.gateway,
    required this.planner,
    this.preferences = const MedicineReminderLocalPreferences(),
  });

  final LocalNotificationGateway gateway;
  final MedicineReminderNotificationPlanner planner;
  final MedicineReminderLocalPreferences preferences;

  /// Reschedules local notifications for the given reminders and returns
  /// `true` only when the gateway initialized and every scheduled
  /// notification was accepted by the platform.
  Future<bool> resync({
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
      return false;
    }

    final previousIds = await preferences.readScheduledNotificationIds();

    for (final id in previousIds) {
      final parsedId = int.tryParse(id);
      if (parsedId == null) {
        continue;
      }
      await gateway.cancel(parsedId);
    }

    if (!remindersEnabled) {
      await preferences.writeScheduledNotificationIds(const <String>[]);
      return true;
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

    var allScheduled = true;
    for (final notification in planned) {
      final scheduled = await gateway.schedule(
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
      if (!scheduled) {
        allScheduled = false;
      }
    }

    await preferences.writeScheduledNotificationIds(
      planned.map((item) => item.id.toString()).toList(growable: false),
    );
    return allScheduled;
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

@Riverpod(keepAlive: true)
Future<void> medicineReminderNotificationSync(Ref ref) async {
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
    // 未登录:清空本地调度,不上报能力。
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
    _reportLocalCapability(ref, 'disabled');
    return;
  }

  final sound = ref.watch(medicineReminderSoundProvider).asData?.value;
  if (sound == null) {
    return;
  }

  try {
    final reminders = await ref.watch(medicineReminderListProvider.future);
    final allScheduled = await coordinator.resync(
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
    _reportLocalCapability(ref, allScheduled ? 'active' : 'unavailable');
  } catch (e) {
    ref
        .read(talkerProvider)
        .error('MedicineReminderNotificationCoordinator: resync failed: $e');
    _reportLocalCapability(ref, 'unavailable');
  }
}

/// Reports the client's local scheduling capability to the server
/// (fire-and-forget). Never reports when the user is not signed in.
void _reportLocalCapability(Ref ref, String state) {
  final auth = ref.read(authSessionProvider);
  if (!auth.canAccessProtectedData) {
    return;
  }
  final repository = ref.read(reminderRepositoryProvider);
  unawaited(() async {
    try {
      final result = await repository.reportLocalCapability(state).run();
      result.fold(
        (failure) => ref
            .read(talkerProvider)
            .error('reportLocalCapability($state) failed: $failure'),
        (_) {},
      );
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('reportLocalCapability($state) failed: $e');
    }
  }());
}

MedicineReminderNotificationTexts _notificationTexts(Ref ref) {
  final currentLocale =
      ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;
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
