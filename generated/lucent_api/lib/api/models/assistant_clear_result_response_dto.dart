// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assistant_clear_result_data_dto.dart';

part 'assistant_clear_result_response_dto.g.dart';

@JsonSerializable()
class AssistantClearResultResponseDto {
  const AssistantClearResultResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AssistantClearResultResponseDto.fromJson(Map<String, Object?> json) =>
      _$AssistantClearResultResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final AssistantClearResultDataDto data;

  Map<String, Object?> toJson() =>
      _$AssistantClearResultResponseDtoToJson(this);
}
