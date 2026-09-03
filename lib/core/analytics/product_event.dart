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
///
/// The event name/surface/result/platform enums are the request-scoped enums
/// the current contract inlines into
/// [ProductEventsControllerRecordBatchV1RequestEventsInner] (the previously
/// standalone `ProductEventName` / `ProductEventSurface` /
/// `ProductEventResult` / `UserDevicePlatform` model enums were merged into
/// that type; members and wire values are unchanged).
sealed class ProductEvent {
  const ProductEvent();

  /// Fixed event name from the API contract.
  ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum get name;

  /// Fixed in-app surface for this event kind.
  ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum get surface;

  /// Non-lifecycle events report success/failure semantics; impression and
  /// review_opened always carry `success` (the event itself was recorded).
  ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum get result;

  /// Internal serialization to the API request event type.
  ///
  /// The event's `toJson` emits exactly the allowlisted attribute keys; queue
  /// payloads are built from that JSON so offline replays never carry extra
  /// fields.
  ProductEventsControllerRecordBatchV1RequestEventsInner toDto({
    required String appVersion,
    required ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
    platform,
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
  ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum get name =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum
          .suggestionImpression;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
  get surface =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum.today;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum get result =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum.success;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInner toDto({
    required String appVersion,
    required ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
    platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return ProductEventsControllerRecordBatchV1RequestEventsInner(
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
  ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum get name =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum
          .reviewOpened;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
  get surface =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum.review;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum get result =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum.success;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInner toDto({
    required String appVersion,
    required ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
    platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return ProductEventsControllerRecordBatchV1RequestEventsInner(
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
  final ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum result;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum get name =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum
          .visitSummaryPreviewed;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
  get surface =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum.more;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInner toDto({
    required String appVersion,
    required ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
    platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return ProductEventsControllerRecordBatchV1RequestEventsInner(
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
  final ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum result;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum get name =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum
          .visitSummaryExported;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
  get surface =>
      ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum.more;

  @override
  ProductEventsControllerRecordBatchV1RequestEventsInner toDto({
    required String appVersion,
    required ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
    platform,
    required String occurredAt,
    required String clientEventId,
  }) {
    return ProductEventsControllerRecordBatchV1RequestEventsInner(
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
