//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_coverage_daily_records.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataCoverageDailyRecords {
  /// Returns a new [EventReviewDataCoverageDailyRecords] instance.
  EventReviewDataCoverageDailyRecords({
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
        EventReviewDataCoverageDailyRecordsStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewDataCoverageDailyRecordsStateEnum state;

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewDataCoverageDailyRecordsCoverageEnum.unknownDefaultOpenApi,
  )
  final EventReviewDataCoverageDailyRecordsCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<EventReviewDataCoverageDailyRecordsSourcesEnum> sources;

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
      other is EventReviewDataCoverageDailyRecords &&
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

  factory EventReviewDataCoverageDailyRecords.fromJson(
    Map<String, dynamic> json,
  ) => _$EventReviewDataCoverageDailyRecordsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EventReviewDataCoverageDailyRecordsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewDataCoverageDailyRecordsStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewDataCoverageDailyRecordsStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
enum EventReviewDataCoverageDailyRecordsCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewDataCoverageDailyRecordsCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewDataCoverageDailyRecordsSourcesEnum {
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

  const EventReviewDataCoverageDailyRecordsSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
