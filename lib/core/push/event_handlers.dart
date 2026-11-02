import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/push/jpush_gateway.dart';

/// Push actions this app knows about.
///
/// Declared in core so `core/push` can branch on an action without importing
/// the feature that owns the behaviour.
abstract final class PushAction {
  static const String aiTodaySummary = 'ai_today_summary';
  static const String medicineReminder = 'medicine_reminder';
}

/// Feature-agnostic reactions to push events.
///
/// `lib/core/push` used to import `features/notification` and `features/today`
/// directly, which violates `core_not_import_features`. The composition root
/// (`lib/app/push_handlers.dart`) registers the feature-backed implementation
/// and core only fires the callbacks.
abstract interface class PushEventHandlers {
  /// A push arrived while the app was in the foreground.
  void onReceive(Map<String, dynamic> event);

  /// The user opened a push / local notification.
  void onOpen(Map<String, dynamic> event);
}

/// No-op default: push payloads are ignored while nothing is registered.
class NoopPushEventHandlers implements PushEventHandlers {
  const NoopPushEventHandlers();

  @override
  void onReceive(Map<String, dynamic> event) {}

  @override
  void onOpen(Map<String, dynamic> event) {}
}

/// Composition-root seam: overridden in `ProviderScope` by the app adapter.
final pushEventHandlersProvider = Provider<PushEventHandlers>(
  (ref) => const NoopPushEventHandlers(),
);

/// Fan-out point between the JPush listener and
/// [aiTodaySummaryPushEventsProvider].
class AiSummaryEventSink {
  void Function(Map<String, dynamic>)? _emit;

  void attach(void Function(Map<String, dynamic>) emit) {
    _emit = emit;
  }

  void add(Map<String, dynamic> event) => _emit?.call(event);
}

final aiSummarySinkProvider = Provider<AiSummaryEventSink>(
  (ref) => AiSummaryEventSink(),
);

/// Reads the `action` extra out of a raw push payload.
String? pushActionOf(Map<String, dynamic> event) =>
    JpushGateway.extrasFrom(event)['action'] as String?;
