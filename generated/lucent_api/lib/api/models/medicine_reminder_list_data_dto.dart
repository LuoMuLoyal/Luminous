// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'medicine_reminder_item_dto.dart';

part 'medicine_reminder_list_data_dto.g.dart';

@JsonSerializable()
class MedicineReminderListDataDto {
  const MedicineReminderListDataDto({required this.items});

  factory MedicineReminderListDataDto.fromJson(Map<String, Object?> json) =>
      _$MedicineReminderListDataDtoFromJson(json);

  final List<MedicineReminderItemDto> items;

  Map<String, Object?> toJson() => _$MedicineReminderListDataDtoToJson(this);
}
