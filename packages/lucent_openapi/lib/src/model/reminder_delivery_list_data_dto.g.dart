// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_delivery_list_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderDeliveryListDataDto _$ReminderDeliveryListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReminderDeliveryListDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = ReminderDeliveryListDataDto(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ReminderDeliveryItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReminderDeliveryListDataDtoToJson(
  ReminderDeliveryListDataDto instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
