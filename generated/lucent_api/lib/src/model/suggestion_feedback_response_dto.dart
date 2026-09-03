//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_feedback_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionFeedbackResponseDto {
  /// Returns a new [SuggestionFeedbackResponseDto] instance.
  SuggestionFeedbackResponseDto({
    required this.suggestionId,

    required this.feedback,

    required this.appliedEffect,

    this.expiresAt,
  });

  @JsonKey(name: r'suggestionId', required: true, includeIfNull: false)
  final String suggestionId;

  @JsonKey(
    name: r'feedback',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionFeedbackResponseDtoFeedbackEnum.unknownDefaultOpenApi,
  )
  final SuggestionFeedbackResponseDtoFeedbackEnum feedback;

  /// Effect applied by the feedback engine
  @JsonKey(
    name: r'appliedEffect',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionFeedbackResponseDtoAppliedEffectEnum.unknownDefaultOpenApi,
  )
  final SuggestionFeedbackResponseDtoAppliedEffectEnum appliedEffect;

  /// When the suppression expires (if applicable)
  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final String? expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionFeedbackResponseDto &&
          other.suggestionId == suggestionId &&
          other.feedback == feedback &&
          other.appliedEffect == appliedEffect &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode =>
      suggestionId.hashCode +
      feedback.hashCode +
      appliedEffect.hashCode +
      expiresAt.hashCode;

  factory SuggestionFeedbackResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFeedbackResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionFeedbackResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SuggestionFeedbackResponseDtoFeedbackEnum {
  @JsonValue(r'accepted')
  accepted(r'accepted'),
  @JsonValue(r'later')
  later(r'later'),
  @JsonValue(r'not_applicable')
  notApplicable(r'not_applicable'),
  @JsonValue(r'suppress')
  suppress(r'suppress'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionFeedbackResponseDtoFeedbackEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Effect applied by the feedback engine
enum SuggestionFeedbackResponseDtoAppliedEffectEnum {
  @JsonValue(r'boosted_type')
  boostedType(r'boosted_type'),
  @JsonValue(r'delayed_until')
  delayedUntil(r'delayed_until'),
  @JsonValue(r'suppressed_type')
  suppressedType(r'suppressed_type'),
  @JsonValue(r'noted')
  noted(r'noted'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionFeedbackResponseDtoAppliedEffectEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
