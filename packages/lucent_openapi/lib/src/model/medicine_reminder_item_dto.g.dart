// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineReminderItemDto _$MedicineReminderItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineReminderItemDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'scheduledHour',
      'scheduledMinute',
      'isActive',
      'createdAt',
      'updatedAt',
    ],
  );
  final val = MedicineReminderItemDto(
    id: $checkedConvert('id', (v) => v as String),
    currentMedicineId: $checkedConvert('currentMedicineId', (v) => v),
    label: $checkedConvert('label', (v) => v),
    scheduledHour: $checkedConvert('scheduledHour', (v) => v as num),
    scheduledMinute: $checkedConvert('scheduledMinute', (v) => v as num),
    daysOfWeek: $checkedConvert(
      'daysOfWeek',
      (v) => (v as List<dynamic>?)?.map((e) => e as num).toList(),
    ),
    startDate: $checkedConvert('startDate', (v) => v),
    endDate: $checkedConvert('endDate', (v) => v),
    isActive: $checkedConvert('isActive', (v) => v as bool),
    note: $checkedConvert('note', (v) => v),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$MedicineReminderItemDtoToJson(
  MedicineReminderItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  if (instance.currentMedicineId != null)
    'currentMedicineId': instance.currentMedicineId,
  if (instance.label != null) 'label': instance.label,
  'scheduledHour': instance.scheduledHour,
  'scheduledMinute': instance.scheduledMinute,
  if (instance.daysOfWeek != null) 'daysOfWeek': instance.daysOfWeek,
  if (instance.startDate != null) 'startDate': instance.startDate,
  if (instance.endDate != null) 'endDate': instance.endDate,
  'isActive': instance.isActive,
  if (instance.note != null) 'note': instance.note,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
