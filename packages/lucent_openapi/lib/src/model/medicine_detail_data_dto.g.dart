// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_detail_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineDetailDataDto _$MedicineDetailDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineDetailDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'source', 'name', 'subtitle', 'detail'],
  );
  final val = MedicineDetailDataDto(
    id: $checkedConvert('id', (v) => v as String),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(
        _$MedicineDetailDataDtoSource_EnumEnumMap,
        v,
        unknownValue: MedicineDetailDataDtoSource_Enum.unknownDefaultOpenApi,
      ),
    ),
    name: $checkedConvert('name', (v) => v as String),
    subtitle: $checkedConvert('subtitle', (v) => v),
    detail: $checkedConvert(
      'detail',
      (v) => MedicineDetailDataDtoDetail.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$MedicineDetailDataDtoToJson(
  MedicineDetailDataDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'source': _$MedicineDetailDataDtoSource_EnumEnumMap[instance.source_]!,
  'name': instance.name,
  'subtitle': instance.subtitle,
  'detail': instance.detail.toJson(),
};

const _$MedicineDetailDataDtoSource_EnumEnumMap = {
  MedicineDetailDataDtoSource_Enum.drugbank: 'drugbank',
  MedicineDetailDataDtoSource_Enum.cn: 'cn',
  MedicineDetailDataDtoSource_Enum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
