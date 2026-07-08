// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_summary_bullet_dto_kind_kind.dart';

part 'report_summary_bullet_dto.g.dart';

@JsonSerializable()
class ReportSummaryBulletDto {
  const ReportSummaryBulletDto({required this.kind, required this.text});

  factory ReportSummaryBulletDto.fromJson(Map<String, Object?> json) =>
      _$ReportSummaryBulletDtoFromJson(json);

  final ReportSummaryBulletDtoKindKind kind;
  final String text;

  Map<String, Object?> toJson() => _$ReportSummaryBulletDtoToJson(this);
}
