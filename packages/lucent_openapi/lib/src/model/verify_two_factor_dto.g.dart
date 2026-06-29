// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_two_factor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyTwoFactorDto _$VerifyTwoFactorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyTwoFactorDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'tempToken']);
      final val = VerifyTwoFactorDto(
        code: $checkedConvert('code', (v) => v as String),
        tempToken: $checkedConvert('tempToken', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VerifyTwoFactorDtoToJson(VerifyTwoFactorDto instance) =>
    <String, dynamic>{'code': instance.code, 'tempToken': instance.tempToken};
