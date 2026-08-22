//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_explanation_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionExplanationResponseDto {
  /// Returns a new [SuggestionExplanationResponseDto] instance.
  SuggestionExplanationResponseDto({
    required this.suggestionId,

    required this.reason,

    required this.boundary,

    required this.aiGenerated,

    this.locale,
  });

  /// The suggestion ID that was explained
  @JsonKey(name: r'suggestionId', required: true, includeIfNull: false)
  final String suggestionId;

  /// AI-enhanced or original reason text
  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  /// AI-enhanced or original boundary / disclaimer text
  @JsonKey(name: r'boundary', required: true, includeIfNull: false)
  final String boundary;

  /// Whether the AI model was used to generate the explanation
  @JsonKey(name: r'aiGenerated', required: true, includeIfNull: false)
  final bool aiGenerated;

  /// Locale used for the explanation (e.g. \"zh-CN\", \"en\")
  @JsonKey(name: r'locale', required: false, includeIfNull: false)
  final String? locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionExplanationResponseDto &&
          other.suggestionId == suggestionId &&
          other.reason == reason &&
          other.boundary == boundary &&
          other.aiGenerated == aiGenerated &&
          other.locale == locale;

  @override
  int get hashCode =>
      suggestionId.hashCode +
      reason.hashCode +
      boundary.hashCode +
      aiGenerated.hashCode +
      locale.hashCode;

  factory SuggestionExplanationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$SuggestionExplanationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SuggestionExplanationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
