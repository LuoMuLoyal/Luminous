//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_today_check_in_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_check_in_coverage_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewCheckInCoverageDto {
  /// Returns a new [EventReviewCheckInCoverageDto] instance.
  EventReviewCheckInCoverageDto({
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
        EventReviewCheckInCoverageDtoStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewCheckInCoverageDtoStateEnum state;

  /// 'none' when no check-ins exist; 'partial' when check-ins exist but sufficiency is not yet assessed by the section services.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewCheckInCoverageDtoCoverageEnum.unknownDefaultOpenApi,
  )
  final EventReviewCheckInCoverageDtoCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<EventReviewCheckInCoverageDtoSourcesEnum> sources;

  /// Number of user-confirmed check-ins.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  /// No fixed expectation exists for check-ins.
  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  /// First check-in calendar date, or null when none exists.
  @JsonKey(name: r'firstCheckInDate', required: true, includeIfNull: true)
  final String? firstCheckInDate;

  /// Last check-in calendar date, or null when none exists.
  @JsonKey(name: r'lastCheckInDate', required: true, includeIfNull: true)
  final String? lastCheckInDate;

  @JsonKey(name: r'todayCheckIn', required: true, includeIfNull: true)
  final EventReviewTodayCheckInDto? todayCheckIn;

  /// Event window start in ISO 8601 format.
  @JsonKey(name: r'windowStart', required: true, includeIfNull: false)
  final String windowStart;

  /// Event window end in ISO 8601 format.
  @JsonKey(name: r'windowEnd', required: true, includeIfNull: false)
  final String windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewCheckInCoverageDto &&
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

  factory EventReviewCheckInCoverageDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewCheckInCoverageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewCheckInCoverageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewCheckInCoverageDtoStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewCheckInCoverageDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// 'none' when no check-ins exist; 'partial' when check-ins exist but sufficiency is not yet assessed by the section services.
enum EventReviewCheckInCoverageDtoCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewCheckInCoverageDtoCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewCheckInCoverageDtoSourcesEnum {
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

  const EventReviewCheckInCoverageDtoSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
