// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_reminder_item_dto.dart';

part 'medicine_reminder_response_dto.g.dart';

@JsonSerializable()
class MedicineReminderResponseDto {
  const MedicineReminderResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MedicineReminderResponseDto.fromJson(Map<String, Object?> json) =>
      _$MedicineReminderResponseDtoFromJson(json);

  final num code;
  final String message;
  final MedicineReminderItemDto data;

  Map<String, Object?> toJson() => _$MedicineReminderResponseDtoToJson(this);
}
