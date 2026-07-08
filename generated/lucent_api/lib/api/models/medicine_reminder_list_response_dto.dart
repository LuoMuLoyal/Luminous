// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_reminder_list_data_dto.dart';

part 'medicine_reminder_list_response_dto.g.dart';

@JsonSerializable()
class MedicineReminderListResponseDto {
  const MedicineReminderListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MedicineReminderListResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineReminderListResponseDtoFromJson(json);

  final num code;
  final String message;
  final MedicineReminderListDataDto data;

  Map<String, Object?> toJson() =>
      _$MedicineReminderListResponseDtoToJson(this);
}
