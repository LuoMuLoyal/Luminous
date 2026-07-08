// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'uv_level.dart';

part 'uv_indicator_dto.g.dart';

@JsonSerializable()
class UvIndicatorDto {
  const UvIndicatorDto({required this.indexField, required this.level});

  factory UvIndicatorDto.fromJson(Map<String, Object?> json) =>
      _$UvIndicatorDtoFromJson(json);

  @JsonKey(name: 'index')
  final num indexField;
  final UvLevel level;

  Map<String, Object?> toJson() => _$UvIndicatorDtoToJson(this);
}
