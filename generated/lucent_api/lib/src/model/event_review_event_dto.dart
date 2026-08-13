//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_outcome.dart';
import 'package:lucent_api/src/model/health_event_status.dart';
import 'package:lucent_api/src/model/health_event_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_event_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewEventDto {
  /// Returns a new [EventReviewEventDto] instance.
  EventReviewEventDto({
    required this.id,

    required this.kind,

    required this.title,

    required this.status,

    required this.startedAt,

    required this.endedAt,

    required this.outcome,

    required this.currentMedicineIds,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventKind.unknownDefaultOpenApi,
  )
  final HealthEventKind kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventStatus.unknownDefaultOpenApi,
  )
  final HealthEventStatus status;

  /// Start time in ISO 8601 format.
  @JsonKey(name: r'startedAt', required: true, includeIfNull: false)
  final String startedAt;

  /// End time in ISO 8601 format, or null while active.
  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final String? endedAt;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: true,
    unknownEnumValue: HealthEventOutcome.unknownDefaultOpenApi,
  )
  final HealthEventOutcome? outcome;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewEventDto &&
          other.id == id &&
          other.kind == kind &&
          other.title == title &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.outcome == outcome &&
          other.currentMedicineIds == currentMedicineIds;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      title.hashCode +
      status.hashCode +
      startedAt.hashCode +
      (endedAt == null ? 0 : endedAt.hashCode) +
      (outcome == null ? 0 : outcome.hashCode) +
      currentMedicineIds.hashCode;

  factory EventReviewEventDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewEventDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
