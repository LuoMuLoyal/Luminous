// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_feedback_dto_feedback_feedback.dart';

part 'suggestion_feedback_dto.g.dart';

@JsonSerializable()
class SuggestionFeedbackDto {
  const SuggestionFeedbackDto({required this.feedback});

  factory SuggestionFeedbackDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionFeedbackDtoFromJson(json);

  /// User feedback for the suggestion
  final SuggestionFeedbackDtoFeedbackFeedback feedback;

  Map<String, Object?> toJson() => _$SuggestionFeedbackDtoToJson(this);
}
