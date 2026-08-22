//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'clinic_summary_export_async_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ClinicSummaryExportAsyncResponseDto {
  /// Returns a new [ClinicSummaryExportAsyncResponseDto] instance.
  ClinicSummaryExportAsyncResponseDto({this.jobId, this.pdfBase64});

  /// Queued PDF export job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  /// Base64 PDF when the export is processed inline.
  @JsonKey(name: r'pdfBase64', required: false, includeIfNull: false)
  final String? pdfBase64;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicSummaryExportAsyncResponseDto &&
          other.jobId == jobId &&
          other.pdfBase64 == pdfBase64;

  @override
  int get hashCode => jobId.hashCode + pdfBase64.hashCode;

  factory ClinicSummaryExportAsyncResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ClinicSummaryExportAsyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ClinicSummaryExportAsyncResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
