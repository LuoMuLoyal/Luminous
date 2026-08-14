import 'package:lucent_api/lucent_api.dart';

/// Server allowlisted suggestion rule codes the client may report.
///
/// Mirrors the server-side suggestion rule registry (Lucent). The server
/// rejects unknown `suggestionRuleCode` values with 400, so impressions for
/// codes outside this set are dropped client-side instead of being queued
/// for doomed retries.
const Set<String> kAllowlistedSuggestionRuleCodes = {
  'water_behind_target',
  'sleep_shortfall',
  'caffeine_sleep_correlation',
  'mood_sleep_correlation',
  'missed_dose_pending',
  'coverage_explanation',
  'deteriorating_symptom',
};

/// Closed union of client-reported product events.
///
/// Each variant carries only typed, privacy-minimal properties — there is no
/// `Map<String, dynamic>` public entry point, no free-text field and no
/// metadata slot, so the union structurally cannot express forbidden payloads
/// (symptom/title/note/medicineName text, record values, PDF URL, share
/// token, device ad id).
///
/// Server-authoritative events (health_event_*, suggestion_actioned,
/// visit_summary_share_*) are deliberately NOT representable here — the
/// server emits those after successful transactions.
sealed class ProductEvent {
  const ProductEvent();

  /// Fixed event name from the API contract.
  ProductEventName get name;

  /// Fixed in-app surface for this event kind.
  ProductEventSurface get surface;

  /// Non-lifecycle events report success/failure semantics; impression and
  /// review_opened always carry `success` (the event itself was recorded).
  ProductEventResult get result;

  /// Internal serialization to the API DTO.
  ///
  /// The DTO's `toJson` emits exactly the allowlisted attribute keys; queue
  /// payloads are built from that JSON so offline replays never carry extra
  /// fields.
  CreateProductEventDto toDto({
    required String appVersion,
    required UserDevicePlatform platform,
    required String occurredAt,
    required String clientEventId,
  });
}

/// The primary suggestion card entered the visible area of the Today page.
final class SuggestionImpressionEvent extends ProductEvent {
  const SuggestionImpressionEvent({required this.suggestionRuleCode});

  /// Server-side rule code (allowlisted, see [kAllowlistedSuggestionRuleCodes]).
  final String suggestionRuleCode;

  @override
  ProductEventName get name => ProductEventName.suggestionImpression;

  @override
  ProductEventSurface get surface => ProductEventSurface.today;

  @override
  ProductEventResult get result => ProductEventResult.success;

  @override
  CreateProductEventDto toDto({
    required String appVersion,
    required UserDevicePlatform platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return CreateProductEventDto(
      name: name,
      surface: surface,
      result: result,
      suggestionRuleCode: suggestionRuleCode,
      appVersion: appVersion,
      platform: platform,
      occurredAt: occurredAt,
      clientEventId: clientEventId,
    );
  }
}

/// The review page actually presented review data (or the confirmed
/// no-event state) to the user.
final class ReviewOpenedEvent extends ProductEvent {
  const ReviewOpenedEvent();

  @override
  ProductEventName get name => ProductEventName.reviewOpened;

  @override
  ProductEventSurface get surface => ProductEventSurface.review;

  @override
  ProductEventResult get result => ProductEventResult.success;

  @override
  CreateProductEventDto toDto({
    required String appVersion,
    required UserDevicePlatform platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return CreateProductEventDto(
      name: name,
      surface: surface,
      result: result,
      appVersion: appVersion,
      platform: platform,
      occurredAt: occurredAt,
      clientEventId: clientEventId,
    );
  }
}

/// A visit summary preview was fetched (or failed) from the server.
final class VisitSummaryPreviewedEvent extends ProductEvent {
  const VisitSummaryPreviewedEvent({required this.result});

  /// `success` after a successful server preview response, `failure` after
  /// any error — a failed preview never counts as previewed.
  @override
  final ProductEventResult result;

  @override
  ProductEventName get name => ProductEventName.visitSummaryPreviewed;

  @override
  ProductEventSurface get surface => ProductEventSurface.more;

  @override
  CreateProductEventDto toDto({
    required String appVersion,
    required UserDevicePlatform platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return CreateProductEventDto(
      name: name,
      surface: surface,
      result: result,
      appVersion: appVersion,
      platform: platform,
      occurredAt: occurredAt,
      clientEventId: clientEventId,
    );
  }
}

/// A visit summary export (clinic-summary PDF download, or the monthly/print
/// export request from the report More sheet / legacy export cards) completed.
final class VisitSummaryExportedEvent extends ProductEvent {
  const VisitSummaryExportedEvent({required this.result});

  /// `success` only after a successful server response — failures are
  /// recorded with `failure` and never count as exported.
  @override
  final ProductEventResult result;

  @override
  ProductEventName get name => ProductEventName.visitSummaryExported;

  @override
  ProductEventSurface get surface => ProductEventSurface.more;

  @override
  CreateProductEventDto toDto({
    required String appVersion,
    required UserDevicePlatform platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return CreateProductEventDto(
      name: name,
      surface: surface,
      result: result,
      appVersion: appVersion,
      platform: platform,
      occurredAt: occurredAt,
      clientEventId: clientEventId,
    );
  }
}
