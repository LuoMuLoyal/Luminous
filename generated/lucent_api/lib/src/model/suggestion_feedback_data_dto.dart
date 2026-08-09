//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_feedback_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionFeedbackDataDto {
  /// Returns a new [SuggestionFeedbackDataDto] instance.
  SuggestionFeedbackDataDto({
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
        SuggestionFeedbackDataDtoFeedbackEnum.unknownDefaultOpenApi,
  )
  final SuggestionFeedbackDataDtoFeedbackEnum feedback;

  /// Effect applied by the feedback engine
  @JsonKey(
    name: r'appliedEffect',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        SuggestionFeedbackDataDtoAppliedEffectEnum.unknownDefaultOpenApi,
  )
  final SuggestionFeedbackDataDtoAppliedEffectEnum appliedEffect;

  /// When the suppression expires (if applicable)
  @JsonKey(name: r'expiresAt', required: false, includeIfNull: false)
  final String? expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionFeedbackDataDto &&
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

  factory SuggestionFeedbackDataDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFeedbackDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionFeedbackDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SuggestionFeedbackDataDtoFeedbackEnum {
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

  const SuggestionFeedbackDataDtoFeedbackEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Effect applied by the feedback engine
enum SuggestionFeedbackDataDtoAppliedEffectEnum {
  /// Effect applied by the feedback engine
  @JsonValue(r'boosted_type')
  boostedType(r'boosted_type'),

  /// Effect applied by the feedback engine
  @JsonValue(r'delayed_until')
  delayedUntil(r'delayed_until'),

  /// Effect applied by the feedback engine
  @JsonValue(r'suppressed_type')
  suppressedType(r'suppressed_type'),

  /// Effect applied by the feedback engine
  @JsonValue(r'noted')
  noted(r'noted'),

  /// Effect applied by the feedback engine
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionFeedbackDataDtoAppliedEffectEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
