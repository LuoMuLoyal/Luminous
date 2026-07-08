// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'health_app_info_dto.g.dart';

@JsonSerializable()
class HealthAppInfoDto {
  const HealthAppInfoDto({
    required this.name,
    required this.env,
    required this.pid,
    required this.uptimeSeconds,
    required this.memoryRssBytes,
    required this.memoryHeapUsedBytes,
  });

  factory HealthAppInfoDto.fromJson(Map<String, Object?> json) =>
      _$HealthAppInfoDtoFromJson(json);

  final String name;
  final String env;
  final num pid;
  final num uptimeSeconds;
  final num memoryRssBytes;
  final num memoryHeapUsedBytes;

  Map<String, Object?> toJson() => _$HealthAppInfoDtoToJson(this);
}
