import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:luminous/viewmodels/reminder.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inited = false;

  static const String _channelId = 'luminous_reminders';
  static const String _channelName = '用药提醒';
  static const String _channelDescription = '按计划提醒你按时用药';

  Future<void> init() async {
    if (_inited) {
      return;
    }

    // tz init (used by zonedSchedule)
    tz.initializeTimeZones();
    await _trySetLocalTimezone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);

    // Create channel eagerly to avoid missing notifications on some devices.
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _inited = true;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll(List<ReminderPlan> reminders) async {
    await init();
    final granted = await _ensureNotificationPermission();
    if (!granted) {
      // User denied permission: keep reminders saved but no scheduling.
      return;
    }

    await cancelAll();

    final scheduleMode = await _chooseAndroidScheduleMode();

    for (final r in reminders) {
      if (!r.enabled) continue;
      if (r.repeatRule.trim().toLowerCase() != 'daily') continue;
      if (r.method.trim().toLowerCase() != 'notification') continue;
      if (r.id.trim().isEmpty) continue;

      final hm = _parseHourMinute(r.time);
      if (hm == null) continue;

      final notificationId = _stableHash32('reminder:${r.id}');
      final scheduled = _nextInstanceOfTime(hm.$1, hm.$2);

      final title = r.productName.trim().isEmpty ? '用药提醒' : r.productName.trim();
      final body = r.subtitle.trim().isEmpty ? '请按时用药' : r.subtitle.trim();

      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _trySetLocalTimezone() async {
    // flutter_timezone doesn't support all platforms (e.g. web); keep it best-effort.
    if (kIsWeb) {
      return;
    }
    try {
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Ignore: fall back to default tz.local.
    }
  }

  Future<bool> _ensureNotificationPermission() async {
    if (kIsWeb) {
      return false;
    }

    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    final next = await Permission.notification.request();
    return next.isGranted;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<AndroidScheduleMode> _chooseAndroidScheduleMode() async {
    if (kIsWeb) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    try {
      final can = await android.canScheduleExactNotifications();
      if (can == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
      final granted = await android.requestExactAlarmsPermission();
      if (granted == true) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    } catch (_) {}

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }
}

(int, int)? _parseHourMinute(String time) {
  final t = time.trim();
  if (t.length != 5 || !t.contains(':')) {
    return null;
  }
  final parts = t.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23) return null;
  if (m < 0 || m > 59) return null;
  return (h, m);
}

int _stableHash32(String input) {
  // FNV-1a 32-bit
  const int fnvPrime = 0x01000193;
  int hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
