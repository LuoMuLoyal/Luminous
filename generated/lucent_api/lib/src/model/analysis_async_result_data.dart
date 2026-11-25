//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/analysis_async_result_data_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analysis_async_result_data.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalysisAsyncResultData {
  /// Returns a new [AnalysisAsyncResultData] instance.
  AnalysisAsyncResultData({required this.result});

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final AnalysisAsyncResultDataResult result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisAsyncResultData && other.result == result;

  @override
  int get hashCode => result.hashCode;

  factory AnalysisAsyncResultData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisAsyncResultDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisAsyncResultDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
