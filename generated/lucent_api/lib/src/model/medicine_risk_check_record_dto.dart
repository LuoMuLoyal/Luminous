//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_response_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_record_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordDto {
  /// Returns a new [MedicineRiskCheckRecordDto] instance.
  MedicineRiskCheckRecordDto({
    required this.checkType,

    required this.result,

    required this.riskScore,

    required this.riskLevel,

    required this.stale,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(
    name: r'checkType',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordDtoCheckTypeEnum.unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordDtoCheckTypeEnum checkType;

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final MedicineRiskCheckResponseDto result;

  // minimum: 0
  // maximum: 100
  @JsonKey(name: r'riskScore', required: true, includeIfNull: false)
  final num riskScore;

  @JsonKey(
    name: r'riskLevel',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordDtoRiskLevelEnum.unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordDtoRiskLevelEnum riskLevel;

  @JsonKey(name: r'stale', required: true, includeIfNull: false)
  final bool stale;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordDto &&
          other.checkType == checkType &&
          other.result == result &&
          other.riskScore == riskScore &&
          other.riskLevel == riskLevel &&
          other.stale == stale &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      checkType.hashCode +
      result.hashCode +
      riskScore.hashCode +
      riskLevel.hashCode +
      stale.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory MedicineRiskCheckRecordDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineRiskCheckRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineRiskCheckRecordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineRiskCheckRecordDtoCheckTypeEnum {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'llm')
  llm(r'llm'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordDtoCheckTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum MedicineRiskCheckRecordDtoRiskLevelEnum {
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

  const MedicineRiskCheckRecordDtoRiskLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
