import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';

class _FakeJPush extends JPushFlutterInterface {
  EventHandler? receiveHandler;
  EventHandler? openHandler;

  @override
  void addEventHandler({
    EventHandler? onReceiveNotification,
    EventHandler? onOpenNotification,
    EventHandler? onReceiveMessage,
    EventHandler? onReceiveNotificationAuthorization,
    EventHandler? onNotifyMessageUnShow,
    EventHandler? onConnected,
    EventHandler? onInAppMessageClick,
    EventHandler? onInAppMessageShow,
    EventHandler? onNotifyButtonClick,
    EventHandler? onCommandResult,
    EventHandler? onReceiveDeviceToken,
    EventHandler? onVoipMessage,
  }) {
    receiveHandler = onReceiveNotification;
    openHandler = onOpenNotification;
  }
}

void main() {
  group('routeForPushEvent', () {
    test('uses the notifications route by default', () {
      expect(routeForPushEvent(<String, dynamic>{}), Routes.notifications);
    });

    test('keeps medicine reminder messages in notifications', () {
      expect(
        routeForPushEvent(<String, dynamic>{
          'extras': <String, dynamic>{'action': 'medicine_reminder'},
        }),
        Routes.notifications,
      );
    });
  });

  test('invalidates unread count on receive and navigates on open', () async {
    final fake = _FakeJPush();
    final gateway = JpushGateway(
      appKey: 'test-key',
      client: fake,
      platform: TargetPlatform.android,
    );
    var invalidationCount = 0;
    final routes = <String>[];
    final handler = PushMessageHandler(
      gateway: gateway,
      invalidateUnread: () => invalidationCount++,
      navigate: routes.add,
    );

    handler.start();
    await gateway.init();
    await fake.receiveHandler!(<String, dynamic>{'title': 'New'});
    await fake.openHandler!(<String, dynamic>{'title': 'Opened'});

    expect(invalidationCount, 2);
    expect(routes, <String>[Routes.notifications]);
    await handler.dispose();
  });

  test('can restart after dispose', () async {
    final fake = _FakeJPush();
    final gateway = JpushGateway(
      appKey: 'test-key',
      client: fake,
      platform: TargetPlatform.android,
    );
    var invalidationCount = 0;
    final handler = PushMessageHandler(
      gateway: gateway,
      invalidateUnread: () => invalidationCount++,
      navigate: (_) {},
    );

    handler.start();
    await gateway.init();
    await handler.dispose();

    // Restart should not throw and should resume receiving events.
    handler.start();
    await fake.receiveHandler!(<String, dynamic>{'title': 'After restart'});
    expect(invalidationCount, 1);
    await handler.dispose();
  });
}
