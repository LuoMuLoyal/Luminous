// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_search_data_dto.dart';

part 'medicine_search_response_dto.g.dart';

@JsonSerializable()
class MedicineSearchResponseDto {
  const MedicineSearchResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MedicineSearchResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineSearchResponseDtoFromJson(json);

  final num code;
  final String message;
  final MedicineSearchDataDto data;

  Map<String, Object?> toJson() => _$MedicineSearchResponseDtoToJson(this);
}
