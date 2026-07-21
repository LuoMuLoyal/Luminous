// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reports_controller_generate_summary_async_v1_response_data.g.dart';

@JsonSerializable()
class ReportsControllerGenerateSummaryAsyncV1ResponseData {
  const ReportsControllerGenerateSummaryAsyncV1ResponseData({this.jobId});

  factory ReportsControllerGenerateSummaryAsyncV1ResponseData.fromJson(
    Map<String, Object?> json,
  ) => _$ReportsControllerGenerateSummaryAsyncV1ResponseDataFromJson(json);

  final String? jobId;

  Map<String, Object?> toJson() =>
      _$ReportsControllerGenerateSummaryAsyncV1ResponseDataToJson(this);
}
