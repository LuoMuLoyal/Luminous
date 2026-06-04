// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoseLogResponseDto _$DoseLogResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DoseLogResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = DoseLogResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => DoseLogItemDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DoseLogResponseDtoToJson(DoseLogResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
