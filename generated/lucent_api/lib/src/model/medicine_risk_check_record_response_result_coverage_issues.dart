//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_record_response_result_coverage_issues.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordResponseResultCoverageIssues {
  /// Returns a new [MedicineRiskCheckRecordResponseResultCoverageIssues] instance.
  MedicineRiskCheckRecordResponseResultCoverageIssues({
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
        MedicineRiskCheckRecordResponseResultCoverageIssuesReasonEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordResponseResultCoverageIssuesReasonEnum reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordResponseResultCoverageIssues &&
          other.medicineName == medicineName &&
          other.reason == reason;

  @override
  int get hashCode => medicineName.hashCode + reason.hashCode;

  factory MedicineRiskCheckRecordResponseResultCoverageIssues.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordResponseResultCoverageIssuesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordResponseResultCoverageIssuesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Why the medicine detail was not checked.
enum MedicineRiskCheckRecordResponseResultCoverageIssuesReasonEnum {
  @JsonValue(r'manualEntry')
  manualEntry(r'manualEntry'),
  @JsonValue(r'missingSourceRef')
  missingSourceRef(r'missingSourceRef'),
  @JsonValue(r'detailUnavailable')
  detailUnavailable(r'detailUnavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordResponseResultCoverageIssuesReasonEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
