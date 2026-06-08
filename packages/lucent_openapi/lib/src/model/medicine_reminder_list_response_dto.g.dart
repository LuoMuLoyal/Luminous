// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineReminderListResponseDto _$MedicineReminderListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineReminderListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = MedicineReminderListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => MedicineReminderListDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineReminderListResponseDtoToJson(
  MedicineReminderListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
