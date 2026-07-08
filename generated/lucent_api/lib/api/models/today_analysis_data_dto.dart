// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_analysis_bullet_dto.dart';

part 'today_analysis_data_dto.g.dart';

@JsonSerializable()
class TodayAnalysisDataDto {
  const TodayAnalysisDataDto({
    required this.date,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.action,
    required this.confidenceNote,
  });

  factory TodayAnalysisDataDto.fromJson(Map<String, Object?> json) =>
      _$TodayAnalysisDataDtoFromJson(json);

  final String date;
  final String generatedAt;
  final String summary;
  final List<TodayAnalysisBulletDto> bullets;
  final String actionLabel;
  final String action;
  final String confidenceNote;

  Map<String, Object?> toJson() => _$TodayAnalysisDataDtoToJson(this);
}
