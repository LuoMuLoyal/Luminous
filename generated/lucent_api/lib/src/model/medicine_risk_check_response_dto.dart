//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_red_flag_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_coverage_issue_dto.dart';
import 'package:lucent_api/src/model/medicine_risk_finding_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckResponseDto {
  /// Returns a new [MedicineRiskCheckResponseDto] instance.
  MedicineRiskCheckResponseDto({
    required this.overallRiskLevel,
    required this.overallRiskScore,
    required this.currentMedicineCount,
    required this.checkedMedicineCount,
    required this.findings,
    required this.coverageIssues,
    required this.redFlags,
    this.overallRecommendation,
  });

  @JsonKey(
    name: r'overallRiskLevel',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckResponseDtoOverallRiskLevelEnum.unknownDefaultOpenApi,
  )
  final MedicineRiskCheckResponseDtoOverallRiskLevelEnum overallRiskLevel;

  // minimum: 0
  // maximum: 100
  @JsonKey(name: r'overallRiskScore', required: true, includeIfNull: false)
  final num overallRiskScore;

  @JsonKey(name: r'currentMedicineCount', required: true, includeIfNull: false)
  final num currentMedicineCount;

  @JsonKey(name: r'checkedMedicineCount', required: true, includeIfNull: false)
  final num checkedMedicineCount;

  @JsonKey(name: r'findings', required: true, includeIfNull: false)
  final List<MedicineRiskFindingDto> findings;

  @JsonKey(name: r'coverageIssues', required: true, includeIfNull: false)
  final List<MedicineRiskCoverageIssueDto> coverageIssues;

  @JsonKey(name: r'redFlags', required: true, includeIfNull: false)
  final List<MedicineRedFlagDto> redFlags;

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
      other is MedicineRiskCheckResponseDto &&
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

  factory MedicineRiskCheckResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineRiskCheckResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRiskCheckResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineRiskCheckResponseDtoOverallRiskLevelEnum {
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

  const MedicineRiskCheckResponseDtoOverallRiskLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
