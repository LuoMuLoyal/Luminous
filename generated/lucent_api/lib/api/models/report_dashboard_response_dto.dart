// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_dashboard_data_dto.dart';

part 'report_dashboard_response_dto.g.dart';

@JsonSerializable()
class ReportDashboardResponseDto {
  const ReportDashboardResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ReportDashboardResponseDto.fromJson(Map<String, Object?> json) =>
      _$ReportDashboardResponseDtoFromJson(json);

  final num code;
  final String message;
  final ReportDashboardDataDto data;

  Map<String, Object?> toJson() => _$ReportDashboardResponseDtoToJson(this);
}
