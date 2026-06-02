// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email']);
      final val = LoginDto(
        email: $checkedConvert('email', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
  'email': instance.email,
  if (instance.password != null) 'password': instance.password,
  if (instance.code != null) 'code': instance.code,
};
