// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_analysis_data_dto.dart';

part 'today_analysis_response_dto.g.dart';

@JsonSerializable()
class TodayAnalysisResponseDto {
  const TodayAnalysisResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TodayAnalysisResponseDto.fromJson(Map<String, Object?> json) =>
      _$TodayAnalysisResponseDtoFromJson(json);

  final num code;
  final String message;
  final TodayAnalysisDataDto data;

  Map<String, Object?> toJson() => _$TodayAnalysisResponseDtoToJson(this);
}
