// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeEmailDto _$ChangeEmailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChangeEmailDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['newEmail', 'code']);
      final val = ChangeEmailDto(
        newEmail: $checkedConvert('newEmail', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ChangeEmailDtoToJson(ChangeEmailDto instance) =>
    <String, dynamic>{'newEmail': instance.newEmail, 'code': instance.code};
