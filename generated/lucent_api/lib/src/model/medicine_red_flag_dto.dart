//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_red_flag_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRedFlagDto {
  /// Returns a new [MedicineRedFlagDto] instance.
  MedicineRedFlagDto({
    required this.rule,

    required this.primaryMedicineName,

    this.relatedLabel,
  });

  @JsonKey(
    name: r'rule',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineRedFlagDtoRuleEnum.unknownDefaultOpenApi,
  )
  final MedicineRedFlagDtoRuleEnum rule;

  @JsonKey(name: r'primaryMedicineName', required: true, includeIfNull: false)
  final String primaryMedicineName;

  @JsonKey(name: r'relatedLabel', required: false, includeIfNull: false)
  final String? relatedLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRedFlagDto &&
          other.rule == rule &&
          other.primaryMedicineName == primaryMedicineName &&
          other.relatedLabel == relatedLabel;

  @override
  int get hashCode =>
      rule.hashCode + primaryMedicineName.hashCode + relatedLabel.hashCode;

  factory MedicineRedFlagDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineRedFlagDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRedFlagDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineRedFlagDtoRuleEnum {
  @JsonValue(r'severeAllergy')
  severeAllergy(r'severeAllergy'),
  @JsonValue(r'informationGap')
  informationGap(r'informationGap'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRedFlagDtoRuleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
