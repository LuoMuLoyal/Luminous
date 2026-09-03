//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_events_controller_record_batch_v1_request_events_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductEventsControllerRecordBatchV1RequestEventsInner {
  /// Returns a new [ProductEventsControllerRecordBatchV1RequestEventsInner] instance.
  ProductEventsControllerRecordBatchV1RequestEventsInner({
    required this.name,

    required this.surface,

    required this.result,

    this.eventStatus,

    this.suggestionRuleCode,

    required this.appVersion,

    required this.platform,

    required this.occurredAt,

    required this.clientEventId,
  });

  /// Fixed product event name — enums only, no free text.
  @JsonKey(
    name: r'name',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum
            .unknownDefaultOpenApi,
  )
  final ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum name;

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonKey(
    name: r'surface',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
            .unknownDefaultOpenApi,
  )
  final ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum
  surface;

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonKey(
    name: r'result',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum
            .unknownDefaultOpenApi,
  )
  final ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum result;

  /// Lifecycle status — only health_event_started (active) / health_event_ended (ended) report it; other events omit it.
  @JsonKey(
    name: r'eventStatus',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        ProductEventsControllerRecordBatchV1RequestEventsInnerEventStatusEnum
            .unknownDefaultOpenApi,
  )
  final ProductEventsControllerRecordBatchV1RequestEventsInnerEventStatusEnum?
  eventStatus;

  /// Known server-side suggestion rule code (allowlisted, no free strings); unknown codes are rejected with 400.
  @JsonKey(name: r'suggestionRuleCode', required: false, includeIfNull: false)
  final String? suggestionRuleCode;

  /// Client app version, e.g. 1.2.0.
  @JsonKey(name: r'appVersion', required: true, includeIfNull: false)
  final String appVersion;

  /// Client platform.
  @JsonKey(
    name: r'platform',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
            .unknownDefaultOpenApi,
  )
  final ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum
  platform;

  /// Event time (ISO 8601). Retention scans this field (90 days).
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Client-generated id enabling retry idempotency — unique per user, so retried batches never double-insert.
  @JsonKey(name: r'clientEventId', required: true, includeIfNull: false)
  final String clientEventId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEventsControllerRecordBatchV1RequestEventsInner &&
          other.name == name &&
          other.surface == surface &&
          other.result == result &&
          other.eventStatus == eventStatus &&
          other.suggestionRuleCode == suggestionRuleCode &&
          other.appVersion == appVersion &&
          other.platform == platform &&
          other.occurredAt == occurredAt &&
          other.clientEventId == clientEventId;

  @override
  int get hashCode =>
      name.hashCode +
      surface.hashCode +
      result.hashCode +
      eventStatus.hashCode +
      suggestionRuleCode.hashCode +
      appVersion.hashCode +
      platform.hashCode +
      occurredAt.hashCode +
      clientEventId.hashCode;

  factory ProductEventsControllerRecordBatchV1RequestEventsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$ProductEventsControllerRecordBatchV1RequestEventsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductEventsControllerRecordBatchV1RequestEventsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Fixed product event name — enums only, no free text.
enum ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum {
  @JsonValue(r'health_event_started')
  healthEventStarted(r'health_event_started'),
  @JsonValue(r'health_event_ended')
  healthEventEnded(r'health_event_ended'),
  @JsonValue(r'health_event_outcome_confirmed')
  healthEventOutcomeConfirmed(r'health_event_outcome_confirmed'),
  @JsonValue(r'suggestion_impression')
  suggestionImpression(r'suggestion_impression'),
  @JsonValue(r'suggestion_actioned')
  suggestionActioned(r'suggestion_actioned'),
  @JsonValue(r'review_opened')
  reviewOpened(r'review_opened'),
  @JsonValue(r'visit_summary_previewed')
  visitSummaryPreviewed(r'visit_summary_previewed'),
  @JsonValue(r'visit_summary_exported')
  visitSummaryExported(r'visit_summary_exported'),
  @JsonValue(r'visit_summary_share_created')
  visitSummaryShareCreated(r'visit_summary_share_created'),
  @JsonValue(r'visit_summary_share_opened')
  visitSummaryShareOpened(r'visit_summary_share_opened'),
  @JsonValue(r'visit_summary_share_revoked')
  visitSummaryShareRevoked(r'visit_summary_share_revoked'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventsControllerRecordBatchV1RequestEventsInnerNameEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// In-app surface where the event occurred; 'system' marks server-initiated events.
enum ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum {
  @JsonValue(r'today')
  today(r'today'),
  @JsonValue(r'record')
  record(r'record'),
  @JsonValue(r'review')
  review(r'review'),
  @JsonValue(r'more')
  more(r'more'),
  @JsonValue(r'notification')
  notification(r'notification'),
  @JsonValue(r'system')
  system(r'system'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventsControllerRecordBatchV1RequestEventsInnerSurfaceEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
enum ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum {
  @JsonValue(r'success')
  success(r'success'),
  @JsonValue(r'failure')
  failure(r'failure'),
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle status — only health_event_started (active) / health_event_ended (ended) report it; other events omit it.
enum ProductEventsControllerRecordBatchV1RequestEventsInnerEventStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventsControllerRecordBatchV1RequestEventsInnerEventStatusEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}

/// Client platform.
enum ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum {
  @JsonValue(r'ios')
  ios(r'ios'),
  @JsonValue(r'android')
  android(r'android'),
  @JsonValue(r'web')
  web(r'web'),
  @JsonValue(r'windows')
  windows(r'windows'),
  @JsonValue(r'macos')
  macos(r'macos'),
  @JsonValue(r'linux')
  linux(r'linux'),
  @JsonValue(r'watchos')
  watchos(r'watchos'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventsControllerRecordBatchV1RequestEventsInnerPlatformEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
