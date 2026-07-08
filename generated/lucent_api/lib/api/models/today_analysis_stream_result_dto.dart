// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_analysis_stream_result_dto_event_event.dart';

part 'today_analysis_stream_result_dto.g.dart';

@JsonSerializable()
class TodayAnalysisStreamResultDto {
  const TodayAnalysisStreamResultDto({required this.event, required this.data});

  factory TodayAnalysisStreamResultDto.fromJson(Map<String, Object?> json) =>
      _$TodayAnalysisStreamResultDtoFromJson(json);

  final TodayAnalysisStreamResultDtoEventEvent event;

  /// SSE payload object. event=summary => { summary }, event=result => TodayAnalysisDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  final dynamic data;

  Map<String, Object?> toJson() => _$TodayAnalysisStreamResultDtoToJson(this);
}
