// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reminder_delivery_list_data_dto.dart';

part 'reminder_delivery_list_response_dto.g.dart';

@JsonSerializable()
class ReminderDeliveryListResponseDto {
  const ReminderDeliveryListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ReminderDeliveryListResponseDto.fromJson(Map<String, Object?> json) =>
      _$ReminderDeliveryListResponseDtoFromJson(json);

  final num code;
  final String message;
  final ReminderDeliveryListDataDto data;

  Map<String, Object?> toJson() =>
      _$ReminderDeliveryListResponseDtoToJson(this);
}
