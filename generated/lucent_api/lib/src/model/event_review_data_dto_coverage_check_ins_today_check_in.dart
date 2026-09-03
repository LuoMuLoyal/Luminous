//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_dto_coverage_check_ins_today_check_in.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataDtoCoverageCheckInsTodayCheckIn {
  /// Returns a new [EventReviewDataDtoCoverageCheckInsTodayCheckIn] instance.
  EventReviewDataDtoCoverageCheckInsTodayCheckIn({
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
    unknownEnumValue: EventReviewDataDtoCoverageCheckInsTodayCheckInOutcomeEnum
        .unknownDefaultOpenApi,
  )
  final EventReviewDataDtoCoverageCheckInsTodayCheckInOutcomeEnum outcome;

  /// Last update time in ISO 8601 format.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataDtoCoverageCheckInsTodayCheckIn &&
          other.date == date &&
          other.outcome == outcome &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => date.hashCode + outcome.hashCode + updatedAt.hashCode;

  factory EventReviewDataDtoCoverageCheckInsTodayCheckIn.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewDataDtoCoverageCheckInsTodayCheckInFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewDataDtoCoverageCheckInsTodayCheckInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewDataDtoCoverageCheckInsTodayCheckInOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewDataDtoCoverageCheckInsTodayCheckInOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
