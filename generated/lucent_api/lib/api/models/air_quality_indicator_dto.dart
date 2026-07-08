// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'air_quality_level.dart';

part 'air_quality_indicator_dto.g.dart';

@JsonSerializable()
class AirQualityIndicatorDto {
  const AirQualityIndicatorDto({
    required this.aqi,
    required this.level,
    required this.primaryPollutant,
  });

  factory AirQualityIndicatorDto.fromJson(Map<String, Object?> json) =>
      _$AirQualityIndicatorDtoFromJson(json);

  final num aqi;
  final AirQualityLevel level;
  final String? primaryPollutant;

  Map<String, Object?> toJson() => _$AirQualityIndicatorDtoToJson(this);
}
