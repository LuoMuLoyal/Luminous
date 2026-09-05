//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/clinic_summary_response_coverage_sleep.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_water.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_check_ins.dart';
import 'package:lucent_api/src/model/clinic_summary_response_coverage_dose.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_response_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryResponseCoverage {
  /// Returns a new [ClinicSummaryResponseCoverage] instance.
  ClinicSummaryResponseCoverage({
    required this.checkIns,

    this.water,

    required this.dose,

    this.sleep,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final ClinicSummaryResponseCoverageCheckIns checkIns;

  @JsonKey(name: r'water', required: false, includeIfNull: false)
  final ClinicSummaryResponseCoverageWater? water;

  @JsonKey(name: r'dose', required: true, includeIfNull: false)
  final ClinicSummaryResponseCoverageDose dose;

  @JsonKey(name: r'sleep', required: false, includeIfNull: false)
  final ClinicSummaryResponseCoverageSleep? sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryResponseCoverage &&
          other.checkIns == checkIns &&
          other.water == water &&
          other.dose == dose &&
          other.sleep == sleep;

  @override
  int get hashCode =>
      checkIns.hashCode + water.hashCode + dose.hashCode + sleep.hashCode;

  factory ClinicSummaryResponseCoverage.fromJson(Map<String, dynamic> json) =>
      _$ClinicSummaryResponseCoverageFromJson(json);

  Map<String, dynamic> toJson() => _$ClinicSummaryResponseCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
