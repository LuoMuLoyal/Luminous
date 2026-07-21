// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_analysis_controller_generate_async_v1_response_data.dart';

part 'today_analysis_controller_generate_async_v1_response.g.dart';

@JsonSerializable()
class TodayAnalysisControllerGenerateAsyncV1Response {
  const TodayAnalysisControllerGenerateAsyncV1Response({this.code, this.data});

  factory TodayAnalysisControllerGenerateAsyncV1Response.fromJson(
    Map<String, Object?> json,
  ) => _$TodayAnalysisControllerGenerateAsyncV1ResponseFromJson(json);

  final num? code;
  final TodayAnalysisControllerGenerateAsyncV1ResponseData? data;

  Map<String, Object?> toJson() =>
      _$TodayAnalysisControllerGenerateAsyncV1ResponseToJson(this);
}
