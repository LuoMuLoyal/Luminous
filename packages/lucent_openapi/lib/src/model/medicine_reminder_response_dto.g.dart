// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineReminderResponseDto _$MedicineReminderResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineReminderResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = MedicineReminderResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => MedicineReminderItemDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineReminderResponseDtoToJson(
  MedicineReminderResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
