// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'health_app_info_dto.dart';
import 'health_component_dto.dart';
import 'health_overall_status.dart';
import 'health_probe_type.dart';
import 'health_summary_dto.dart';

part 'health_probe_dto.g.dart';

@JsonSerializable()
class HealthProbeDto {
  const HealthProbeDto({
    required this.probe,
    required this.status,
    required this.checkedAt,
    required this.app,
    required this.summary,
    required this.components,
  });

  factory HealthProbeDto.fromJson(Map<String, Object?> json) =>
      _$HealthProbeDtoFromJson(json);

  final HealthProbeType probe;
  final HealthOverallStatus status;
  final String checkedAt;
  final HealthAppInfoDto app;
  final HealthSummaryDto summary;
  final List<HealthComponentDto> components;

  Map<String, Object?> toJson() => _$HealthProbeDtoToJson(this);
}
