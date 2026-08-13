//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_today_check_in_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewTodayCheckInDto {
  /// Returns a new [EventReviewTodayCheckInDto] instance.
  EventReviewTodayCheckInDto({
    required this.date,

    required this.outcome,

    required this.updatedAt,
  });

  /// Calendar date in YYYY-MM-DD format.
  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final String date;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventOutcome.unknownDefaultOpenApi,
  )
  final HealthEventOutcome outcome;

  /// Last update time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewTodayCheckInDto &&
          other.date == date &&
          other.outcome == outcome &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => date.hashCode + outcome.hashCode + updatedAt.hashCode;

  factory EventReviewTodayCheckInDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewTodayCheckInDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewTodayCheckInDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
