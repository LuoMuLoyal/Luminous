import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:luminous/core/push/jpush_gateway.dart';

class _FakeJPush extends JPushFlutterInterface {
  final calls = <String>[];
  EventHandler? receiveHandler;
  EventHandler? openHandler;
  Map<dynamic, dynamic> launchNotification = <dynamic, dynamic>{};

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
    calls.add('addEventHandler');
    receiveHandler = onReceiveNotification;
    openHandler = onOpenNotification;
  }

  @override
  void setup({
    String appKey = '',
    bool production = false,
    String channel = '',
    bool debug = false,
  }) {
    calls.add('setup:$appKey:$production:$channel:$debug');
  }

  @override
  void applyPushAuthority([
    NotificationSettingsIOS iosSettings = const NotificationSettingsIOS(),
  ]) {
    calls.add('applyPushAuthority');
  }

  @override
  Future<Map<dynamic, dynamic>> setAlias(String alias) async {
    calls.add('setAlias:$alias');
    return <dynamic, dynamic>{'alias': alias};
  }

  @override
  Future<Map<dynamic, dynamic>> deleteAlias() async {
    calls.add('deleteAlias');
    return <dynamic, dynamic>{};
  }

  @override
  Future<Map<dynamic, dynamic>> getLaunchAppNotification() async {
    calls.add('getLaunchAppNotification');
    return launchNotification;
  }
}

void main() {
  group('JpushGateway', () {
    late _FakeJPush fake;

    setUp(() {
      fake = _FakeJPush();
    });

    test('silently disables on non-mobile platforms', () async {
      final gateway = JpushGateway(
        appKey: 'test-key',
        client: fake,
        platform: TargetPlatform.windows,
      );

      await gateway.init();

      expect(gateway.isConfigured, isFalse);
      expect(fake.calls, isEmpty);
    });

    test('silently disables when AppKey is empty', () async {
      final gateway = JpushGateway(
        appKey: '',
        client: fake,
        platform: TargetPlatform.android,
      );

      await gateway.init();

      expect(gateway.isConfigured, isFalse);
      expect(fake.calls, isEmpty);
    });

    test('registers async handlers before synchronous setup', () async {
      final gateway = JpushGateway(
        appKey: 'test-key',
        production: true,
        client: fake,
        platform: TargetPlatform.android,
      );

      await gateway.init();

      expect(fake.calls, <String>[
        'addEventHandler',
        'setup:test-key:true:developer-default:true',
      ]);
      expect(gateway.isConfigured, isTrue);
    });

    test('only configured gateways bind and clear aliases', () async {
      final gateway = JpushGateway(
        appKey: 'test-key',
        client: fake,
        platform: TargetPlatform.iOS,
      );

      await gateway.setAlias('user-123');
      await gateway.deleteAlias();

      expect(fake.calls, <String>['setAlias:user-123', 'deleteAlias']);
    });

    test('requests APNs authority only on configured iOS gateways', () async {
      final gateway = JpushGateway(
        appKey: 'test-key',
        client: fake,
        platform: TargetPlatform.iOS,
      );

      gateway.applyPushAuthority();

      expect(fake.calls, <String>['applyPushAuthority']);
    });

    test('returns null for an empty cold-start notification', () async {
      final gateway = JpushGateway(
        appKey: 'test-key',
        client: fake,
        platform: TargetPlatform.iOS,
      );

      expect(await gateway.getLaunchAppNotification(), isNull);
      expect(fake.calls, <String>['getLaunchAppNotification']);
    });

    test('normalizes extras from a Map or JSON string', () {
      expect(
        JpushGateway.extrasFrom(<String, dynamic>{
          'extras': <dynamic, dynamic>{'action': 'medicine_reminder'},
        }),
        <String, dynamic>{'action': 'medicine_reminder'},
      );
      expect(
        JpushGateway.extrasFrom(<String, dynamic>{
          'extras': '{"action":"medicine_reminder"}',
        }),
        <String, dynamic>{'action': 'medicine_reminder'},
      );
    });

    test(
      'keeps an open event until the first subscriber is attached',
      () async {
        final gateway = JpushGateway(
          appKey: 'test-key',
          client: fake,
          platform: TargetPlatform.android,
        );
        await gateway.init();

        final event = <String, dynamic>{'title': 'Reminder'};
        await fake.openHandler!(event);

        expect(await gateway.openEvents.first, event);
      },
    );
  });
}
