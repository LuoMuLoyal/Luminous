// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_summary_stream_result_dto_event_event.dart';

part 'report_summary_stream_result_dto.g.dart';

@JsonSerializable()
class ReportSummaryStreamResultDto {
  const ReportSummaryStreamResultDto({required this.event, required this.data});

  factory ReportSummaryStreamResultDto.fromJson(Map<String, Object?> json) =>
      _$ReportSummaryStreamResultDtoFromJson(json);

  final ReportSummaryStreamResultDtoEventEvent event;

  /// SSE payload object. event=summary => { summary }, event=result => ReportSummaryDataDto-like object, event=error => { message, code?, statusCode? }, event=done => {}.
  final dynamic data;

  Map<String, Object?> toJson() => _$ReportSummaryStreamResultDtoToJson(this);
}
