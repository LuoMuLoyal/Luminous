//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_refresh_ready_data_analysis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_refresh_ready_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisRefreshReadyData {
  /// Returns a new [TodayAnalysisRefreshReadyData] instance.
  TodayAnalysisRefreshReadyData({required this.status, required this.analysis});

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'analysis', required: true, includeIfNull: false)
  final TodayAnalysisRefreshReadyDataAnalysis analysis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisRefreshReadyData &&
          other.status == status &&
          other.analysis == analysis;

  @override
  int get hashCode => status.hashCode + analysis.hashCode;

  factory TodayAnalysisRefreshReadyData.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisRefreshReadyDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisRefreshReadyDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
