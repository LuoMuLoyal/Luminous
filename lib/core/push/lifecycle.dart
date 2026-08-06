import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';

typedef PushEventSink = void Function(Map<String, dynamic> event);

/// Coordinates the JPush process lifecycle with the authenticated user.
class PushCoordinator {
  PushCoordinator({
    required this.gateway,
    required this.sink,
    required this.permissionService,
  });

  final JpushGateway gateway;
  final PushEventSink sink;
  final NotificationPermissionService permissionService;

  Future<void>? _startFuture;
  Future<void> _authChanges = Future<void>.value();
  String? _boundUserId;

  /// Reads the native cold-start event at most once per process.
  Future<void> start() {
    return _startFuture ??= _startOnce();
  }

  /// Serializes auth changes so restore and the root auth listener cannot bind
  /// two aliases concurrently during a cold start.
  Future<void> onAuthChanged({String? userId}) {
    final operation = _authChanges.then<void>((_) => _applyAuthChange(userId));
    _authChanges = operation.catchError((Object _, StackTrace __) {});
    return operation;
  }

  Future<void> _startOnce() async {
    if (!gateway.isConfigured) return;
    final event = await gateway.getLaunchAppNotification();
    if (event != null) sink(event);
  }

  Future<void> _applyAuthChange(String? userId) async {
    await start();
    if (!gateway.isConfigured) return;

    final normalizedUserId = userId?.trim();
    if (normalizedUserId == null || normalizedUserId.isEmpty) {
      await gateway.deleteAlias();
      _boundUserId = null;
      return;
    }

    if (_boundUserId == normalizedUserId) return;
    if (_boundUserId != null) {
      await gateway.deleteAlias();
      _boundUserId = null;
    }

    final permissionState = await permissionService.getPermissionState();
    if (permissionState == NotificationPermissionState.granted) {
      gateway.applyPushAuthority();
    }
    await gateway.setAlias(normalizedUserId);
    _boundUserId = normalizedUserId;
  }
}

final pushCoordinatorProvider = Provider<PushCoordinator>((ref) {
  final messageHandler = ref.watch(pushMessageHandlerProvider);
  return PushCoordinator(
    gateway: ref.watch(jpushGatewayProvider),
    sink: messageHandler.handleOpenEvent,
    permissionService: ref.watch(notificationPermissionServiceProvider),
  );
});
