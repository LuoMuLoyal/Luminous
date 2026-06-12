//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'generate_today_analysis_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateTodayAnalysisDto {
  /// Returns a new [GenerateTodayAnalysisDto] instance.
  GenerateTodayAnalysisDto({this.date});

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateTodayAnalysisDto && other.date == date;

  @override
  int get hashCode => date.hashCode;

  factory GenerateTodayAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateTodayAnalysisDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateTodayAnalysisDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
