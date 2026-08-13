//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_section_facts_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_section_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewSectionDto {
  /// Returns a new [EventReviewSectionDto] instance.
  EventReviewSectionDto({required this.state, this.reasonCode, this.facts});

  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EventReviewSectionDtoStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewSectionDtoStateEnum state;

  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonKey(
    name: r'reasonCode',
    required: false,
    includeIfNull: false,
    unknownEnumValue: EventReviewSectionDtoReasonCodeEnum.unknownDefaultOpenApi,
  )
  final EventReviewSectionDtoReasonCodeEnum? reasonCode;

  /// Basic facts when state is available.
  @JsonKey(name: r'facts', required: false, includeIfNull: false)
  final EventReviewSectionFactsDto? facts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewSectionDto &&
          other.state == state &&
          other.reasonCode == reasonCode &&
          other.facts == facts;

  @override
  int get hashCode => state.hashCode + reasonCode.hashCode + facts.hashCode;

  factory EventReviewSectionDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewSectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewSectionDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewSectionDtoStateEnum {
  @JsonValue(r'available')
  available(r'available'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewSectionDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
enum EventReviewSectionDtoReasonCodeEnum {
  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonValue(r'no_observations')
  noObservations(r'no_observations'),

  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonValue(r'no_completed_actions')
  noCompletedActions(r'no_completed_actions'),

  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonValue(r'insufficient_coverage')
  insufficientCoverage(r'insufficient_coverage'),

  /// Fixed reason code when state is unknown: no_observations (window has no observations), no_completed_actions (no confirmed doses or check-ins), insufficient_coverage (observations exist but no trend is computable).
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewSectionDtoReasonCodeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
