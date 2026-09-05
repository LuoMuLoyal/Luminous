//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'record_batch_request_events.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RecordBatchRequestEvents {
  /// Returns a new [RecordBatchRequestEvents] instance.
  RecordBatchRequestEvents({
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
    unknownEnumValue: RecordBatchRequestEventsNameEnum.unknownDefaultOpenApi,
  )
  final RecordBatchRequestEventsNameEnum name;

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonKey(
    name: r'surface',
    required: true,
    includeIfNull: false,
    unknownEnumValue: RecordBatchRequestEventsSurfaceEnum.unknownDefaultOpenApi,
  )
  final RecordBatchRequestEventsSurfaceEnum surface;

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonKey(
    name: r'result',
    required: true,
    includeIfNull: false,
    unknownEnumValue: RecordBatchRequestEventsResultEnum.unknownDefaultOpenApi,
  )
  final RecordBatchRequestEventsResultEnum result;

  /// Lifecycle status — only health_event_started (active) / health_event_ended (ended) report it; other events omit it.
  @JsonKey(
    name: r'eventStatus',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        RecordBatchRequestEventsEventStatusEnum.unknownDefaultOpenApi,
  )
  final RecordBatchRequestEventsEventStatusEnum? eventStatus;

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
        RecordBatchRequestEventsPlatformEnum.unknownDefaultOpenApi,
  )
  final RecordBatchRequestEventsPlatformEnum platform;

  /// Event time (ISO 8601). Retention scans this field (90 days).
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Client-generated id enabling retry idempotency — unique per user, so retried batches never double-insert.
  @JsonKey(name: r'clientEventId', required: true, includeIfNull: false)
  final String clientEventId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordBatchRequestEvents &&
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

  factory RecordBatchRequestEvents.fromJson(Map<String, dynamic> json) =>
      _$RecordBatchRequestEventsFromJson(json);

  Map<String, dynamic> toJson() => _$RecordBatchRequestEventsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Fixed product event name — enums only, no free text.
enum RecordBatchRequestEventsNameEnum {
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

  const RecordBatchRequestEventsNameEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// In-app surface where the event occurred; 'system' marks server-initiated events.
enum RecordBatchRequestEventsSurfaceEnum {
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

  const RecordBatchRequestEventsSurfaceEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
enum RecordBatchRequestEventsResultEnum {
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

  const RecordBatchRequestEventsResultEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Lifecycle status — only health_event_started (active) / health_event_ended (ended) report it; other events omit it.
enum RecordBatchRequestEventsEventStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const RecordBatchRequestEventsEventStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Client platform.
enum RecordBatchRequestEventsPlatformEnum {
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

  const RecordBatchRequestEventsPlatformEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
