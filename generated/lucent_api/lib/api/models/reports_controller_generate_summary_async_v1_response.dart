// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reports_controller_generate_summary_async_v1_response_data.dart';

part 'reports_controller_generate_summary_async_v1_response.g.dart';

@JsonSerializable()
class ReportsControllerGenerateSummaryAsyncV1Response {
  const ReportsControllerGenerateSummaryAsyncV1Response({this.code, this.data});

  factory ReportsControllerGenerateSummaryAsyncV1Response.fromJson(
    Map<String, Object?> json,
  ) => _$ReportsControllerGenerateSummaryAsyncV1ResponseFromJson(json);

  final num? code;
  final ReportsControllerGenerateSummaryAsyncV1ResponseData? data;

  Map<String, Object?> toJson() =>
      _$ReportsControllerGenerateSummaryAsyncV1ResponseToJson(this);
}
