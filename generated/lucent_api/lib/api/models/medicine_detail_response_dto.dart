// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_detail_data_dto.dart';

part 'medicine_detail_response_dto.g.dart';

@JsonSerializable()
class MedicineDetailResponseDto {
  const MedicineDetailResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MedicineDetailResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineDetailResponseDtoFromJson(json);

  final num code;
  final String message;
  final MedicineDetailDataDto data;

  Map<String, Object?> toJson() => _$MedicineDetailResponseDtoToJson(this);
}
