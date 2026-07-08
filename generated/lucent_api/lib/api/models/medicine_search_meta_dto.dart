// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_pagination_dto.dart';

part 'medicine_search_meta_dto.g.dart';

@JsonSerializable()
class MedicineSearchMetaDto {
  const MedicineSearchMetaDto({required this.pagination});

  factory MedicineSearchMetaDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSearchMetaDtoFromJson(json);

  final MedicinePaginationDto pagination;

  Map<String, Object?> toJson() => _$MedicineSearchMetaDtoToJson(this);
}
