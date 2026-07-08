// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_search_item_dto.dart';
import 'medicine_search_meta_dto.dart';

part 'medicine_search_response_dto.g.dart';

@JsonSerializable()
class MedicineSearchResponseDto {
  const MedicineSearchResponseDto({
    required this.code,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory MedicineSearchResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSearchResponseDtoFromJson(json);

  final num code;
  final String message;
  final List<MedicineSearchItemDto> data;
  final MedicineSearchMetaDto meta;

  Map<String, Object?> toJson() => _$MedicineSearchResponseDtoToJson(this);
}
