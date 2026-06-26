// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationListResponseDto _$NotificationListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NotificationListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'items', 'total']);
  final val = NotificationListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => NotificationListItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    total: $checkedConvert('total', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$NotificationListResponseDtoToJson(
  NotificationListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'total': instance.total,
};
