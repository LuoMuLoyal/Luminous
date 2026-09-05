//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_job_response_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_job_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryJobResponse {
  /// Returns a new [ReportSummaryJobResponse] instance.
  ReportSummaryJobResponse({this.jobId, this.result});

  /// Queued report summary job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final ReportSummaryJobResponseResult? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryJobResponse &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory ReportSummaryJobResponse.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryJobResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryJobResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
