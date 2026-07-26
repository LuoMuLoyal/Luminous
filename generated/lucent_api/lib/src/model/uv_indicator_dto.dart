//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/uv_level.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uv_indicator_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UvIndicatorDto {
  /// Returns a new [UvIndicatorDto] instance.
  UvIndicatorDto({required this.index, required this.level});

  @JsonKey(name: r'index', required: true, includeIfNull: false)
  final num index;

  @JsonKey(
    name: r'level',
    required: true,
    includeIfNull: false,
    unknownEnumValue: UvLevel.unknownDefaultOpenApi,
  )
  final UvLevel level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UvIndicatorDto && other.index == index && other.level == level;

  @override
  int get hashCode => index.hashCode + level.hashCode;

  factory UvIndicatorDto.fromJson(Map<String, dynamic> json) =>
      _$UvIndicatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UvIndicatorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
