// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_delivery_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderDeliveryListResponseDto _$ReminderDeliveryListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReminderDeliveryListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ReminderDeliveryListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => ReminderDeliveryListDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReminderDeliveryListResponseDtoToJson(
  ReminderDeliveryListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
