// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_trend_dto_kind_kind.dart';

part 'report_trend_dto.g.dart';

@JsonSerializable()
class ReportTrendDto {
  const ReportTrendDto({
    required this.kind,
    required this.unit,
    required this.currentValue,
    required this.valuesField,
  });

  factory ReportTrendDto.fromJson(Map<String, Object?> json) =>
      _$ReportTrendDtoFromJson(json);

  final ReportTrendDtoKindKind kind;
  final String unit;
  final String currentValue;
  @JsonKey(name: 'values')
  final List<num> valuesField;

  Map<String, Object?> toJson() => _$ReportTrendDtoToJson(this);
}
