// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_search_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineSearchResponseDto _$MedicineSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineSearchResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data', 'meta']);
  final val = MedicineSearchResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => MedicineSearchItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => MedicineSearchMetaDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineSearchResponseDtoToJson(
  MedicineSearchResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.map((e) => e.toJson()).toList(),
  'meta': instance.meta.toJson(),
};
