import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';

/// The process-level bridge around the JPush Flutter plugin.
///
/// JPush is intentionally kept behind this class so the rest of the app does
/// not depend on plugin-specific callback signatures or platform checks.
class JpushGateway {
  JpushGateway({
    required String appKey,
    this.production = false,
    JPushFlutterInterface? client,
    TargetPlatform? platform,
  }) : appKey = appKey.trim(),
       _injectedClient = client,
       _platform = platform ?? defaultTargetPlatform {
    _openController = StreamController<Map<String, dynamic>>.broadcast(
      onListen: _flushPendingOpenEvents,
    );
  }

  final String appKey;
  final bool production;
  final JPushFlutterInterface? _injectedClient;
  final TargetPlatform _platform;

  late final StreamController<Map<String, dynamic>> _openController;
  final StreamController<Map<String, dynamic>> _receiveController =
      StreamController<Map<String, dynamic>>.broadcast();
  final List<Map<String, dynamic>> _pendingOpenEvents =
      <Map<String, dynamic>>[];

  JPushFlutterInterface? _createdClient;
  bool _initialized = false;

  /// The app can safely call the coordinator even when JPush is not configured.
  bool get isConfigured => appKey.isNotEmpty && isMobilePlatform;

  bool get isMobilePlatform =>
      !kIsWeb &&
      (_platform == TargetPlatform.android || _platform == TargetPlatform.iOS);

  Stream<Map<String, dynamic>> get openEvents => _openController.stream;

  Stream<Map<String, dynamic>> get receiveEvents => _receiveController.stream;

  JPushFlutterInterface get _client =>
      _createdClient ??= _injectedClient ?? JPush.newJPush();

  /// Registers callbacks before invoking the plugin's synchronous setup API.
  Future<void> init() async {
    if (_initialized || !isConfigured) return;
    _initialized = true;

    _client.addEventHandler(
      onReceiveNotification: _handleReceiveNotification,
      onOpenNotification: _handleOpenNotification,
    );
    _client.setup(
      appKey: appKey,
      production: production,
      channel: 'developer-default',
      debug: kDebugMode,
    );
  }

  /// Requests iOS push authority without introducing a second permission flow.
  void applyPushAuthority() {
    if (!isConfigured || _platform != TargetPlatform.iOS) return;
    _client.applyPushAuthority();
  }

  Future<void> setAlias(String alias) async {
    final normalizedAlias = alias.trim();
    if (!isConfigured || normalizedAlias.isEmpty) return;
    await _client.setAlias(normalizedAlias);
  }

  Future<void> deleteAlias() async {
    if (!isConfigured) return;
    await _client.deleteAlias();
  }

  Future<Map<String, dynamic>?> getLaunchAppNotification() async {
    if (!isConfigured) return null;
    final notification = await _client.getLaunchAppNotification();
    if (notification.isEmpty) return null;
    return _stringKeyedMap(notification);
  }

  /// Reads JPush's `extras` field from either its native Map or JSON form.
  static Map<String, dynamic> extrasFrom(Map<String, dynamic> event) {
    final rawExtras = event['extras'];
    if (rawExtras is Map) {
      return _stringKeyedMap(rawExtras);
    }
    if (rawExtras is String && rawExtras.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawExtras);
        if (decoded is Map) return _stringKeyedMap(decoded);
      } on FormatException {
        // A malformed optional extras field should not block notification UI.
      }
    }
    return const <String, dynamic>{};
  }

  Future<void> _handleReceiveNotification(Map<String, dynamic> event) async {
    _receiveController.add(_stringKeyedMap(event));
  }

  Future<void> _handleOpenNotification(Map<String, dynamic> event) async {
    _emitOpenEvent(_stringKeyedMap(event));
  }

  void _emitOpenEvent(Map<String, dynamic> event) {
    if (_openController.hasListener) {
      _openController.add(event);
      return;
    }
    _pendingOpenEvents.add(event);
  }

  void _flushPendingOpenEvents() {
    if (_pendingOpenEvents.isEmpty) return;
    final pendingEvents = List<Map<String, dynamic>>.of(_pendingOpenEvents);
    _pendingOpenEvents.clear();
    for (final event in pendingEvents) {
      _openController.add(event);
    }
  }

  static Map<String, dynamic> _stringKeyedMap(Map<dynamic, dynamic> source) =>
      <String, dynamic>{
        for (final entry in source.entries) entry.key.toString(): entry.value,
      };
}

/// JPush has process-level state, so this instance must not be disposed by a
/// short-lived Riverpod provider.
final jpushGatewaySingleton = JpushGateway(
  appKey: const String.fromEnvironment('JPUSH_APP_KEY'),
  production: kReleaseMode,
);
