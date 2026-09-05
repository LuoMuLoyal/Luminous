//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_record_response_result_red_flags.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordResponseResultRedFlags {
  /// Returns a new [MedicineRiskCheckRecordResponseResultRedFlags] instance.
  MedicineRiskCheckRecordResponseResultRedFlags({
    required this.rule,

    required this.primaryMedicineName,

    this.relatedLabel,
  });

  /// Red flag rule.
  @JsonKey(
    name: r'rule',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineRiskCheckRecordResponseResultRedFlagsRuleEnum
        .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordResponseResultRedFlagsRuleEnum rule;

  /// Medicine the flag is about.
  @JsonKey(name: r'primaryMedicineName', required: true, includeIfNull: false)
  final String primaryMedicineName;

  /// Related label.
  @JsonKey(name: r'relatedLabel', required: false, includeIfNull: false)
  final String? relatedLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordResponseResultRedFlags &&
          other.rule == rule &&
          other.primaryMedicineName == primaryMedicineName &&
          other.relatedLabel == relatedLabel;

  @override
  int get hashCode =>
      rule.hashCode + primaryMedicineName.hashCode + relatedLabel.hashCode;

  factory MedicineRiskCheckRecordResponseResultRedFlags.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordResponseResultRedFlagsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordResponseResultRedFlagsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Red flag rule.
enum MedicineRiskCheckRecordResponseResultRedFlagsRuleEnum {
  @JsonValue(r'severeAllergy')
  severeAllergy(r'severeAllergy'),
  @JsonValue(r'informationGap')
  informationGap(r'informationGap'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordResponseResultRedFlagsRuleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
