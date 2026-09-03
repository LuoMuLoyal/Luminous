//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_risk_check_records_response_dto_static_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_dto_static.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseDtoStatic {
  /// Returns a new [MedicineRiskCheckRecordsResponseDtoStatic] instance.
  MedicineRiskCheckRecordsResponseDtoStatic({
    required this.checkType,

    required this.result,

    required this.riskScore,

    required this.riskLevel,

    required this.stale,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Type of risk check.
  @JsonKey(
    name: r'checkType',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum
        .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum checkType;

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final MedicineRiskCheckRecordsResponseDtoStaticResult result;

  /// Persisted risk score (0-100).
  @JsonKey(name: r'riskScore', required: true, includeIfNull: false)
  final num riskScore;

  /// Persisted risk level.
  @JsonKey(
    name: r'riskLevel',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum
        .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum riskLevel;

  /// Whether the record is stale.
  @JsonKey(name: r'stale', required: true, includeIfNull: false)
  final bool stale;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseDtoStatic &&
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

  factory MedicineRiskCheckRecordsResponseDtoStatic.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineRiskCheckRecordsResponseDtoStaticFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseDtoStaticToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Type of risk check.
enum MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'llm')
  llm(r'llm'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Persisted risk level.
enum MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum {
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

  const MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
