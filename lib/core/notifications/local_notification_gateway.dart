import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

part 'local_notification_gateway.g.dart';

class LocalNotificationGateway {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin() {
    _tapController = StreamController<NotificationResponse>.broadcast(
      onListen: _flushPendingTapEvents,
    );
  }

  static const _soundingChannelId = 'medicine_reminders';
  static const _silentChannelId = 'medicine_reminders_silent';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _available = false;
  bool _timeZonesInitialized = false;

  /// The in-flight initialization future. Concurrent callers awaiting
  /// [ensureInitialized] share it instead of racing on `_available` while
  /// the first attempt is still running (which would misreport the gateway
  /// as unavailable).
  Future<bool>? _initializing;

  late final StreamController<NotificationResponse> _tapController;
  final List<NotificationResponse> _pendingTapEvents = <NotificationResponse>[];
  NotificationAppLaunchDetails? _launchDetails;
  bool _launchDetailsEmitted = false;

  /// Tap events (user selects a notification or a notification action),
  /// including the response that launched the app from a cold start.
  ///
  /// The launch-details response is buffered and replayed to the first
  /// listener, mirroring `JpushGateway`'s pending-open-events pattern.
  Stream<NotificationResponse> get tapEvents => _tapController.stream;

  Future<bool> ensureInitialized() {
    if (_initialized) {
      return Future<bool>.value(_available);
    }
    return _initializing ??= _initialize();
  }

  Future<bool> _initialize() async {
    try {
      if (kIsWeb || !_supportsLocalSchedulingOnThisPlatform) {
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
        await _plugin.initialize(
          settings,
          onDidReceiveNotificationResponse: _handleTapResponse,
        );
        _ensureTimeZonesInitialized();
        _available = _hasPlatformPluginBinding;
        await _readLaunchDetails();
        return _available;
      } on MissingPluginException {
        return false;
      } on PlatformException {
        return false;
      } on Error catch (error) {
        if (!_isLateInitializationError(error)) {
          rethrow;
        }
        // The plugin platform binding was never registered (e.g. tests or an
        // exotic embedder); treat the gateway as unavailable instead of
        // crashing the app bootstrap.
        return false;
      }
    } finally {
      _initialized = true;
      _initializing = null;
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
    } on Error catch (error) {
      if (_isLateInitializationError(error)) {
        return;
      }
      rethrow;
    }
  }

  /// Schedules a local notification, returning `true` only when the platform
  /// actually accepted the schedule. Any failure (unsupported platform,
  /// missing plugin binding, or a platform error) returns `false` so callers
  /// can report local scheduling as unavailable.
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
    if (!await ensureInitialized() || !scheduledAt.isAfter(clock.now())) {
      return false;
    }

    final scheduledDate = tz.TZDateTime.from(scheduledAt, tz.UTC);
    final details = _buildNotificationDetails(
      playSound: playSound,
      channelName: channelName,
      channelDescription: channelDescription,
      enableVibration: enableVibration,
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
      return true;
    } on MissingPluginException {
      return false;
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
          return true;
        } on MissingPluginException {
          return false;
        } on PlatformException {
          return false;
        } on Error catch (error) {
          if (_isLateInitializationError(error)) {
            return false;
          }
          rethrow;
        }
      }
      return false;
    } on Error catch (error) {
      if (_isLateInitializationError(error)) {
        return false;
      }
      rethrow;
    }
  }

  /// Returns the notifications currently shown by the OS that have not been
  /// dismissed. Failures (unsupported platform, missing plugin binding) yield
  /// an empty list.
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (!await ensureInitialized()) {
      return const <ActiveNotification>[];
    }

    try {
      return await _plugin.getActiveNotifications();
    } on MissingPluginException {
      return const <ActiveNotification>[];
    } on PlatformException {
      return const <ActiveNotification>[];
    } on UnimplementedError {
      return const <ActiveNotification>[];
    } on Error catch (error) {
      if (_isLateInitializationError(error)) {
        return const <ActiveNotification>[];
      }
      rethrow;
    }
  }

  void _handleTapResponse(NotificationResponse response) {
    _emitTapEvent(response);
  }

  void _emitTapEvent(NotificationResponse response) {
    if (_tapController.hasListener) {
      _tapController.add(response);
      return;
    }
    _pendingTapEvents.add(response);
  }

  void _flushPendingTapEvents() {
    if (_pendingTapEvents.isNotEmpty) {
      final pending = List<NotificationResponse>.of(_pendingTapEvents);
      _pendingTapEvents.clear();
      for (final event in pending) {
        _tapController.add(event);
      }
    }
    if (_launchDetailsEmitted) {
      return;
    }
    _launchDetailsEmitted = true;
    final response = _launchDetails?.notificationResponse;
    if (_launchDetails?.didNotificationLaunchApp == true && response != null) {
      _tapController.add(response);
    }
  }

  Future<void> _readLaunchDetails() async {
    try {
      _launchDetails = await _plugin.getNotificationAppLaunchDetails();
    } on MissingPluginException {
      _launchDetailsEmitted = true;
      return;
    } on PlatformException {
      _launchDetailsEmitted = true;
      return;
    } on Error catch (error) {
      if (!_isLateInitializationError(error)) {
        rethrow;
      }
      _launchDetailsEmitted = true;
      return;
    }
    final response = _launchDetails?.notificationResponse;
    if (_launchDetails?.didNotificationLaunchApp != true || response == null) {
      // Nothing to replay; mark consumed so the flush never emits.
      _launchDetailsEmitted = true;
      return;
    }
    if (_tapController.hasListener) {
      // A listener is already subscribed: deliver immediately.
      _launchDetailsEmitted = true;
      _tapController.add(response);
      return;
    }
    // No listener yet: leave [_launchDetailsEmitted] false so the first
    // listener's flush replays the response from [_launchDetails].
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

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) {
        return AndroidScheduleMode.inexactAllowWhileIdle;
      }

      final canScheduleExact =
          await android.canScheduleExactNotifications() ?? false;
      return canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } on MissingPluginException {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    } on PlatformException {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    } on Error catch (error) {
      if (_isLateInitializationError(error)) {
        return AndroidScheduleMode.inexactAllowWhileIdle;
      }
      rethrow;
    }
  }

  /// Dart 3.12 surfaces late-initialization failures only as the internal
  /// `LateError` (there is no public `LateInitializationError` type), so the
  /// error is recognized by message. This turns an unregistered platform
  /// plugin binding (e.g. in tests or an exotic embedder) into a graceful
  /// "unavailable" result instead of an unhandled async error, without
  /// swallowing unrelated programming errors.
  bool _isLateInitializationError(Error error) {
    return error.toString().startsWith('LateInitializationError');
  }

  NotificationDetails _buildNotificationDetails({
    required bool playSound,
    required String channelName,
    required String channelDescription,
    bool enableVibration = true,
  }) {
    final android = AndroidNotificationDetails(
      playSound ? _soundingChannelId : _silentChannelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: playSound && enableVibration,
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

@riverpod
LocalNotificationGateway localNotificationGateway(Ref ref) {
  return LocalNotificationGateway();
}
