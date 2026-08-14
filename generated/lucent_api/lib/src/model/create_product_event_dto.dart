//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/product_event_result.dart';
import 'package:lucent_api/src/model/health_event_status.dart';
import 'package:lucent_api/src/model/product_event_surface.dart';
import 'package:lucent_api/src/model/product_event_name.dart';
import 'package:lucent_api/src/model/user_device_platform.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_product_event_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateProductEventDto {
  /// Returns a new [CreateProductEventDto] instance.
  CreateProductEventDto({
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
    unknownEnumValue: ProductEventName.unknownDefaultOpenApi,
  )
  final ProductEventName name;

  /// In-app surface where the event occurred; 'system' marks server-initiated events.
  @JsonKey(
    name: r'surface',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ProductEventSurface.unknownDefaultOpenApi,
  )
  final ProductEventSurface surface;

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonKey(
    name: r'result',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ProductEventResult.unknownDefaultOpenApi,
  )
  final ProductEventResult result;

  /// Lifecycle status — only health_event_started (active) / health_event_ended (ended) report it; other events omit it.
  @JsonKey(
    name: r'eventStatus',
    required: false,
    includeIfNull: false,
    unknownEnumValue: HealthEventStatus.unknownDefaultOpenApi,
  )
  final HealthEventStatus? eventStatus;

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
    unknownEnumValue: UserDevicePlatform.unknownDefaultOpenApi,
  )
  final UserDevicePlatform platform;

  /// Event time (ISO 8601). Retention scans this field (90 days).
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Client-generated id enabling retry idempotency — unique per user, so retried batches never double-insert.
  @JsonKey(name: r'clientEventId', required: true, includeIfNull: false)
  final String clientEventId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateProductEventDto &&
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

  factory CreateProductEventDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProductEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
