// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reminder_delivery_item_dto.dart';

part 'reminder_delivery_list_data_dto.g.dart';

@JsonSerializable()
class ReminderDeliveryListDataDto {
  const ReminderDeliveryListDataDto({required this.items});

  factory ReminderDeliveryListDataDto.fromJson(Map<String, Object?> json) =>
      _$ReminderDeliveryListDataDtoFromJson(json);

  final List<ReminderDeliveryItemDto> items;

  Map<String, Object?> toJson() => _$ReminderDeliveryListDataDtoToJson(this);
}
