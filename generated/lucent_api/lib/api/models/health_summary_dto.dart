// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'health_summary_dto.g.dart';

@JsonSerializable()
class HealthSummaryDto {
  const HealthSummaryDto({
    required this.total,
    required this.passed,
    required this.failed,
  });

  factory HealthSummaryDto.fromJson(Map<String, Object?> json) =>
      _$HealthSummaryDtoFromJson(json);

  final num total;
  final num passed;
  final num failed;

  Map<String, Object?> toJson() => _$HealthSummaryDtoToJson(this);
}
