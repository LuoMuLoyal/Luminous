import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/lifecycle.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

class _FakeJPush extends JPushFlutterInterface {
  final calls = <String>[];
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
  }

  @override
  void setup({
    String appKey = '',
    bool production = false,
    String channel = '',
    bool debug = false,
  }) {
    calls.add('setup');
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
    return <dynamic, dynamic>{};
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

class _FakeNotificationPermissionService extends NotificationPermissionService {
  _FakeNotificationPermissionService(this.state) : super(plugin: null);

  final NotificationPermissionState state;
  int getStateCalls = 0;

  @override
  Future<NotificationPermissionState> getPermissionState() async {
    getStateCalls++;
    return state;
  }
}

void main() {
  JpushGateway buildGateway(_FakeJPush fake, {String appKey = 'test-key'}) {
    return JpushGateway(
      appKey: appKey,
      client: fake,
      platform: TargetPlatform.iOS,
    );
  }

  test('authorized login requests APNs authority and binds alias', () async {
    final fake = _FakeJPush();
    final permission = _FakeNotificationPermissionService(
      NotificationPermissionState.granted,
    );
    final coordinator = PushCoordinator(
      gateway: buildGateway(fake),
      sink: (_) {},
      permissionService: permission,
    );

    await coordinator.onAuthChanged(userId: 'user-123');

    expect(permission.getStateCalls, 1);
    expect(fake.calls, <String>[
      'getLaunchAppNotification',
      'applyPushAuthority',
      'setAlias:user-123',
    ]);
  });

  test('denied login binds alias without requesting APNs authority', () async {
    final fake = _FakeJPush();
    final permission = _FakeNotificationPermissionService(
      NotificationPermissionState.denied,
    );
    final coordinator = PushCoordinator(
      gateway: buildGateway(fake),
      sink: (_) {},
      permissionService: permission,
    );

    await coordinator.onAuthChanged(userId: 'user-123');

    expect(permission.getStateCalls, 1);
    expect(fake.calls, <String>[
      'getLaunchAppNotification',
      'setAlias:user-123',
    ]);
  });

  test('logout clears the current alias', () async {
    final fake = _FakeJPush();
    final coordinator = PushCoordinator(
      gateway: buildGateway(fake),
      sink: (_) {},
      permissionService: _FakeNotificationPermissionService(
        NotificationPermissionState.denied,
      ),
    );

    await coordinator.onAuthChanged(userId: 'user-123');
    await coordinator.onAuthChanged();

    expect(fake.calls, <String>[
      'getLaunchAppNotification',
      'setAlias:user-123',
      'deleteAlias',
    ]);
  });

  test('does nothing when JPush is unavailable', () async {
    final fake = _FakeJPush();
    final permission = _FakeNotificationPermissionService(
      NotificationPermissionState.granted,
    );
    final coordinator = PushCoordinator(
      gateway: buildGateway(fake, appKey: ''),
      sink: (_) {},
      permissionService: permission,
    );

    await coordinator.onAuthChanged(userId: 'user-123');

    expect(permission.getStateCalls, 0);
    expect(fake.calls, isEmpty);
  });

  test(
    'delivers a cold-start event once when start is called repeatedly',
    () async {
      final fake = _FakeJPush()
        ..launchNotification = <dynamic, dynamic>{'title': 'Reminder'};
      final events = <Map<String, dynamic>>[];
      final coordinator = PushCoordinator(
        gateway: buildGateway(fake),
        sink: events.add,
        permissionService: _FakeNotificationPermissionService(
          NotificationPermissionState.denied,
        ),
      );

      await coordinator.start();
      await coordinator.start();

      expect(events, <Map<String, dynamic>>[
        <String, dynamic>{'title': 'Reminder'},
      ]);
      expect(fake.calls, <String>['getLaunchAppNotification']);
    },
  );
}
