// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_email_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountEmailDataDto _$AccountEmailDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountEmailDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'emailVerifiedAt']);
      final val = AccountEmailDataDto(
        email: $checkedConvert('email', (v) => v as String),
        emailVerifiedAt: $checkedConvert('emailVerifiedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AccountEmailDataDtoToJson(
  AccountEmailDataDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'emailVerifiedAt': instance.emailVerifiedAt,
};
