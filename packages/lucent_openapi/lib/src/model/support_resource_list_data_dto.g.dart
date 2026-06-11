// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_resource_list_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportResourceListDataDto _$SupportResourceListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SupportResourceListDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['items', 'updatedAt']);
  final val = SupportResourceListDataDto(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => SupportResourceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$SupportResourceListDataDtoToJson(
  SupportResourceListDataDto instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'updatedAt': instance.updatedAt,
};
