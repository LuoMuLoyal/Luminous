// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetPasswordDto _$SetPasswordDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SetPasswordDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'password']);
      final val = SetPasswordDto(
        email: $checkedConvert('email', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SetPasswordDtoToJson(SetPasswordDto instance) =>
    <String, dynamic>{
      if (instance.email != null) 'email': instance.email,
      'code': instance.code,
      'password': instance.password,
    };
