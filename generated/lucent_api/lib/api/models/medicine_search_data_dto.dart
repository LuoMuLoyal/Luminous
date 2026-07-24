// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_pagination_dto.dart';
import 'medicine_search_item_dto.dart';

part 'medicine_search_data_dto.g.dart';

@JsonSerializable()
class MedicineSearchDataDto {
  const MedicineSearchDataDto({required this.items, required this.pagination});

  factory MedicineSearchDataDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSearchDataDtoFromJson(json);

  final List<MedicineSearchItemDto> items;
  final MedicinePaginationDto pagination;

  Map<String, Object?> toJson() => _$MedicineSearchDataDtoToJson(this);
}
