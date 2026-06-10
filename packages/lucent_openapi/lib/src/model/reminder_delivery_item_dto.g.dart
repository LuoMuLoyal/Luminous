// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_delivery_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderDeliveryItemDto _$ReminderDeliveryItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReminderDeliveryItemDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'channel',
      'status',
      'scheduledFor',
      'createdAt',
    ],
  );
  final val = ReminderDeliveryItemDto(
    id: $checkedConvert('id', (v) => v as String),
    reminderId: $checkedConvert('reminderId', (v) => v),
    deviceId: $checkedConvert('deviceId', (v) => v),
    channel: $checkedConvert('channel', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    scheduledFor: $checkedConvert('scheduledFor', (v) => v as String),
    deliveredAt: $checkedConvert('deliveredAt', (v) => v),
    errorMessage: $checkedConvert('errorMessage', (v) => v),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReminderDeliveryItemDtoToJson(
  ReminderDeliveryItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.reminderId != null) 'reminderId': instance.reminderId,
  if (instance.deviceId != null) 'deviceId': instance.deviceId,
  'channel': instance.channel,
  'status': instance.status,
  'scheduledFor': instance.scheduledFor,
  if (instance.deliveredAt != null) 'deliveredAt': instance.deliveredAt,
  if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
  'createdAt': instance.createdAt,
};
