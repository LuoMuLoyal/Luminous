// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_list_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoseLogListDataDto _$DoseLogListDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DoseLogListDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['items']);
      final val = DoseLogListDataDto(
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => DoseLogItemDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DoseLogListDataDtoToJson(DoseLogListDataDto instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
