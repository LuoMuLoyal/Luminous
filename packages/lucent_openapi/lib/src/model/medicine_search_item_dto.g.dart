// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_search_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineSearchItemDto _$MedicineSearchItemDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineSearchItemDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'source',
      'name',
      'subtitle',
      'summary',
      'tags',
      'imageUrl',
      'matchedBy',
    ],
  );
  final val = MedicineSearchItemDto(
    id: $checkedConvert('id', (v) => v as String),
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(
        _$MedicineSearchItemDtoSource_EnumEnumMap,
        v,
        unknownValue: MedicineSearchItemDtoSource_Enum.unknownDefaultOpenApi,
      ),
    ),
    name: $checkedConvert('name', (v) => v as String),
    subtitle: $checkedConvert('subtitle', (v) => v),
    summary: $checkedConvert('summary', (v) => v),
    tags: $checkedConvert(
      'tags',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    imageUrl: $checkedConvert('imageUrl', (v) => v),
    matchedBy: $checkedConvert(
      'matchedBy',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$MedicineSearchItemDtoToJson(
  MedicineSearchItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'source': _$MedicineSearchItemDtoSource_EnumEnumMap[instance.source_]!,
  'name': instance.name,
  'subtitle': instance.subtitle,
  'summary': instance.summary,
  'tags': instance.tags,
  'imageUrl': instance.imageUrl,
  'matchedBy': instance.matchedBy,
};

const _$MedicineSearchItemDtoSource_EnumEnumMap = {
  MedicineSearchItemDtoSource_Enum.drugbank: 'drugbank',
  MedicineSearchItemDtoSource_Enum.cn: 'cn',
  MedicineSearchItemDtoSource_Enum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
