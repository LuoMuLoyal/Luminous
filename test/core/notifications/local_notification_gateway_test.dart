import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';

void main() {
  group('LocalNotificationGateway', () {
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

    test('schedule does not throw with future date', () async {
      final gateway = LocalNotificationGateway();
      await expectLater(
        gateway.schedule(
          id: 1,
          title: 'Test',
          body: 'Body',
          scheduledAt: DateTime.now().add(const Duration(hours: 1)),
          playSound: true,
          channelName: 'Test',
          channelDescription: 'Test channel',
        ),
        completes,
      );
    });

    test('schedule does not throw with past date (early return)', () async {
      final gateway = LocalNotificationGateway();
      await expectLater(
        gateway.schedule(
          id: 2,
          title: 'Past',
          body: 'Past notification',
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
          playSound: false,
          channelName: 'Silent',
          channelDescription: 'Silent channel',
        ),
        completes,
      );
    });

    test('multiple schedule calls do not throw', () async {
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
  });
}
