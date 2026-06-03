//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_search_meta_dto.dart';
import 'package:lucent_openapi/src/model/medicine_search_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_search_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSearchResponseDto {
  /// Returns a new [MedicineSearchResponseDto] instance.
  MedicineSearchResponseDto({
    required this.code,

    required this.message,

    required this.data,

    required this.meta,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final List<MedicineSearchItemDto> data;

  @JsonKey(name: r'meta', required: true, includeIfNull: false)
  final MedicineSearchMetaDto meta;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSearchResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data &&
          other.meta == meta;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + data.hashCode + meta.hashCode;

  factory MedicineSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSearchResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
