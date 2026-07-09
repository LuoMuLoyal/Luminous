// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_feedback_data_dto.dart';

part 'suggestion_feedback_response_dto.g.dart';

@JsonSerializable()
class SuggestionFeedbackResponseDto {
  const SuggestionFeedbackResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionFeedbackResponseDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionFeedbackResponseDtoFromJson(json);

  final num code;
  final String message;
  final SuggestionFeedbackDataDto data;

  Map<String, Object?> toJson() => _$SuggestionFeedbackResponseDtoToJson(this);
}
