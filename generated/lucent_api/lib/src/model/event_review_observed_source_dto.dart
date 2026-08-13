//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_observed_source_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewObservedSourceDto {
  /// Returns a new [EventReviewObservedSourceDto] instance.
  EventReviewObservedSourceDto({
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
        EventReviewObservedSourceDtoStateEnum.unknownDefaultOpenApi,
  )
  final EventReviewObservedSourceDtoStateEnum state;

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewObservedSourceDtoCoverageEnum.unknownDefaultOpenApi,
  )
  final EventReviewObservedSourceDtoCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<EventReviewObservedSourceDtoSourcesEnum> sources;

  /// Number of observations in the event window.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  /// No fixed expectation is defined for this source yet.
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
      other is EventReviewObservedSourceDto &&
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

  factory EventReviewObservedSourceDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewObservedSourceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewObservedSourceDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewObservedSourceDtoStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewObservedSourceDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
enum EventReviewObservedSourceDtoCoverageEnum {
  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonValue(r'partial')
  partial(r'partial'),

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonValue(r'none')
  none(r'none'),

  /// The skeleton emits 'none' or 'partial'; sufficiency assessment lands with the section services.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewObservedSourceDtoCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewObservedSourceDtoSourcesEnum {
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

  const EventReviewObservedSourceDtoSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
