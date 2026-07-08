// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'temperature_indicator_dto.g.dart';

@JsonSerializable()
class TemperatureIndicatorDto {
  const TemperatureIndicatorDto({
    required this.celsius,
    required this.feelsLike,
  });

  factory TemperatureIndicatorDto.fromJson(Map<String, Object?> json) =>
      _$TemperatureIndicatorDtoFromJson(json);

  final num celsius;
  final num feelsLike;

  Map<String, Object?> toJson() => _$TemperatureIndicatorDtoToJson(this);
}
