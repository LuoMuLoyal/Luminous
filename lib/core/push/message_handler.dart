import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis.dart';

/// Maps a remote notification to the existing in-app destination.
String routeForPushEvent(Map<String, dynamic> event) {
  // Keep the action-specific branch explicit so new push actions can add
  // destinations without changing the coordinator or gateway contracts.
  final action = JpushGateway.extrasFrom(event)['action'];
  switch (action) {
    case 'ai_today_summary':
      return Routes.home;
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
    required this.invalidateTodayAnalysis,
  });

  final JpushGateway gateway;
  final void Function() invalidateUnread;
  final void Function(String route) navigate;
  final void Function() invalidateTodayAnalysis;

  StreamSubscription<Map<String, dynamic>>? _receiveSubscription;
  StreamSubscription<Map<String, dynamic>>? _openSubscription;

  final StreamController<Map<String, dynamic>>
  _foregroundAiTodaySummaryController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Foreground push events with action `ai_today_summary`, suitable for
  /// showing an in-app toast/banner.
  Stream<Map<String, dynamic>> get foregroundAiTodaySummaryEvents =>
      _foregroundAiTodaySummaryController.stream;

  void start() {
    if (_receiveSubscription != null) return;
    _receiveSubscription = gateway.receiveEvents.listen((event) {
      invalidateUnread();
      _handleReceiveEvent(event);
    });
    _openSubscription = gateway.openEvents.listen((event) {
      invalidateUnread();
      navigate(routeForPushEvent(event));
    });
  }

  void _handleReceiveEvent(Map<String, dynamic> event) {
    final action = JpushGateway.extrasFrom(event)['action'];
    if (action == 'ai_today_summary') {
      invalidateTodayAnalysis();
      _foregroundAiTodaySummaryController.add(event);
    }
  }

  /// Public entry point used by [PushCoordinator] for cold-start open events.
  void handleOpenEvent(Map<String, dynamic> event) {
    invalidateUnread();
    navigate(routeForPushEvent(event));
  }

  Future<void> dispose() async {
    await _receiveSubscription?.cancel();
    await _openSubscription?.cancel();
    _receiveSubscription = null;
    _openSubscription = null;
    await _foregroundAiTodaySummaryController.close();
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
    invalidateTodayAnalysis: () =>
        ref.invalidate(todayAiAnalysisControllerProvider),
  );
  handler.start();
  ref.onDispose(handler.dispose);
  return handler;
});

/// Foreground push events with action `ai_today_summary`.
final aiTodaySummaryPushEventsProvider = StreamProvider<Map<String, dynamic>>(
  (ref) => ref.watch(pushMessageHandlerProvider).foregroundAiTodaySummaryEvents,
);

final localNotificationRouterProvider = Provider<void>((ref) {
  final gateway = ref.watch(localNotificationGatewayProvider);
  final subscription = gateway.tapEvents.listen((response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;

    final action = decoded['action'];
    if (action == 'ai_today_summary') {
      ref.invalidate(notificationUnreadCountProvider);
      ref.invalidate(todayAiAnalysisControllerProvider);
      ref.read(appRouterProvider).go(Routes.home);
    }
  });

  ref.onDispose(subscription.cancel);
});
