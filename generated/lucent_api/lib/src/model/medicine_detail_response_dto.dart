//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDto {
  /// Returns a new [MedicineDetailResponseDto] instance.
  MedicineDetailResponseDto({
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
    unknownEnumValue:
        MedicineDetailResponseDtoSource_Enum.unknownDefaultOpenApi,
  )
  final MedicineDetailResponseDtoSource_Enum source_;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'subtitle', required: true, includeIfNull: true)
  final String? subtitle;

  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final MedicineDetailResponseDtoDetail detail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseDto &&
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

  factory MedicineDetailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineDetailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDetailResponseDtoSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineDetailResponseDtoSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
