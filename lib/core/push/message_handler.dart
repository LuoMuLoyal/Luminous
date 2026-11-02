import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/notifications/local_notification_gateway.dart';
import 'package:luminous/core/push/event_handlers.dart';
import 'package:luminous/core/push/jpush_gateway.dart';

export 'package:luminous/core/push/event_handlers.dart';

/// Maps a remote notification to the existing in-app destination.
String routeForPushEvent(Map<String, dynamic> event) {
  // Keep the action-specific branch explicit so new push actions can add
  // destinations without changing the coordinator or gateway contracts.
  final action = pushActionOf(event);
  switch (action) {
    case PushAction.aiTodaySummary:
      return Routes.home;
    case PushAction.medicineReminder:
    default:
      return Routes.notifications;
  }
}

/// Connects JPush events to the registered [PushEventHandlers] and to the
/// foreground AI-summary stream.
///
/// Core no longer imports `features/notification` or `features/today`; the
/// feature-backed behaviour (unread-count invalidation, today analysis
/// invalidation) is registered by `lib/app/push_handlers.dart`.
class PushMessageHandler {
  PushMessageHandler({
    required this.gateway,
    required this.handlers,
    required this.emitAiSummary,
    required this.navigate,
  });

  final JpushGateway gateway;
  final PushEventHandlers handlers;
  final void Function(Map<String, dynamic> event) emitAiSummary;
  final void Function(String route) navigate;

  StreamSubscription<Map<String, dynamic>>? _receiveSubscription;
  StreamSubscription<Map<String, dynamic>>? _openSubscription;

  void start() {
    if (_receiveSubscription != null) return;
    _receiveSubscription = gateway.receiveEvents.listen(_handleReceiveEvent);
    _openSubscription = gateway.openEvents.listen(handleOpenEvent);
  }

  void _handleReceiveEvent(Map<String, dynamic> event) {
    handlers.onReceive(event);
    if (pushActionOf(event) == PushAction.aiTodaySummary) {
      emitAiSummary(event);
    }
  }

  /// Public entry point used by [PushCoordinator] for cold-start open events.
  void handleOpenEvent(Map<String, dynamic> event) {
    handlers.onOpen(event);
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
    handlers: ref.watch(pushEventHandlersProvider),
    emitAiSummary: (event) => ref.read(aiSummarySinkProvider).add(event),
    navigate: (route) => ref.read(appRouterProvider).go(route),
  );
  handler.start();
  ref.onDispose(handler.dispose);
  return handler;
});

/// Foreground push events with action `ai_today_summary`.
final aiTodaySummaryPushEventsProvider = StreamProvider<Map<String, dynamic>>((
  ref,
) {
  final sink = ref.watch(aiSummarySinkProvider);
  final controller = StreamController<Map<String, dynamic>>.broadcast();
  sink.attach(controller.add);
  ref.onDispose(controller.close);
  return controller.stream;
});

/// Routes local-notification taps through the registered push handlers.
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
    if (action == PushAction.aiTodaySummary) {
      ref.read(pushEventHandlersProvider).onOpen(decoded);
      ref.read(appRouterProvider).go(Routes.home);
    }
  });

  ref.onDispose(subscription.cancel);
});
