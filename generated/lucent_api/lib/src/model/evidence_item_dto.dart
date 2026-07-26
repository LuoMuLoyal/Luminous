//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'evidence_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EvidenceItemDto {
  /// Returns a new [EvidenceItemDto] instance.
  EvidenceItemDto({
    required this.kind,

    required this.label,

    required this.value,

    this.recordId,

    this.medicineId,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: EvidenceItemDtoKindEnum.unknownDefaultOpenApi,
  )
  final EvidenceItemDtoKindEnum kind;

  /// Human-readable label
  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  /// Human-readable value
  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final String value;

  /// Related record id for navigation
  @JsonKey(name: r'recordId', required: false, includeIfNull: false)
  final Object? recordId;

  /// Related medicine id for navigation
  @JsonKey(name: r'medicineId', required: false, includeIfNull: false)
  final Object? medicineId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenceItemDto &&
          other.kind == kind &&
          other.label == label &&
          other.value == value &&
          other.recordId == recordId &&
          other.medicineId == medicineId;

  @override
  int get hashCode =>
      kind.hashCode +
      label.hashCode +
      value.hashCode +
      recordId.hashCode +
      medicineId.hashCode;

  factory EvidenceItemDto.fromJson(Map<String, dynamic> json) =>
      _$EvidenceItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EvidenceItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EvidenceItemDtoKindEnum {
  @JsonValue(r'record')
  record(r'record'),
  @JsonValue(r'reminder')
  reminder(r'reminder'),
  @JsonValue(r'risk_check')
  riskCheck(r'risk_check'),
  @JsonValue(r'trend')
  trend(r'trend'),
  @JsonValue(r'profile')
  profile(r'profile'),
  @JsonValue(r'baseline')
  baseline(r'baseline'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EvidenceItemDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
