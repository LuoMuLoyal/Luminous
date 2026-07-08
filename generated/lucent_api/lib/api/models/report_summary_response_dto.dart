// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_summary_data_dto.dart';

part 'report_summary_response_dto.g.dart';

@JsonSerializable()
class ReportSummaryResponseDto {
  const ReportSummaryResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ReportSummaryResponseDto.fromJson(Map<String, Object?> json) =>
      _$ReportSummaryResponseDtoFromJson(json);

  final num code;
  final String message;
  final ReportSummaryDataDto data;

  Map<String, Object?> toJson() => _$ReportSummaryResponseDtoToJson(this);
}
