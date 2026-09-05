//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_coverage_check_ins_today_check_in.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseCoverageCheckInsTodayCheckIn {
  /// Returns a new [EventReviewResponseCoverageCheckInsTodayCheckIn] instance.
  EventReviewResponseCoverageCheckInsTodayCheckIn({
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
    unknownEnumValue: EventReviewResponseCoverageCheckInsTodayCheckInOutcomeEnum
        .unknownDefaultOpenApi,
  )
  final EventReviewResponseCoverageCheckInsTodayCheckInOutcomeEnum outcome;

  /// Last update time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseCoverageCheckInsTodayCheckIn &&
          other.date == date &&
          other.outcome == outcome &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => date.hashCode + outcome.hashCode + updatedAt.hashCode;

  factory EventReviewResponseCoverageCheckInsTodayCheckIn.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewResponseCoverageCheckInsTodayCheckInFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewResponseCoverageCheckInsTodayCheckInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseCoverageCheckInsTodayCheckInOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageCheckInsTodayCheckInOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
