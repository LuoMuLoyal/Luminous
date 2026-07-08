// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'health_probe_dto.dart';

part 'health_response_dto.g.dart';

@JsonSerializable()
class HealthResponseDto {
  const HealthResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory HealthResponseDto.fromJson(Map<String, Object?> json) =>
      _$HealthResponseDtoFromJson(json);

  final num code;
  final String message;
  final HealthProbeDto data;

  Map<String, Object?> toJson() => _$HealthResponseDtoToJson(this);
}
