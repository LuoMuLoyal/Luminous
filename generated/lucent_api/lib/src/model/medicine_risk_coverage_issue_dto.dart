//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_coverage_issue_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCoverageIssueDto {
  /// Returns a new [MedicineRiskCoverageIssueDto] instance.
  MedicineRiskCoverageIssueDto({
    required this.medicineName,
    required this.reason,
  });

  @JsonKey(name: r'medicineName', required: true, includeIfNull: false)
  final String medicineName;

  @JsonKey(
    name: r'reason',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCoverageIssueDtoReasonEnum.unknownDefaultOpenApi,
  )
  final MedicineRiskCoverageIssueDtoReasonEnum reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCoverageIssueDto &&
          other.medicineName == medicineName &&
          other.reason == reason;

  @override
  int get hashCode => medicineName.hashCode + reason.hashCode;

  factory MedicineRiskCoverageIssueDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineRiskCoverageIssueDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRiskCoverageIssueDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineRiskCoverageIssueDtoReasonEnum {
  @JsonValue(r'manualEntry')
  manualEntry(r'manualEntry'),
  @JsonValue(r'missingSourceRef')
  missingSourceRef(r'missingSourceRef'),
  @JsonValue(r'detailUnavailable')
  detailUnavailable(r'detailUnavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCoverageIssueDtoReasonEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
