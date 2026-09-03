//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_coverage_water.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoCoverageWater {
  /// Returns a new [ClinicSummaryResponseDtoCoverageWater] instance.
  ClinicSummaryResponseDtoCoverageWater({
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
        ClinicSummaryResponseDtoCoverageWaterStateEnum.unknownDefaultOpenApi,
  )
  final ClinicSummaryResponseDtoCoverageWaterStateEnum state;

  /// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
  @JsonKey(
    name: r'coverage',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ClinicSummaryResponseDtoCoverageWaterCoverageEnum.unknownDefaultOpenApi,
  )
  final ClinicSummaryResponseDtoCoverageWaterCoverageEnum coverage;

  @JsonKey(name: r'sources', required: true, includeIfNull: false)
  final List<ClinicSummaryResponseDtoCoverageWaterSourcesEnum> sources;

  /// Number of observations in the window.
  @JsonKey(name: r'observedCount', required: true, includeIfNull: false)
  final num observedCount;

  @JsonKey(name: r'expectedCount', required: true, includeIfNull: true)
  final num? expectedCount;

  @JsonKey(name: r'windowStart', required: true, includeIfNull: true)
  final String? windowStart;

  @JsonKey(name: r'windowEnd', required: true, includeIfNull: true)
  final String? windowEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoCoverageWater &&
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

  factory ClinicSummaryResponseDtoCoverageWater.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoCoverageWaterFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoCoverageWaterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ClinicSummaryResponseDtoCoverageWaterStateEnum {
  @JsonValue(r'observed')
  observed(r'observed'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ClinicSummaryResponseDtoCoverageWaterStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// 'none' when the source has no observations; 'partial' when observations exist but sufficiency is not assessed.
enum ClinicSummaryResponseDtoCoverageWaterCoverageEnum {
  @JsonValue(r'sufficient')
  sufficient(r'sufficient'),
  @JsonValue(r'partial')
  partial(r'partial'),
  @JsonValue(r'none')
  none(r'none'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ClinicSummaryResponseDtoCoverageWaterCoverageEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ClinicSummaryResponseDtoCoverageWaterSourcesEnum {
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

  const ClinicSummaryResponseDtoCoverageWaterSourcesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
