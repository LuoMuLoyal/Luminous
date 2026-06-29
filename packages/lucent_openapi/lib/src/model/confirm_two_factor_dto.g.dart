// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_two_factor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmTwoFactorDto _$ConfirmTwoFactorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfirmTwoFactorDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code']);
      final val = ConfirmTwoFactorDto(
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ConfirmTwoFactorDtoToJson(
  ConfirmTwoFactorDto instance,
) => <String, dynamic>{'code': instance.code};
