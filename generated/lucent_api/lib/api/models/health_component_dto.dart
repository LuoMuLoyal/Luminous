// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'health_component_status.dart';

part 'health_component_dto.g.dart';

@JsonSerializable()
class HealthComponentDto {
  const HealthComponentDto({
    required this.name,
    required this.status,
    required this.critical,
    required this.durationMs,
    required this.error,
    required this.details,
  });

  factory HealthComponentDto.fromJson(Map<String, Object?> json) =>
      _$HealthComponentDtoFromJson(json);

  final String name;
  final HealthComponentStatus status;
  final bool critical;
  final num durationMs;
  final String? error;
  final dynamic details;

  Map<String, Object?> toJson() => _$HealthComponentDtoToJson(this);
}
