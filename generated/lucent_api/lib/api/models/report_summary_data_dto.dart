// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_summary_bullet_dto.dart';
import 'report_summary_data_dto_range_range.dart';

part 'report_summary_data_dto.g.dart';

@JsonSerializable()
class ReportSummaryDataDto {
  const ReportSummaryDataDto({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.action,
    required this.confidenceNote,
  });

  factory ReportSummaryDataDto.fromJson(Map<String, Object?> json) =>
      _$ReportSummaryDataDtoFromJson(json);

  final ReportSummaryDataDtoRangeRange range;
  final String startDate;
  final String endDate;
  final String generatedAt;
  final String summary;
  final List<ReportSummaryBulletDto> bullets;
  final String actionLabel;
  final String action;
  final String confidenceNote;

  Map<String, Object?> toJson() => _$ReportSummaryDataDtoToJson(this);
}
