//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_response_dto_check_in.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventResponseDtoCheckIn {
  /// Returns a new [HealthEventResponseDtoCheckIn] instance.
  HealthEventResponseDtoCheckIn({
    required this.id,

    required this.eventId,

    required this.date,

    required this.outcome,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'eventId', required: true, includeIfNull: false)
  final String eventId;

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventResponseDtoCheckInOutcomeEnum.unknownDefaultOpenApi,
  )
  final HealthEventResponseDtoCheckInOutcomeEnum outcome;

  /// Creation time in ISO 8601 format.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Last update time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventResponseDtoCheckIn &&
          other.id == id &&
          other.eventId == eventId &&
          other.date == date &&
          other.outcome == outcome &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      eventId.hashCode +
      date.hashCode +
      outcome.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory HealthEventResponseDtoCheckIn.fromJson(Map<String, dynamic> json) =>
      _$HealthEventResponseDtoCheckInFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventResponseDtoCheckInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthEventResponseDtoCheckInOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventResponseDtoCheckInOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
