// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'humidity_indicator_dto.g.dart';

@JsonSerializable()
class HumidityIndicatorDto {
  const HumidityIndicatorDto({required this.percent});

  factory HumidityIndicatorDto.fromJson(Map<String, Object?> json) =>
      _$HumidityIndicatorDtoFromJson(json);

  final num percent;

  Map<String, Object?> toJson() => _$HumidityIndicatorDtoToJson(this);
}
