// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'suggestion_explanation_data_dto.g.dart';

@JsonSerializable()
class SuggestionExplanationDataDto {
  const SuggestionExplanationDataDto({
    required this.suggestionId,
    required this.reason,
    required this.boundary,
    required this.aiGenerated,
    this.locale,
  });

  factory SuggestionExplanationDataDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionExplanationDataDtoFromJson(json);

  /// The suggestion ID that was explained
  final String suggestionId;

  /// AI-enhanced or original reason text
  final String reason;

  /// AI-enhanced or original boundary / disclaimer text
  final String boundary;

  /// Whether the AI model was used to generate the explanation
  final bool aiGenerated;

  /// Locale used for the explanation (e.g. "zh-CN", "en")
  final String? locale;

  Map<String, Object?> toJson() => _$SuggestionExplanationDataDtoToJson(this);
}
