// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_metric_dto_direction_direction.dart';
import 'report_metric_dto_kind_kind.dart';
import 'report_metric_dto_status_status.dart';

part 'report_metric_dto.g.dart';

@JsonSerializable()
class ReportMetricDto {
  const ReportMetricDto({
    required this.kind,
    required this.value,
    required this.unit,
    required this.status,
    required this.delta,
    required this.direction,
    required this.sparkline,
  });

  factory ReportMetricDto.fromJson(Map<String, Object?> json) =>
      _$ReportMetricDtoFromJson(json);

  final ReportMetricDtoKindKind kind;
  final String value;
  final String unit;
  final ReportMetricDtoStatusStatus status;
  final String delta;
  final ReportMetricDtoDirectionDirection direction;
  final List<num> sparkline;

  Map<String, Object?> toJson() => _$ReportMetricDtoToJson(this);
}
