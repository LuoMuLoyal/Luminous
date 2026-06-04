// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoseLogListResponseDto _$DoseLogListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DoseLogListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DoseLogListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DoseLogListDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DoseLogListResponseDtoToJson(
  DoseLogListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
