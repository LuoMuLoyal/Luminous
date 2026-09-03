//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestion_controller_submit_feedback_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionControllerSubmitFeedbackV1Request {
  /// Returns a new [TodaySuggestionControllerSubmitFeedbackV1Request] instance.
  TodaySuggestionControllerSubmitFeedbackV1Request({required this.feedback});

  /// User feedback for the suggestion
  @JsonKey(
    name: r'feedback',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        TodaySuggestionControllerSubmitFeedbackV1RequestFeedbackEnum
            .unknownDefaultOpenApi,
  )
  final TodaySuggestionControllerSubmitFeedbackV1RequestFeedbackEnum feedback;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionControllerSubmitFeedbackV1Request &&
          other.feedback == feedback;

  @override
  int get hashCode => feedback.hashCode;

  factory TodaySuggestionControllerSubmitFeedbackV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$TodaySuggestionControllerSubmitFeedbackV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodaySuggestionControllerSubmitFeedbackV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// User feedback for the suggestion
enum TodaySuggestionControllerSubmitFeedbackV1RequestFeedbackEnum {
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

  const TodaySuggestionControllerSubmitFeedbackV1RequestFeedbackEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
