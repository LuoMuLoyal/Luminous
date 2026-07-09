// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_explanation_data_dto.dart';

part 'suggestion_explanation_response_dto.g.dart';

@JsonSerializable()
class SuggestionExplanationResponseDto {
  const SuggestionExplanationResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionExplanationResponseDto.fromJson(
    Map<String, Object?> json,
  ) => _$SuggestionExplanationResponseDtoFromJson(json);

  final num code;
  final String message;
  final SuggestionExplanationDataDto data;

  Map<String, Object?> toJson() =>
      _$SuggestionExplanationResponseDtoToJson(this);
}
