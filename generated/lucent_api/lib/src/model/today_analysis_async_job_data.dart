//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_job_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncJobData {
  /// Returns a new [TodayAnalysisAsyncJobData] instance.
  TodayAnalysisAsyncJobData({required this.jobId});

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncJobData && other.jobId == jobId;

  @override
  int get hashCode => jobId.hashCode;

  factory TodayAnalysisAsyncJobData.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncJobDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisAsyncJobDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
