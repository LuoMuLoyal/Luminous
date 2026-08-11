//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_analysis_stream_summary_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayAnalysisStreamSummaryDto {
  /// Returns a new [TodayAnalysisStreamSummaryDto] instance.
  TodayAnalysisStreamSummaryDto({required this.summary});

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayAnalysisStreamSummaryDto && other.summary == summary;

  @override
  int get hashCode => summary.hashCode;

  factory TodayAnalysisStreamSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$TodayAnalysisStreamSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAnalysisStreamSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
