//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_feedback_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionFeedbackDto {
  /// Returns a new [SuggestionFeedbackDto] instance.
  SuggestionFeedbackDto({required this.feedback});

  /// User feedback for the suggestion
  @JsonKey(
    name: r'feedback',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SuggestionFeedbackDtoFeedbackEnum.unknownDefaultOpenApi,
  )
  final SuggestionFeedbackDtoFeedbackEnum feedback;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionFeedbackDto && other.feedback == feedback;

  @override
  int get hashCode => feedback.hashCode;

  factory SuggestionFeedbackDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFeedbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionFeedbackDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User feedback for the suggestion
enum SuggestionFeedbackDtoFeedbackEnum {
  /// User feedback for the suggestion
  @JsonValue(r'accepted')
  accepted(r'accepted'),

  /// User feedback for the suggestion
  @JsonValue(r'later')
  later(r'later'),

  /// User feedback for the suggestion
  @JsonValue(r'not_applicable')
  notApplicable(r'not_applicable'),

  /// User feedback for the suggestion
  @JsonValue(r'suppress')
  suppress(r'suppress'),

  /// User feedback for the suggestion
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SuggestionFeedbackDtoFeedbackEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
