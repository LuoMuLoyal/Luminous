// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_medicine_reminder_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMedicineReminderDto _$UpdateMedicineReminderDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateMedicineReminderDto', json, ($checkedConvert) {
  final val = UpdateMedicineReminderDto(
    currentMedicineId: $checkedConvert('currentMedicineId', (v) => v),
    label: $checkedConvert('label', (v) => v),
    scheduledHour: $checkedConvert('scheduledHour', (v) => v as num?),
    scheduledMinute: $checkedConvert('scheduledMinute', (v) => v as num?),
    daysOfWeek: $checkedConvert(
      'daysOfWeek',
      (v) => (v as List<dynamic>?)?.map((e) => e as num).toList(),
    ),
    startDate: $checkedConvert('startDate', (v) => v),
    endDate: $checkedConvert('endDate', (v) => v),
    isActive: $checkedConvert('isActive', (v) => v as bool?),
    note: $checkedConvert('note', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$UpdateMedicineReminderDtoToJson(
  UpdateMedicineReminderDto instance,
) => <String, dynamic>{
  if (instance.currentMedicineId != null)
    'currentMedicineId': instance.currentMedicineId,
  if (instance.label != null) 'label': instance.label,
  if (instance.scheduledHour != null) 'scheduledHour': instance.scheduledHour,
  if (instance.scheduledMinute != null)
    'scheduledMinute': instance.scheduledMinute,
  if (instance.daysOfWeek != null) 'daysOfWeek': instance.daysOfWeek,
  if (instance.startDate != null) 'startDate': instance.startDate,
  if (instance.endDate != null) 'endDate': instance.endDate,
  if (instance.isActive != null) 'isActive': instance.isActive,
  if (instance.note != null) 'note': instance.note,
};
