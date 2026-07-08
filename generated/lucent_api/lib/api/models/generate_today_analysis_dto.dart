// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'generate_today_analysis_dto.g.dart';

@JsonSerializable()
class GenerateTodayAnalysisDto {
  const GenerateTodayAnalysisDto({this.date});

  factory GenerateTodayAnalysisDto.fromJson(Map<String, Object?> json) =>
      _$GenerateTodayAnalysisDtoFromJson(json);

  /// Target date in YYYY-MM-DD format. Defaults to backend current day when omitted.
  final String? date;

  Map<String, Object?> toJson() => _$GenerateTodayAnalysisDtoToJson(this);
}
