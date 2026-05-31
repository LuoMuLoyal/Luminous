// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_search_meta_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineSearchMetaDto _$MedicineSearchMetaDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineSearchMetaDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['pagination']);
  final val = MedicineSearchMetaDto(
    pagination: $checkedConvert(
      'pagination',
      (v) => MedicinePaginationDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineSearchMetaDtoToJson(
  MedicineSearchMetaDto instance,
) => <String, dynamic>{'pagination': instance.pagination.toJson()};
