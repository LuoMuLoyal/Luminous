// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthResponseDto _$HealthResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = HealthResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => HealthProbeDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HealthResponseDtoToJson(HealthResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
