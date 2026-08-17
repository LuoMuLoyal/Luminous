import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis.dart';
import 'package:mocktail/mocktail.dart';

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

class _FakeLocalNotificationGateway extends LocalNotificationGateway {
  final _controller = StreamController<NotificationResponse>.broadcast();

  @override
  Stream<NotificationResponse> get tapEvents => _controller.stream;

  @override
  Future<bool> ensureInitialized() async => true;

  void emitTap(NotificationResponse response) => _controller.add(response);
}

class _MockGoRouter extends Mock implements GoRouter {}

class _FakeTodayAiAnalysisNotifier extends TodayAiAnalysisNotifier {
  static int disposeCount = 0;

  @override
  Future<TodayAiAnalysisCardState> build() async {
    ref.onDispose(() => disposeCount++);
    return const TodayAiAnalysisCardState.idle();
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

    test('routes ai_today_summary to home', () {
      expect(
        routeForPushEvent(<String, dynamic>{
          'extras': <String, dynamic>{'action': 'ai_today_summary'},
        }),
        Routes.home,
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
      invalidateTodayAnalysis: () {},
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
      invalidateTodayAnalysis: () {},
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

  group('localNotificationRouterProvider', () {
    setUp(() => _FakeTodayAiAnalysisNotifier.disposeCount = 0);

    test(
      'routes ai_today_summary tap to / and invalidates unread count',
      () async {
        final gateway = _FakeLocalNotificationGateway();
        final router = _MockGoRouter();
        var unreadBuildCount = 0;

        final container = ProviderContainer(
          overrides: [
            localNotificationGatewayProvider.overrideWithValue(gateway),
            appRouterProvider.overrideWithValue(router),
            notificationUnreadCountProvider.overrideWith((ref) async {
              unreadBuildCount++;
              return 0;
            }),
            todayAiAnalysisControllerProvider.overrideWith(
              _FakeTodayAiAnalysisNotifier.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(localNotificationRouterProvider);
        await Future.delayed(Duration.zero);

        // Ensure the AI analysis provider has been built so invalidation triggers
        // its onDispose callback.
        await container.read(todayAiAnalysisControllerProvider.future);

        gateway.emitTap(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            id: 1,
            payload: '{"action":"ai_today_summary"}',
          ),
        );
        await pumpEventQueue();

        verify(() => router.go(Routes.home)).called(1);
        await container.read(notificationUnreadCountProvider.future);
        expect(unreadBuildCount, 1);
        expect(_FakeTodayAiAnalysisNotifier.disposeCount, 1);
      },
    );

    test('ignores local taps without ai_today_summary action', () async {
      final gateway = _FakeLocalNotificationGateway();
      final router = _MockGoRouter();

      final container = ProviderContainer(
        overrides: [
          localNotificationGatewayProvider.overrideWithValue(gateway),
          appRouterProvider.overrideWithValue(router),
          todayAiAnalysisControllerProvider.overrideWith(
            _FakeTodayAiAnalysisNotifier.new,
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(localNotificationRouterProvider);
      await Future.delayed(Duration.zero);

      gateway.emitTap(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 2,
          payload: '{"action":"medicine_reminder"}',
        ),
      );
      await pumpEventQueue();

      verifyNever(() => router.go(any()));
    });
  });
}
