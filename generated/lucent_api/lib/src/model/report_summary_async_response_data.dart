//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_async_response_data_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_async_response_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryAsyncResponseData {
  /// Returns a new [ReportSummaryAsyncResponseData] instance.
  ReportSummaryAsyncResponseData({this.jobId, this.result});

  /// Queued report summary job identifier.
  @JsonKey(name: r'jobId', required: false, includeIfNull: false)
  final String? jobId;

  @JsonKey(name: r'result', required: false, includeIfNull: false)
  final ReportSummaryAsyncResponseDataResult? result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryAsyncResponseData &&
          other.jobId == jobId &&
          other.result == result;

  @override
  int get hashCode => jobId.hashCode + result.hashCode;

  factory ReportSummaryAsyncResponseData.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryAsyncResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSummaryAsyncResponseDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
