//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_response_coverage_dose_logs.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewResponseCoverageDoseLogs {
  /// Returns a new [EventReviewResponseCoverageDoseLogs] instance.
  EventReviewResponseCoverageDoseLogs({
    required this.state,

    required this.coverage,

    required this.sources,

    required this.observedCount,

    required this.expectedCount,

    required this.windowStart,

    required this.windowEnd,
  });

  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewResponseCoverageDoseLogsStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseCoverageDoseLogsStateEnum state;

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewResponseCoverageDoseLogsCoverageEnum.unknownDefaultOpenApi,
  )
  final EventReviewResponseCoverageDoseLogsCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<EventReviewResponseCoverageDoseLogsSourcesEnum> sources;

  /// Number of observations in the event window.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  /// Event window start in ISO 8601 format.
  @JsonKey(name: r'windowStart', required: true, includeIfNull: false)
  final String windowStart;

  /// Event window end in ISO 8601 format.
  @JsonKey(name: r'windowEnd', required: true, includeIfNull: false)
  final String windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewResponseCoverageDoseLogs &&
          other.state == state &&
          other.coverage == coverage &&
          other.sources == sources &&
          other.observedCount == observedCount &&
          other.expectedCount == expectedCount &&
          other.windowStart == windowStart &&
          other.windowEnd == windowEnd;

  @override
  int get hashCode =>
      state.hashCode +
      coverage.hashCode +
      sources.hashCode +
      observedCount.hashCode +
      (expectedCount == null ? 0 : expectedCount.hashCode) +
      windowStart.hashCode +
      windowEnd.hashCode;

  factory EventReviewResponseCoverageDoseLogs.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewResponseCoverageDoseLogsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewResponseCoverageDoseLogsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewResponseCoverageDoseLogsStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageDoseLogsStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
enum EventReviewResponseCoverageDoseLogsCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewResponseCoverageDoseLogsCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewResponseCoverageDoseLogsSourcesEnum {
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

  const EventReviewResponseCoverageDoseLogsSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
