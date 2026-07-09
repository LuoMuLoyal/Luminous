// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_feedback_data_dto_applied_effect_applied_effect.dart';
import 'suggestion_feedback_data_dto_feedback_feedback.dart';

part 'suggestion_feedback_data_dto.g.dart';

@JsonSerializable()
class SuggestionFeedbackDataDto {
  const SuggestionFeedbackDataDto({
    required this.suggestionId,
    required this.feedback,
    required this.appliedEffect,
    this.expiresAt,
  });

  factory SuggestionFeedbackDataDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionFeedbackDataDtoFromJson(json);

  final String suggestionId;
  final SuggestionFeedbackDataDtoFeedbackFeedback feedback;

  /// Effect applied by the feedback engine
  final SuggestionFeedbackDataDtoAppliedEffectAppliedEffect appliedEffect;

  /// When the suppression expires (if applicable)
  final String? expiresAt;

  Map<String, Object?> toJson() => _$SuggestionFeedbackDataDtoToJson(this);
}
