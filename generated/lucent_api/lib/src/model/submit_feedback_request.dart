//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'submit_feedback_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubmitFeedbackRequest {
  /// Returns a new [SubmitFeedbackRequest] instance.
  SubmitFeedbackRequest({required this.feedback});

  /// User feedback for the suggestion
  @JsonKey(
    name: r'feedback',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SubmitFeedbackRequestFeedbackEnum.unknownDefaultOpenApi,
  )
  final SubmitFeedbackRequestFeedbackEnum feedback;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitFeedbackRequest && other.feedback == feedback;

  @override
  int get hashCode => feedback.hashCode;

  factory SubmitFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitFeedbackRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitFeedbackRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User feedback for the suggestion
enum SubmitFeedbackRequestFeedbackEnum {
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

  const SubmitFeedbackRequestFeedbackEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
