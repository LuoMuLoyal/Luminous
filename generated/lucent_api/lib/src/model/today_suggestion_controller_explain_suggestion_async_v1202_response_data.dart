//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestion_controller_explain_suggestion_async_v1202_response_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData {
  /// Returns a new [TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData] instance.
  TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData({
    this.jobId,
  });

  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData &&
          other.jobId == jobId;

  @override
  int get hashCode => jobId.hashCode;

  factory TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseDataFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseDataToJson(
        this,
      );

  @override
  String toString() {
    return toJson().toString();
  }
}
