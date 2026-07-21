// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reports_controller_export_clinic_summary_pdf_async_v1_response_data.g.dart';

@JsonSerializable()
class ReportsControllerExportClinicSummaryPdfAsyncV1ResponseData {
  const ReportsControllerExportClinicSummaryPdfAsyncV1ResponseData({
    this.jobId,
  });

  factory ReportsControllerExportClinicSummaryPdfAsyncV1ResponseData.fromJson(
    Map<String, Object?> json,
  ) => _$ReportsControllerExportClinicSummaryPdfAsyncV1ResponseDataFromJson(
    json,
  );

  final String? jobId;

  Map<String, Object?> toJson() =>
      _$ReportsControllerExportClinicSummaryPdfAsyncV1ResponseDataToJson(this);
}
