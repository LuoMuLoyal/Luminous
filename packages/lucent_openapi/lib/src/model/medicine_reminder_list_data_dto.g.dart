// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_reminder_list_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineReminderListDataDto _$MedicineReminderListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineReminderListDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items']);
  final val = MedicineReminderListDataDto(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) => MedicineReminderItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineReminderListDataDtoToJson(
  MedicineReminderListDataDto instance,
) => <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
