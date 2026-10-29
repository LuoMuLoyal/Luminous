import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/push/jpush_gateway.dart';
import 'package:luminous/core/push/message_handler.dart';

typedef PushEventSink = void Function(Map<String, dynamic> event);

/// Whether the OS allows this app to post notifications.
///
/// Mirrored from the feature-owned enum so `core/push` can gate push authority
/// without importing `features/settings` (`core_not_import_features`). The
/// adapter in `lib/app/push_handlers.dart` maps the feature value onto it.
enum PushPermissionStatus { granted, denied, permanentlyDenied, unsupported }

/// Minimal notification-permission probe used by [PushCoordinator].
abstract interface class PushPermissionProbe {
  Future<PushPermissionStatus> readStatus();
}

/// Reports "denied" until the composition root registers a real probe.
class NoopPushPermissionProbe implements PushPermissionProbe {
  const NoopPushPermissionProbe();

  @override
  Future<PushPermissionStatus> readStatus() async =>
      PushPermissionStatus.denied;
}

/// Composition-root seam: overridden by `lib/app/push_handlers.dart`.
final pushPermissionProbeProvider = Provider<PushPermissionProbe>(
  (ref) => const NoopPushPermissionProbe(),
);

/// Coordinates the JPush process lifecycle with the authenticated user.
class PushCoordinator {
  PushCoordinator({
    required this.gateway,
    required this.sink,
    required this.permissionProbe,
  });

  final JpushGateway gateway;
  final PushEventSink sink;
  final PushPermissionProbe permissionProbe;

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
    _authChanges = operation.catchError((Object error, StackTrace stack) {
      appTalker.error('PushCoordinator: auth change chain error', error, stack);
    });
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

    final permissionState = await permissionProbe.readStatus();
    if (permissionState == PushPermissionStatus.granted) {
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
    permissionProbe: ref.watch(pushPermissionProbeProvider),
  );
});
