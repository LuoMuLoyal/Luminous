// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppInfoResponseDto _$AppInfoResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AppInfoResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = AppInfoResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => AppInfoDataDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AppInfoResponseDtoToJson(AppInfoResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
