// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_pattern_dto_kind_kind.dart';
import 'report_pattern_dto_status_status.dart';

part 'report_pattern_dto.g.dart';

@JsonSerializable()
class ReportPatternDto {
  const ReportPatternDto({
    required this.kind,
    required this.title,
    required this.status,
    required this.body,
    required this.sparkline,
  });

  factory ReportPatternDto.fromJson(Map<String, Object?> json) =>
      _$ReportPatternDtoFromJson(json);

  final ReportPatternDtoKindKind kind;
  final String title;
  final ReportPatternDtoStatusStatus status;
  final String body;
  final List<num> sparkline;

  Map<String, Object?> toJson() => _$ReportPatternDtoToJson(this);
}
