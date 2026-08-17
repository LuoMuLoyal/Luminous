//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/today_analysis_async_result_data_dto_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_async_result_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisAsyncResultDataDto {
  /// Returns a new [TodayAnalysisAsyncResultDataDto] instance.
  TodayAnalysisAsyncResultDataDto({required this.result});

  @JsonKey(name: r'result', required: true, includeIfNull: false)
  final TodayAnalysisAsyncResultDataDtoResult result;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisAsyncResultDataDto && other.result == result;

  @override
  int get hashCode => result.hashCode;

  factory TodayAnalysisAsyncResultDataDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisAsyncResultDataDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayAnalysisAsyncResultDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
