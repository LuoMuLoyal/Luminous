//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_event.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseEvent {
  /// Returns a new [EventReviewResponseEvent] instance.
  EventReviewResponseEvent({
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
    unknownEnumValue: EventReviewResponseEventKindEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseEventKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EventReviewResponseEventStatusEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseEventStatusEnum status;

  /// Start time in ISO 8601 format.
  @JsonKey(name: r'startedAt', required: true, includeIfNull: false)
  final String startedAt;

  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final String? endedAt;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: true,
    unknownEnumValue: EventReviewResponseEventOutcomeEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseEventOutcomeEnum? outcome;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseEvent &&
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

  factory EventReviewResponseEvent.fromJson(Map<String, dynamic> json) =>
      _$EventReviewResponseEventFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewResponseEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseEventKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseEventKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewResponseEventStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseEventStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewResponseEventOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseEventOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
