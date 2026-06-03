//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_detail_data_dto_detail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailDataDto {
  /// Returns a new [MedicineDetailDataDto] instance.
  MedicineDetailDataDto({
    required this.id,

    required this.source_,

    required this.name,

    required this.subtitle,

    required this.detail,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineDetailDataDtoSource_Enum.unknownDefaultOpenApi,
  )
  final MedicineDetailDataDtoSource_Enum source_;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'subtitle', required: true, includeIfNull: true)
  final Object? subtitle;

  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final MedicineDetailDataDtoDetail detail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailDataDto &&
          other.id == id &&
          other.source_ == source_ &&
          other.name == name &&
          other.subtitle == subtitle &&
          other.detail == detail;

  @override
  int get hashCode =>
      id.hashCode +
      source_.hashCode +
      name.hashCode +
      (subtitle == null ? 0 : subtitle.hashCode) +
      detail.hashCode;

  factory MedicineDetailDataDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineDetailDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDetailDataDtoSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineDetailDataDtoSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
