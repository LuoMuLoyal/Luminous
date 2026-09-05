//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_response_coverage_check_ins_today_check_in.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_coverage_check_ins.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseCoverageCheckIns {
  /// Returns a new [EventReviewResponseCoverageCheckIns] instance.
  EventReviewResponseCoverageCheckIns({
    required this.state,

    required this.coverage,

    required this.sources,

    required this.observedCount,

    required this.expectedCount,

    required this.firstCheckInDate,

    required this.lastCheckInDate,

    required this.todayCheckIn,

    required this.windowStart,

    required this.windowEnd,
  });

  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewResponseCoverageCheckInsStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseCoverageCheckInsStateEnum state;

  /// 'none' when no check-ins exist; 'partial' when check-ins exist but sufficiency is not yet assessed by the section services.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewResponseCoverageCheckInsCoverageEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseCoverageCheckInsCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<EventReviewResponseCoverageCheckInsSourcesEnum> sources;

  /// Number of user-confirmed check-ins.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  @JsonKey(name: r'firstCheckInDate', required: true, includeIfNull: true)
  final String? firstCheckInDate;

  @JsonKey(name: r'lastCheckInDate', required: true, includeIfNull: true)
  final String? lastCheckInDate;

  @JsonKey(name: r'todayCheckIn', required: true, includeIfNull: true)
  final EventReviewResponseCoverageCheckInsTodayCheckIn? todayCheckIn;

  /// Event window start in ISO 8601 format.
  @JsonKey(name: r'windowStart', required: true, includeIfNull: false)
  final String windowStart;

  /// Event window end in ISO 8601 format.
  @JsonKey(name: r'windowEnd', required: true, includeIfNull: false)
  final String windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseCoverageCheckIns &&
          other.state == state &&
          other.coverage == coverage &&
          other.sources == sources &&
          other.observedCount == observedCount &&
          other.expectedCount == expectedCount &&
          other.firstCheckInDate == firstCheckInDate &&
          other.lastCheckInDate == lastCheckInDate &&
          other.todayCheckIn == todayCheckIn &&
          other.windowStart == windowStart &&
          other.windowEnd == windowEnd;

  @override
  int get hashCode =>
      state.hashCode +
      coverage.hashCode +
      sources.hashCode +
      observedCount.hashCode +
      (expectedCount == null ? 0 : expectedCount.hashCode) +
      (firstCheckInDate == null ? 0 : firstCheckInDate.hashCode) +
      (lastCheckInDate == null ? 0 : lastCheckInDate.hashCode) +
      (todayCheckIn == null ? 0 : todayCheckIn.hashCode) +
      windowStart.hashCode +
      windowEnd.hashCode;

  factory EventReviewResponseCoverageCheckIns.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewResponseCoverageCheckInsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewResponseCoverageCheckInsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseCoverageCheckInsStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageCheckInsStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// 'none' when no check-ins exist; 'partial' when check-ins exist but sufficiency is not yet assessed by the section services.
enum EventReviewResponseCoverageCheckInsCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageCheckInsCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewResponseCoverageCheckInsSourcesEnum {
  @JsonValue(r'manual')
  manual(r'manual'),
  @JsonValue(r'health_platform')
  healthPlatform(r'health_platform'),
  @JsonValue(r'reminder_plan')
  reminderPlan(r'reminder_plan'),
  @JsonValue(r'derived')
  derived(r'derived'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageCheckInsSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
