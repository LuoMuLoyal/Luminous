// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_detail_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineDetailResponseDto _$MedicineDetailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineDetailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = MedicineDetailResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => MedicineDetailDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MedicineDetailResponseDtoToJson(
  MedicineDetailResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
