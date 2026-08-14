//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reports_controller_export_clinic_summary_pdf_async_v1201_response_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData {
  /// Returns a new [ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData] instance.
  ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData({
    this.jobId,

    this.pdfBase64,
  });

  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @JsonKey(name: r'pdfBase64', required: false, includeIfNull: false)
  final String? pdfBase64;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData &&
          other.jobId == jobId &&
          other.pdfBase64 == pdfBase64;

  @override
  int get hashCode => jobId.hashCode + pdfBase64.hashCode;

  factory ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseDataFromJson(
    json,
  );

  Map<String, dynamic> toJson() =>
      _$ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseDataToJson(
        this,
      );

  @override
  String toString() {
    return toJson().toString();
  }
}
