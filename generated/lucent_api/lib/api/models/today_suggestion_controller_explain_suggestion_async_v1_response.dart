// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_suggestion_controller_explain_suggestion_async_v1_response_data.dart';

part 'today_suggestion_controller_explain_suggestion_async_v1_response.g.dart';

@JsonSerializable()
class TodaySuggestionControllerExplainSuggestionAsyncV1Response {
  const TodaySuggestionControllerExplainSuggestionAsyncV1Response({
    this.code,
    this.data,
  });

  factory TodaySuggestionControllerExplainSuggestionAsyncV1Response.fromJson(
    Map<String, Object?> json,
  ) =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1ResponseFromJson(json);

  final num? code;
  final TodaySuggestionControllerExplainSuggestionAsyncV1ResponseData? data;

  Map<String, Object?> toJson() =>
      _$TodaySuggestionControllerExplainSuggestionAsyncV1ResponseToJson(this);
}
