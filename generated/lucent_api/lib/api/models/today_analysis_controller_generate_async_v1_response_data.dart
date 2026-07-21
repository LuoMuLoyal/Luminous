// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_controller_generate_async_v1_response_data.g.dart';

@JsonSerializable()
class TodayAnalysisControllerGenerateAsyncV1ResponseData {
  const TodayAnalysisControllerGenerateAsyncV1ResponseData({this.jobId});

  factory TodayAnalysisControllerGenerateAsyncV1ResponseData.fromJson(
    Map<String, Object?> json,
  ) => _$TodayAnalysisControllerGenerateAsyncV1ResponseDataFromJson(json);

  final String? jobId;

  Map<String, Object?> toJson() =>
      _$TodayAnalysisControllerGenerateAsyncV1ResponseDataToJson(this);
}
