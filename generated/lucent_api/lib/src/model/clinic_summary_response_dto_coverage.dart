//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_check_ins.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_water.dart';
import 'package:lucent_api/src/model/clinic_summary_response_dto_coverage_sleep.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_dto_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseDtoCoverage {
  /// Returns a new [ClinicSummaryResponseDtoCoverage] instance.
  ClinicSummaryResponseDtoCoverage({
    required this.checkIns,

    this.water,

    required this.dose,

    this.sleep,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final ClinicSummaryResponseDtoCoverageCheckIns checkIns;

  @JsonKey(name: r'water', required: false, includeIfNull: false)
  final ClinicSummaryResponseDtoCoverageWater? water;

  @JsonKey(name: r'dose', required: true, includeIfNull: false)
  final ClinicSummaryResponseDtoCoverageCheckIns dose;

  @JsonKey(name: r'sleep', required: false, includeIfNull: false)
  final ClinicSummaryResponseDtoCoverageSleep? sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseDtoCoverage &&
          other.checkIns == checkIns &&
          other.water == water &&
          other.dose == dose &&
          other.sleep == sleep;

  @override
  int get hashCode =>
      checkIns.hashCode + water.hashCode + dose.hashCode + sleep.hashCode;

  factory ClinicSummaryResponseDtoCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryResponseDtoCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryResponseDtoCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
