import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationGateway {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _soundingChannelId = 'medicine_reminders';
  static const _silentChannelId = 'medicine_reminders_silent';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _available = false;
  bool _timeZonesInitialized = false;

  Future<bool> ensureInitialized() async {
    if (_initialized) {
      return _available;
    }

    _initialized = true;
    if (kIsWeb || !_supportsLocalSchedulingOnThisPlatform) {
      _available = false;
      return false;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    try {
      await _plugin.initialize(settings);
      _ensureTimeZonesInitialized();
      _available = _hasPlatformPluginBinding;
      return _available;
    } on MissingPluginException {
      _available = false;
      return false;
    } on PlatformException {
      _available = false;
      return false;
    }
  }

  Future<void> cancel(int id) async {
    if (!await ensureInitialized()) {
      return;
    }

    try {
      await _plugin.cancel(id);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool playSound,
    required String channelName,
    required String channelDescription,
    String? payload,
  }) async {
    if (!await ensureInitialized() || !scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.UTC);
    final details = _buildNotificationDetails(
      playSound: playSound,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    final preferredMode = await _preferredAndroidScheduleMode();

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: preferredMode,
        payload: payload,
      );
    } on MissingPluginException {
      return;
    } on PlatformException {
      if (preferredMode == AndroidScheduleMode.exactAllowWhileIdle &&
          defaultTargetPlatform == TargetPlatform.android) {
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            scheduledDate,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: payload,
          );
        } on MissingPluginException {
          return;
        } on PlatformException {
          return;
        }
      }
    }
  }

  bool get _supportsLocalSchedulingOnThisPlatform {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get _hasPlatformPluginBinding {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >() !=
          null;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >() !=
          null;
    }
    return false;
  }

  Future<AndroidScheduleMode> _preferredAndroidScheduleMode() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    try {
      final canScheduleExact =
          await android.canScheduleExactNotifications() ?? false;
      return canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } on MissingPluginException {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    } on PlatformException {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  NotificationDetails _buildNotificationDetails({
    required bool playSound,
    required String channelName,
    required String channelDescription,
  }) {
    final android = AndroidNotificationDetails(
      playSound ? _soundingChannelId : _silentChannelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: playSound,
      silent: !playSound,
    );
    final darwin = DarwinNotificationDetails(
      presentSound: playSound,
      presentBanner: true,
      presentList: true,
      presentAlert: true,
      presentBadge: true,
    );

    return NotificationDetails(android: android, iOS: darwin, macOS: darwin);
  }

  void _ensureTimeZonesInitialized() {
    if (_timeZonesInitialized) {
      return;
    }

    tzdata.initializeTimeZones();
    _timeZonesInitialized = true;
  }
}

final localNotificationGatewayProvider = Provider<LocalNotificationGateway>((
  ref,
) {
  return LocalNotificationGateway();
});
