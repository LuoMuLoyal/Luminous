// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_detail_data_dto_detail_detail.dart';
import 'medicine_detail_data_dto_source_source.dart';

part 'medicine_detail_data_dto.g.dart';

@JsonSerializable()
class MedicineDetailDataDto {
  const MedicineDetailDataDto({
    required this.id,
    required this.source,
    required this.name,
    required this.subtitle,
    required this.detail,
  });

  factory MedicineDetailDataDto.fromJson(Map<String, Object?> json) =>
      _$MedicineDetailDataDtoFromJson(json);

  final String id;
  final MedicineDetailDataDtoSourceSource source;
  final String name;
  final String? subtitle;
  final MedicineDetailDataDtoDetailDetail detail;

  Map<String, Object?> toJson() => _$MedicineDetailDataDtoToJson(this);
}
