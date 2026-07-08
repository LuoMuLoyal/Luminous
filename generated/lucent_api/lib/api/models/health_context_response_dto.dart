// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'health_context_data_dto.dart';

part 'health_context_response_dto.g.dart';

@JsonSerializable()
class HealthContextResponseDto {
  const HealthContextResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory HealthContextResponseDto.fromJson(Map<String, Object?> json) =>
      _$HealthContextResponseDtoFromJson(json);

  /// Result code
  final num code;

  /// Prompt message
  final String message;
  final HealthContextDataDto data;

  Map<String, Object?> toJson() => _$HealthContextResponseDtoToJson(this);
}
