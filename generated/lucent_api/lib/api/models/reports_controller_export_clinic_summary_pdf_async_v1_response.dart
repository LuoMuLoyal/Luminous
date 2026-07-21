// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reports_controller_export_clinic_summary_pdf_async_v1_response_data.dart';

part 'reports_controller_export_clinic_summary_pdf_async_v1_response.g.dart';

@JsonSerializable()
class ReportsControllerExportClinicSummaryPdfAsyncV1Response {
  const ReportsControllerExportClinicSummaryPdfAsyncV1Response({
    this.code,
    this.data,
  });

  factory ReportsControllerExportClinicSummaryPdfAsyncV1Response.fromJson(
    Map<String, Object?> json,
  ) => _$ReportsControllerExportClinicSummaryPdfAsyncV1ResponseFromJson(json);

  final num? code;
  final ReportsControllerExportClinicSummaryPdfAsyncV1ResponseData? data;

  Map<String, Object?> toJson() =>
      _$ReportsControllerExportClinicSummaryPdfAsyncV1ResponseToJson(this);
}
