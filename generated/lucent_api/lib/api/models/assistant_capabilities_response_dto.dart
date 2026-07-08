// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_capabilities_data_dto.dart';

part 'assistant_capabilities_response_dto.g.dart';

@JsonSerializable()
class AssistantCapabilitiesResponseDto {
  const AssistantCapabilitiesResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AssistantCapabilitiesResponseDto.fromJson(
    Map<String, Object?> json,
  ) => _$AssistantCapabilitiesResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final AssistantCapabilitiesDataDto data;

  Map<String, Object?> toJson() =>
      _$AssistantCapabilitiesResponseDtoToJson(this);
}
