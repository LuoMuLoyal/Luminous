// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'today_suggestion_controller_explain_suggestion_async_v1_response_data.g.dart';

@JsonSerializable()
class TodaySuggestionControllerExplainSuggestionAsyncV1ResponseData {
  const TodaySuggestionControllerExplainSuggestionAsyncV1ResponseData({
    this.jobId,
  });

  factory TodaySuggestionControllerExplainSuggestionAsyncV1ResponseData.fromJson(
    Map<String, Object?> json,
  ) => _$TodaySuggestionControllerExplainSuggestionAsyncV1ResponseDataFromJson(
    json,
  );

  final String? jobId;

  Map<String, Object?> toJson() =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1ResponseDataToJson(
        this,
      );
}
