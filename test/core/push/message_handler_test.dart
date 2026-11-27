import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:luminous/app/composition/notification/unread_count.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';
import 'package:luminous/features/today/presentation/providers/briefing.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/kv_test_store.dart';

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

/// Counts handler callbacks without pulling feature providers into core tests.
/// Mirrors lib/app/push_handlers.dart's invalidation behaviour.
class _AppLikePushHandlers implements PushEventHandlers {
  _AppLikePushHandlers({this.onOpenEvent});

  final void Function()? onOpenEvent;

  @override
  void onReceive(Map<String, dynamic> event) {}

  @override
  void onOpen(Map<String, dynamic> event) => onOpenEvent?.call();
}

class _CountingPushHandlers implements PushEventHandlers {
  _CountingPushHandlers({this.onEvent});

  final void Function()? onEvent;

  @override
  void onReceive(Map<String, dynamic> event) => onEvent?.call();

  @override
  void onOpen(Map<String, dynamic> event) => onEvent?.call();
}

class _FakeTodayBriefingNotifier extends TodayBriefingNotifier {
  static int disposeCount = 0;

  @override
  Future<TodayBriefingCardState> build() async {
    ref.onDispose(() => disposeCount++);
    return const TodayBriefingCardState.idle();
  }
}

void main() {
  setUp(() {
    KvTestStore.install();
  });

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
      handlers: _CountingPushHandlers(onEvent: () => invalidationCount++),
      emitAiSummary: (_) {},
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
      handlers: _CountingPushHandlers(onEvent: () => invalidationCount++),
      emitAiSummary: (_) {},
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

  group('localNotificationRouterProvider', () {
    setUp(() => _FakeTodayBriefingNotifier.disposeCount = 0);

    test(
      'routes ai_today_summary tap to / and invalidates unread count',
      () async {
        final gateway = _FakeLocalNotificationGateway();
        final router = _MockGoRouter();
        var unreadBuildCount = 0;

        late final ProviderContainer container;
        container = ProviderContainer(
          overrides: [
            localNotificationGatewayProvider.overrideWithValue(gateway),
            pushNavigateProvider.overrideWithValue(router.go),
            pushEventHandlersProvider.overrideWithValue(
              _AppLikePushHandlers(
                onOpenEvent: () {
                  container.invalidate(notificationUnreadCountProvider);
                  container.invalidate(todayBriefingAnalysisControllerProvider);
                },
              ),
            ),
            notificationUnreadCountProvider.overrideWith((ref) async {
              unreadBuildCount++;
              return 0;
            }),
            todayBriefingAnalysisControllerProvider.overrideWith(
              _FakeTodayBriefingNotifier.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(localNotificationRouterProvider);
        await Future.delayed(Duration.zero);

        // Ensure the AI analysis provider has been built so invalidation triggers
        // its onDispose callback.
        await container.read(todayBriefingAnalysisControllerProvider.future);

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
        expect(_FakeTodayBriefingNotifier.disposeCount, 1);
      },
    );

    test('ignores local taps without ai_today_summary action', () async {
      final gateway = _FakeLocalNotificationGateway();
      final router = _MockGoRouter();

      final container = ProviderContainer(
        overrides: [
          localNotificationGatewayProvider.overrideWithValue(gateway),
          pushNavigateProvider.overrideWithValue(router.go),
          todayBriefingAnalysisControllerProvider.overrideWith(
            _FakeTodayBriefingNotifier.new,
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
