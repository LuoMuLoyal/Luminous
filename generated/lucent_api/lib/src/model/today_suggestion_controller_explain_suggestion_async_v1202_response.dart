//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_suggestion_controller_explain_suggestion_async_v1202_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestion_controller_explain_suggestion_async_v1202_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionControllerExplainSuggestionAsyncV1202Response {
  /// Returns a new [TodaySuggestionControllerExplainSuggestionAsyncV1202Response] instance.
  TodaySuggestionControllerExplainSuggestionAsyncV1202Response({
    this.code,

    this.data,
  });

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseData? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionControllerExplainSuggestionAsyncV1202Response &&
          other.code == code &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + data.hashCode;

  factory TodaySuggestionControllerExplainSuggestionAsyncV1202Response.fromJson(
    Map<String, dynamic> json,
  ) => _$TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseFromJson(
    json,
  );

  Map<String, dynamic> toJson() =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1202ResponseToJson(
        this,
      );

  @override
  String toString() {
    return toJson().toString();
  }
}
