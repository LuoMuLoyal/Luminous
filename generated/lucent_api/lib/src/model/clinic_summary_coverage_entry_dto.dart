//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_coverage_entry_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryCoverageEntryDto {
  /// Returns a new [ClinicSummaryCoverageEntryDto] instance.
  ClinicSummaryCoverageEntryDto({
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
        ClinicSummaryCoverageEntryDtoStateEnum.unknownDefaultOpenApi,
  )
  final ClinicSummaryCoverageEntryDtoStateEnum state;

  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ClinicSummaryCoverageEntryDtoCoverageEnum.unknownDefaultOpenApi,
  )
  final ClinicSummaryCoverageEntryDtoCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<ClinicSummaryCoverageEntryDtoSourcesEnum> sources;

  /// Number of observations in the window.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  /// No fixed expectation is defined yet.
  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  /// Window start (ISO 8601), or null when nothing was observed.
  @JsonKey(name: r'windowStart', required: true, includeIfNull: true)
  final String? windowStart;

  /// Window end (ISO 8601), or null when nothing was observed.
  @JsonKey(name: r'windowEnd', required: true, includeIfNull: true)
  final String? windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryCoverageEntryDto &&
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
      (windowStart == null ? 0 : windowStart.hashCode) +
      (windowEnd == null ? 0 : windowEnd.hashCode);

  factory ClinicSummaryCoverageEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryCoverageEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryCoverageEntryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ClinicSummaryCoverageEntryDtoStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ClinicSummaryCoverageEntryDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
enum ClinicSummaryCoverageEntryDtoCoverageEnum {
  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),

  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonValue(r'partial')
  partial(r'partial'),

  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonValue(r'none')
  none(r'none'),

  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ClinicSummaryCoverageEntryDtoCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ClinicSummaryCoverageEntryDtoSourcesEnum {
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

  const ClinicSummaryCoverageEntryDtoSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
