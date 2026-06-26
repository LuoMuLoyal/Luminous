// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDetailResponseDto _$NotificationDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NotificationDetailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = NotificationDetailResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : NotificationDetailDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$NotificationDetailResponseDtoToJson(
  NotificationDetailResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data?.toJson(),
};
