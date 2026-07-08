// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'report_finding_dto_kind_kind.dart';

part 'report_finding_dto.g.dart';

@JsonSerializable()
class ReportFindingDto {
  const ReportFindingDto({
    required this.kind,
    required this.title,
    required this.body,
  });

  factory ReportFindingDto.fromJson(Map<String, Object?> json) =>
      _$ReportFindingDtoFromJson(json);

  final ReportFindingDtoKindKind kind;
  final String title;
  final String body;

  Map<String, Object?> toJson() => _$ReportFindingDtoToJson(this);
}
