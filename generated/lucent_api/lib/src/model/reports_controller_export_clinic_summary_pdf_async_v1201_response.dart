//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reports_controller_export_clinic_summary_pdf_async_v1201_response_data.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reports_controller_export_clinic_summary_pdf_async_v1201_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportsControllerExportClinicSummaryPdfAsyncV1201Response {
  /// Returns a new [ReportsControllerExportClinicSummaryPdfAsyncV1201Response] instance.
  ReportsControllerExportClinicSummaryPdfAsyncV1201Response({
    this.code,

    this.data,
  });

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final num? code;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseData? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportsControllerExportClinicSummaryPdfAsyncV1201Response &&
          other.code == code &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + data.hashCode;

  factory ReportsControllerExportClinicSummaryPdfAsyncV1201Response.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportsControllerExportClinicSummaryPdfAsyncV1201ResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
