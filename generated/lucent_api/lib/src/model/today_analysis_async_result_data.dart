//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_async_result_data_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_result_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResultData {
  /// Returns a new [TodayAnalysisAsyncResultData] instance.
  TodayAnalysisAsyncResultData({required this.result});

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final TodayAnalysisAsyncResultDataResult result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResultData && other.result == result;

  @override
  int get hashCode => result.hashCode;

  factory TodayAnalysisAsyncResultData.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncResultDataFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisAsyncResultDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
