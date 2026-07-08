// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'air_quality_indicator_dto.dart';
import 'environment_data_source.dart';
import 'humidity_indicator_dto.dart';
import 'pollen_indicator_dto.dart';
import 'temperature_indicator_dto.dart';
import 'uv_indicator_dto.dart';

part 'environment_snapshot_dto.g.dart';

@JsonSerializable()
class EnvironmentSnapshotDto {
  const EnvironmentSnapshotDto({
    required this.dataSource,
    required this.updatedAt,
    required this.regionHint,
    required this.pollen,
    required this.uv,
    required this.airQuality,
    required this.temperature,
    required this.humidity,
  });

  factory EnvironmentSnapshotDto.fromJson(Map<String, Object?> json) =>
      _$EnvironmentSnapshotDtoFromJson(json);

  final EnvironmentDataSource dataSource;

  /// ISO-8601 timestamp for the static reference data refresh.
  final String updatedAt;
  final String? regionHint;
  final PollenIndicatorDto pollen;
  final UvIndicatorDto uv;
  final AirQualityIndicatorDto airQuality;
  final TemperatureIndicatorDto temperature;
  final HumidityIndicatorDto humidity;

  Map<String, Object?> toJson() => _$EnvironmentSnapshotDtoToJson(this);
}
