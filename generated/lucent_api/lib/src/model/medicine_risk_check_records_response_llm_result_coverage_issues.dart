//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_llm_result_coverage_issues.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseLlmResultCoverageIssues {
  /// Returns a new [MedicineRiskCheckRecordsResponseLlmResultCoverageIssues] instance.
  MedicineRiskCheckRecordsResponseLlmResultCoverageIssues({
    required this.medicineName,

    required this.reason,
  });

  /// Medicine name without source detail.
  @JsonKey(name: r'medicineName', required: true, includeIfNull: false)
  final String medicineName;

  /// Why the medicine detail was not checked.
  @JsonKey(
    name: r'reason',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesReasonEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesReasonEnum
  reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseLlmResultCoverageIssues &&
          other.medicineName == medicineName &&
          other.reason == reason;

  @override
  int get hashCode => medicineName.hashCode + reason.hashCode;

  factory MedicineRiskCheckRecordsResponseLlmResultCoverageIssues.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Why the medicine detail was not checked.
enum MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesReasonEnum {
  @JsonValue(r'manualEntry')
  manualEntry(r'manualEntry'),
  @JsonValue(r'missingSourceRef')
  missingSourceRef(r'missingSourceRef'),
  @JsonValue(r'detailUnavailable')
  detailUnavailable(r'detailUnavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseLlmResultCoverageIssuesReasonEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
