import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

enum NotificationPermissionState { granted, denied, unsupported }

class NotificationPermissionService {
  NotificationPermissionService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
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
      _initialized = true;
    } on MissingPluginException {
      _initialized = false;
    } on PlatformException {
      _initialized = false;
    }
  }

  Future<NotificationPermissionState> getPermissionState() async {
    await ensureInitialized();

    if (kIsWeb) {
      return NotificationPermissionState.unsupported;
    }

    final pluginState = await _pluginPermissionState();
    if (pluginState != null) {
      return pluginState
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }

    final status = await Permission.notification.status;
    if (status.isGranted) {
      return NotificationPermissionState.granted;
    }
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      return NotificationPermissionState.denied;
    }
    return NotificationPermissionState.unsupported;
  }

  Future<NotificationPermissionState> requestPermission() async {
    await ensureInitialized();

    if (kIsWeb) {
      return NotificationPermissionState.unsupported;
    }

    final pluginResult = await _requestPluginPermission();
    if (pluginResult != null) {
      return pluginResult
          ? NotificationPermissionState.granted
          : NotificationPermissionState.denied;
    }

    final status = await Permission.notification.request();
    return status.isGranted
        ? NotificationPermissionState.granted
        : NotificationPermissionState.denied;
  }

  Future<bool?> _requestPluginPermission() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      try {
        return await android.requestNotificationsPermission();
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    final ios =
        _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      try {
        return await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    final macos =
        _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      try {
        return await macos.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    return null;
  }

  Future<bool?> _pluginPermissionState() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      try {
        return await android.areNotificationsEnabled();
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    final ios =
        _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      try {
        final permissions = await ios.checkPermissions();
        return permissions?.isEnabled ?? false;
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    final macos =
        _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macos != null) {
      try {
        final permissions = await macos.checkPermissions();
        return permissions?.isEnabled ?? false;
      } on MissingPluginException {
        return null;
      } on PlatformException {
        return null;
      }
    }

    return null;
  }
}
