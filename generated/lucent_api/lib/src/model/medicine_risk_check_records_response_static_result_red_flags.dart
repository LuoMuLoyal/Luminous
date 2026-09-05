//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_static_result_red_flags.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseStaticResultRedFlags {
  /// Returns a new [MedicineRiskCheckRecordsResponseStaticResultRedFlags] instance.
  MedicineRiskCheckRecordsResponseStaticResultRedFlags({
    required this.rule,

    required this.primaryMedicineName,

    this.relatedLabel,
  });

  /// Red flag rule.
  @JsonKey(
    name: r'rule',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum rule;

  /// Medicine the flag is about.
  @JsonKey(name: r'primaryMedicineName', required: true, includeIfNull: false)
  final String primaryMedicineName;

  /// Related label.
  @JsonKey(name: r'relatedLabel', required: false, includeIfNull: false)
  final String? relatedLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseStaticResultRedFlags &&
          other.rule == rule &&
          other.primaryMedicineName == primaryMedicineName &&
          other.relatedLabel == relatedLabel;

  @override
  int get hashCode =>
      rule.hashCode + primaryMedicineName.hashCode + relatedLabel.hashCode;

  factory MedicineRiskCheckRecordsResponseStaticResultRedFlags.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseStaticResultRedFlagsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseStaticResultRedFlagsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Red flag rule.
enum MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum {
  @JsonValue(r'severeAllergy')
  severeAllergy(r'severeAllergy'),
  @JsonValue(r'informationGap')
  informationGap(r'informationGap'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
