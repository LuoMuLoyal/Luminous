import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  // Method-channel calls (e.g. canScheduleExactNotifications on the real
  // AndroidFlutterLocalNotificationsPlugin instance the fake returns) need a
  // test binding, even in plain `test()` bodies.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationGateway (non-mobile platform)', () {
    setUp(() {
      // Override to non-mobile so _supportsLocalScheduling returns false
      // and ensureInitialized returns early without touching the plugin.
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('ensureInitialized returns false on non-mobile platform', () async {
      final gateway = LocalNotificationGateway();
      final available = await gateway.ensureInitialized();
      expect(available, isFalse);
    });

    test('cancel does not throw when not initialized', () async {
      final gateway = LocalNotificationGateway();
      await expectLater(gateway.cancel(1), completes);
    });

    test('schedule returns false when the platform is unsupported', () async {
      final gateway = LocalNotificationGateway();
      final scheduled = await gateway.schedule(
        id: 1,
        title: 'Test',
        body: 'Body',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        playSound: true,
        channelName: 'Test',
        channelDescription: 'Test channel',
      );
      expect(scheduled, isFalse);
    });

    test('schedule returns false for past dates', () async {
      final gateway = LocalNotificationGateway();
      final scheduled = await gateway.schedule(
        id: 2,
        title: 'Past',
        body: 'Past notification',
        scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        playSound: false,
        channelName: 'Silent',
        channelDescription: 'Silent channel',
      );
      expect(scheduled, isFalse);
    });

    test('multiple schedule calls return false without throwing', () async {
      final gateway = LocalNotificationGateway();
      await gateway.schedule(
        id: 3,
        title: 'Sound on',
        body: 'With sound',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        playSound: true,
        channelName: 'Sound',
        channelDescription: 'Sound channel',
      );
      await gateway.schedule(
        id: 4,
        title: 'Silent',
        body: 'No sound',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        playSound: false,
        channelName: 'Silent',
        channelDescription: 'Silent channel',
      );
      // No exception means success
    });

    test('ensureInitialized is idempotent', () async {
      final gateway = LocalNotificationGateway();
      final first = await gateway.ensureInitialized();
      final second = await gateway.ensureInitialized();
      expect(first, equals(second));
    });

    test(
      'getActiveNotifications returns empty on unsupported platform',
      () async {
        final gateway = LocalNotificationGateway();
        expect(await gateway.getActiveNotifications(), isEmpty);
      },
    );
  });

  group('LocalNotificationGateway (fake android plugin)', () {
    late _FakeAndroidPlugin plugin;
    late LocalNotificationGateway gateway;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      plugin = _FakeAndroidPlugin();
      FlutterLocalNotificationsPlatform.instance = plugin;
      gateway = LocalNotificationGateway();
    });

    tearDown(() {
      FlutterLocalNotificationsPlatform.instance =
          AndroidFlutterLocalNotificationsPlugin();
      debugDefaultTargetPlatformOverride = null;
    });

    test('ensureInitialized succeeds with a platform binding', () async {
      expect(await gateway.ensureInitialized(), isTrue);
      expect(plugin.tapCallback, isNotNull);
    });

    test(
      'schedule returns true when the plugin accepts the schedule',
      () async {
        final scheduled = await gateway.schedule(
          id: 11,
          title: 'OK',
          body: 'Scheduled',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          playSound: true,
          channelName: 'Channel',
          channelDescription: 'Channel description',
        );
        expect(scheduled, isTrue);
        expect(plugin.scheduledIds, <int>[11]);
      },
    );

    test(
      'schedule returns false when the plugin throws a platform error',
      () async {
        plugin.scheduleError = PlatformException(code: 'schedule_failed');
        final scheduled = await gateway.schedule(
          id: 12,
          title: 'Fail',
          body: 'Scheduled',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          playSound: true,
          channelName: 'Channel',
          channelDescription: 'Channel description',
        );
        expect(scheduled, isFalse);
      },
    );

    test('schedule returns false when the plugin is missing', () async {
      plugin.scheduleError = MissingPluginException();
      final scheduled = await gateway.schedule(
        id: 13,
        title: 'Missing',
        body: 'Scheduled',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        playSound: true,
        channelName: 'Channel',
        channelDescription: 'Channel description',
      );
      expect(scheduled, isFalse);
    });

    test('tap events are emitted to the tapEvents stream', () async {
      final events = <NotificationResponse>[];
      final sub = gateway.tapEvents.listen(events.add);
      addTearDown(sub.cancel);

      await gateway.ensureInitialized();
      plugin.tapCallback!(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 42,
          payload: '{"reminderId":"r1","date":"2026-06-10","time":"21:30"}',
        ),
      );
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.payload, contains('r1'));
    });

    test(
      'tap events arriving before a listener are replayed on first listen',
      () async {
        await gateway.ensureInitialized();
        plugin.tapCallback!(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            id: 7,
            payload: 'early',
          ),
        );

        final events = <NotificationResponse>[];
        final sub = gateway.tapEvents.listen(events.add);
        addTearDown(sub.cancel);
        await pumpEventQueue();

        expect(events, hasLength(1));
        expect(events.single.id, 7);
      },
    );

    test('launch details response is replayed to the first listener', () async {
      plugin.launchDetails = const NotificationAppLaunchDetails(
        true,
        notificationResponse: NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 99,
          payload: 'launch-payload',
        ),
      );

      await gateway.ensureInitialized();

      final events = <NotificationResponse>[];
      final sub = gateway.tapEvents.listen(events.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.single.id, 99);
      expect(events.single.payload, 'launch-payload');
    });

    test('launch details without a launch response emit nothing', () async {
      plugin.launchDetails = const NotificationAppLaunchDetails(false);

      await gateway.ensureInitialized();

      final events = <NotificationResponse>[];
      final sub = gateway.tapEvents.listen(events.add);
      addTearDown(sub.cancel);
      await pumpEventQueue();

      expect(events, isEmpty);
    });

    test('concurrent ensureInitialized calls share one result', () async {
      // Gate the plugin's initialize so both callers await the same
      // in-flight initialization instead of racing on a stale _available.
      final gated = _GatedAndroidPlugin();
      FlutterLocalNotificationsPlatform.instance = gated;
      final gatedGateway = LocalNotificationGateway();

      final first = gatedGateway.ensureInitialized();
      final second = gatedGateway.ensureInitialized();
      gated.complete(true);

      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(gated.initializeCalls, 1);
    });

    test('getActiveNotifications returns the plugin list', () async {
      plugin.active = <ActiveNotification>[
        const ActiveNotification(id: 1, payload: 'p1'),
        const ActiveNotification(id: 2, payload: 'p2'),
      ];
      final active = await gateway.getActiveNotifications();
      expect(active.map((item) => item.id).toList(), <int?>[1, 2]);
    });

    test(
      'getActiveNotifications returns empty when the plugin fails',
      () async {
        plugin.activeError = MissingPluginException();
        expect(await gateway.getActiveNotifications(), isEmpty);
      },
    );
  });
}

class _FakeAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  DidReceiveNotificationResponseCallback? tapCallback;
  final scheduledIds = <int>[];
  Object? scheduleError;
  NotificationAppLaunchDetails? launchDetails;
  List<ActiveNotification> active = const <ActiveNotification>[];
  Object? activeError;

  @override
  Future<bool> initialize(
    AndroidInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    tapCallback = onDidReceiveNotificationResponse;
    return true;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    AndroidNotificationDetails? notificationDetails, {
    required AndroidScheduleMode scheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final error = scheduleError;
    if (error != null) {
      throw error;
    }
    scheduledIds.add(id);
  }

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => launchDetails;

  @override
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final error = activeError;
    if (error != null) {
      throw error;
    }
    return active;
  }
}

class _GatedAndroidPlugin extends AndroidFlutterLocalNotificationsPlugin {
  final _completer = Completer<bool>();
  int initializeCalls = 0;

  @override
  Future<bool> initialize(
    AndroidInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) {
    initializeCalls += 1;
    return _completer.future;
  }

  @override
  Future<bool?> canScheduleExactNotifications() async => true;

  void complete(bool value) => _completer.complete(value);
}
