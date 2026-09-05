//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_refresh_pending_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisRefreshPendingData {
  /// Returns a new [TodayAnalysisRefreshPendingData] instance.
  TodayAnalysisRefreshPendingData({required this.status, required this.jobId});

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'jobId', required: true, includeIfNull: false)
  final String jobId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisRefreshPendingData &&
          other.status == status &&
          other.jobId == jobId;

  @override
  int get hashCode => status.hashCode + jobId.hashCode;

  factory TodayAnalysisRefreshPendingData.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisRefreshPendingDataFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisRefreshPendingDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
