// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_context_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthContextResponseDto _$HealthContextResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HealthContextResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = HealthContextResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => HealthContextDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$HealthContextResponseDtoToJson(
  HealthContextResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
