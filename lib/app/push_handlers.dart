import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:luminous/core/push/event_handlers.dart';
import 'package:luminous/core/push/lifecycle.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/settings/data/providers/notification_permission.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:luminous/features/today/presentation/providers/ai_analysis.dart';

/// Feature-backed [PushEventHandlers] registered by the composition root.
///
/// `lib/core/push` is feature-free: it only knows the callback contract. The
/// unread-count / today-analysis invalidation lives here, where importing
/// features is allowed.
class FeaturePushEventHandlers implements PushEventHandlers {
  const FeaturePushEventHandlers({
    required this.invalidateUnread,
    required this.invalidateTodayAnalysis,
    required this.handleAiSummaryOpen,
  });

  final void Function() invalidateUnread;
  final void Function() invalidateTodayAnalysis;

  /// Extra reaction when an AI-summary notification is opened.
  final void Function(Map<String, dynamic> event) handleAiSummaryOpen;

  @override
  void onReceive(Map<String, dynamic> event) {
    invalidateUnread();
    if (pushActionOf(event) == PushAction.aiTodaySummary) {
      invalidateTodayAnalysis();
    }
  }

  @override
  void onOpen(Map<String, dynamic> event) {
    invalidateUnread();
    if (pushActionOf(event) == PushAction.aiTodaySummary) {
      invalidateTodayAnalysis();
      handleAiSummaryOpen(event);
    }
  }
}

final pushEventHandlersProviderForApp = Provider<PushEventHandlers>((ref) {
  return FeaturePushEventHandlers(
    invalidateUnread: () => ref.invalidate(notificationUnreadCountProvider),
    invalidateTodayAnalysis: () =>
        ref.invalidate(todayAiAnalysisControllerProvider),
    // Navigation is handled by core's PushMessageHandler; nothing extra needed.
    handleAiSummaryOpen: (_) {},
  );
});

/// Adapts the feature-owned notification-permission service to the core
/// [PushPermissionProbe] contract.
class FeaturePushPermissionProbe implements PushPermissionProbe {
  const FeaturePushPermissionProbe(this._service);

  final NotificationPermissionService _service;

  @override
  Future<PushPermissionStatus> readStatus() async {
    final state = await _service.getPermissionState();
    return switch (state) {
      NotificationPermissionState.granted => PushPermissionStatus.granted,
      NotificationPermissionState.denied => PushPermissionStatus.denied,
      NotificationPermissionState.permanentlyDenied =>
        PushPermissionStatus.permanentlyDenied,
      NotificationPermissionState.unsupported =>
        PushPermissionStatus.unsupported,
    };
  }
}

final pushPermissionProbeProviderForApp = Provider<PushPermissionProbe>((ref) {
  return FeaturePushPermissionProbe(
    ref.watch(notificationPermissionServiceProvider),
  );
});

/// Extra overrides for the root [ProviderScope] that involve push wiring.
List<Override> pushProviderOverrides(ProviderContainer container) => [
  pushEventHandlersProvider.overrideWithValue(
    FeaturePushEventHandlers(
      invalidateUnread: () =>
          container.invalidate(notificationUnreadCountProvider),
      invalidateTodayAnalysis: () =>
          container.invalidate(todayAiAnalysisControllerProvider),
      handleAiSummaryOpen: (_) {},
    ),
  ),
  pushPermissionProbeProvider.overrideWithValue(
    FeaturePushPermissionProbe(
      container.read(notificationPermissionServiceProvider),
    ),
  ),
];
