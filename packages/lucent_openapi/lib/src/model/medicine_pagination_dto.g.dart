// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_pagination_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicinePaginationDto _$MedicinePaginationDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicinePaginationDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['page', 'pageSize', 'total', 'totalPages'],
  );
  final val = MedicinePaginationDto(
    page: $checkedConvert('page', (v) => v as num),
    pageSize: $checkedConvert('pageSize', (v) => v as num),
    total: $checkedConvert('total', (v) => v as num),
    totalPages: $checkedConvert('totalPages', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$MedicinePaginationDtoToJson(
  MedicinePaginationDto instance,
) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'total': instance.total,
  'totalPages': instance.totalPages,
};
