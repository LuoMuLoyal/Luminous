// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_medicine_reminder_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMedicineReminderDto _$CreateMedicineReminderDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateMedicineReminderDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['scheduledHour', 'scheduledMinute']);
  final val = CreateMedicineReminderDto(
    currentMedicineId: $checkedConvert(
      'currentMedicineId',
      (v) => v as String?,
    ),
    label: $checkedConvert('label', (v) => v),
    scheduledHour: $checkedConvert('scheduledHour', (v) => v as num),
    scheduledMinute: $checkedConvert('scheduledMinute', (v) => v as num),
    daysOfWeek: $checkedConvert(
      'daysOfWeek',
      (v) => (v as List<dynamic>?)?.map((e) => e as num).toList(),
    ),
    startDate: $checkedConvert('startDate', (v) => v),
    endDate: $checkedConvert('endDate', (v) => v),
    isActive: $checkedConvert('isActive', (v) => v as bool? ?? true),
    note: $checkedConvert('note', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$CreateMedicineReminderDtoToJson(
  CreateMedicineReminderDto instance,
) => <String, dynamic>{
  if (instance.currentMedicineId != null)
    'currentMedicineId': instance.currentMedicineId,
  if (instance.label != null) 'label': instance.label,
  'scheduledHour': instance.scheduledHour,
  'scheduledMinute': instance.scheduledMinute,
  if (instance.daysOfWeek != null) 'daysOfWeek': instance.daysOfWeek,
  if (instance.startDate != null) 'startDate': instance.startDate,
  if (instance.endDate != null) 'endDate': instance.endDate,
  if (instance.isActive != null) 'isActive': instance.isActive,
  if (instance.note != null) 'note': instance.note,
};
