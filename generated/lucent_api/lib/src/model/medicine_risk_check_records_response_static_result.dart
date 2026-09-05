//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_red_flags.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_coverage_issues.dart';
import 'package:lucent_api/src/model/medicine_risk_check_records_response_static_result_findings.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_static_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseStaticResult {
  /// Returns a new [MedicineRiskCheckRecordsResponseStaticResult] instance.
  MedicineRiskCheckRecordsResponseStaticResult({
    required this.overallRiskLevel,

    required this.overallRiskScore,

    required this.currentMedicineCount,

    required this.checkedMedicineCount,

    required this.findings,

    required this.coverageIssues,

    required this.redFlags,

    this.overallRecommendation,
  });

  /// Overall risk level.
  @JsonKey(
    name: r'overallRiskLevel',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum
  overallRiskLevel;

  /// Overall risk score (0-100).
  @JsonKey(name: r'overallRiskScore', required: true, includeIfNull: false)
  final num overallRiskScore;

  /// Current medicine count.
  @JsonKey(name: r'currentMedicineCount', required: true, includeIfNull: false)
  final num currentMedicineCount;

  /// Count actually checked.
  @JsonKey(name: r'checkedMedicineCount', required: true, includeIfNull: false)
  final num checkedMedicineCount;

  /// Detected risk findings.
  @JsonKey(name: r'findings', required: true, includeIfNull: false)
  final List<MedicineRiskCheckRecordsResponseStaticResultFindings> findings;

  /// Medicines skipped due to missing detail.
  @JsonKey(name: r'coverageIssues', required: true, includeIfNull: false)
  final List<MedicineRiskCheckRecordsResponseStaticResultCoverageIssues>
  coverageIssues;

  /// Raised red flags.
  @JsonKey(name: r'redFlags', required: true, includeIfNull: false)
  final List<MedicineRiskCheckRecordsResponseStaticResultRedFlags> redFlags;

  /// LLM check only
  @JsonKey(
    name: r'overallRecommendation',
    required: false,
    includeIfNull: false,
  )
  final String? overallRecommendation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseStaticResult &&
          other.overallRiskLevel == overallRiskLevel &&
          other.overallRiskScore == overallRiskScore &&
          other.currentMedicineCount == currentMedicineCount &&
          other.checkedMedicineCount == checkedMedicineCount &&
          other.findings == findings &&
          other.coverageIssues == coverageIssues &&
          other.redFlags == redFlags &&
          other.overallRecommendation == overallRecommendation;

  @override
  int get hashCode =>
      overallRiskLevel.hashCode +
      overallRiskScore.hashCode +
      currentMedicineCount.hashCode +
      checkedMedicineCount.hashCode +
      findings.hashCode +
      coverageIssues.hashCode +
      redFlags.hashCode +
      overallRecommendation.hashCode;

  factory MedicineRiskCheckRecordsResponseStaticResult.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseStaticResultFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseStaticResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Overall risk level.
enum MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum {
  @JsonValue(r'safe')
  safe(r'safe'),
  @JsonValue(r'caution')
  caution(r'caution'),
  @JsonValue(r'risk')
  risk(r'risk'),
  @JsonValue(r'danger')
  danger(r'danger'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
