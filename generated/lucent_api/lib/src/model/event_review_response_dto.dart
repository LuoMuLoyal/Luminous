//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_source_timestamps_dto.dart';
import 'package:lucent_api/src/model/event_review_coverage_summary_dto.dart';
import 'package:lucent_api/src/model/event_review_event_dto.dart';
import 'package:lucent_api/src/model/event_review_sections_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseDto {
  /// Returns a new [EventReviewResponseDto] instance.
  EventReviewResponseDto({
    required this.event,

    required this.sections,

    required this.coverage,

    required this.sourceTimestamps,

    required this.availableActions,

    required this.generatedAt,
  });

  @JsonKey(name: r'event', required: true, includeIfNull: false)
  final EventReviewEventDto event;

  @JsonKey(name: r'sections', required: true, includeIfNull: false)
  final EventReviewSectionsDto sections;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final EventReviewCoverageSummaryDto coverage;

  @JsonKey(name: r'sourceTimestamps', required: true, includeIfNull: false)
  final EventReviewSourceTimestampsDto sourceTimestamps;

  /// Actions the user can take from this review, mapped by the client.
  @JsonKey(name: r'availableActions', required: true, includeIfNull: false)
  final List<EventReviewResponseDtoAvailableActionsEnum> availableActions;

  /// Review assembly time in ISO 8601 format.
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseDto &&
          other.event == event &&
          other.sections == sections &&
          other.coverage == coverage &&
          other.sourceTimestamps == sourceTimestamps &&
          other.availableActions == availableActions &&
          other.generatedAt == generatedAt;

  @override
  int get hashCode =>
      event.hashCode +
      sections.hashCode +
      coverage.hashCode +
      sourceTimestamps.hashCode +
      availableActions.hashCode +
      generatedAt.hashCode;

  factory EventReviewResponseDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseDtoAvailableActionsEnum {
  @JsonValue(r'check_in')
  checkIn(r'check_in'),
  @JsonValue(r'end_event')
  endEvent(r'end_event'),
  @JsonValue(r'clinic_summary')
  clinicSummary(r'clinic_summary'),
  @JsonValue(r'export')
  export_(r'export'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseDtoAvailableActionsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
