import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';

/// Maps a remote notification to the existing in-app destination.
String routeForPushEvent(Map<String, dynamic> event) {
  // Keep the action-specific branch explicit so new push actions can add
  // destinations without changing the coordinator or gateway contracts.
  final action = JpushGateway.extrasFrom(event)['action'];
  switch (action) {
    case 'medicine_reminder':
    default:
      return Routes.notifications;
  }
}

/// Connects JPush events to notification cache invalidation and navigation.
class PushMessageHandler {
  PushMessageHandler({
    required this.gateway,
    required this.invalidateUnread,
    required this.navigate,
  });

  final JpushGateway gateway;
  final void Function() invalidateUnread;
  final void Function(String route) navigate;

  StreamSubscription<Map<String, dynamic>>? _receiveSubscription;
  StreamSubscription<Map<String, dynamic>>? _openSubscription;

  void start() {
    if (_receiveSubscription != null) return;
    _receiveSubscription = gateway.receiveEvents.listen((_) {
      invalidateUnread();
    });
    _openSubscription = gateway.openEvents.listen((event) {
      handleOpenEvent(event);
    });
  }

  void handleOpenEvent(Map<String, dynamic> event) {
    invalidateUnread();
    navigate(routeForPushEvent(event));
  }

  Future<void> dispose() async {
    await _receiveSubscription?.cancel();
    await _openSubscription?.cancel();
    _receiveSubscription = null;
    _openSubscription = null;
  }
}

final jpushGatewayProvider = Provider<JpushGateway>((ref) {
  return jpushGatewaySingleton;
});

/// The root widget watches this provider to keep event subscriptions alive.
final pushMessageHandlerProvider = Provider<PushMessageHandler>((ref) {
  final handler = PushMessageHandler(
    gateway: ref.watch(jpushGatewayProvider),
    invalidateUnread: () => ref.invalidate(notificationUnreadCountProvider),
    navigate: (route) => ref.read(appRouterProvider).go(route),
  );
  handler.start();
  ref.onDispose(handler.dispose);
  return handler;
});
