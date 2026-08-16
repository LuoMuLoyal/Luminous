//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_feedback_data_dto.dart';
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
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SuggestionFeedbackDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionFeedbackResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory SuggestionFeedbackResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionFeedbackResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionFeedbackResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
