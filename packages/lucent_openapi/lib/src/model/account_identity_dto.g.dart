// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_identity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountIdentityDto _$AccountIdentityDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountIdentityDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'provider',
          'email',
          'emailVerifiedAt',
          'linkedAt',
        ],
      );
      final val = AccountIdentityDto(
        provider: $checkedConvert('provider', (v) => v as String),
        email: $checkedConvert('email', (v) => v),
        emailVerifiedAt: $checkedConvert('emailVerifiedAt', (v) => v),
        linkedAt: $checkedConvert('linkedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AccountIdentityDtoToJson(AccountIdentityDto instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'email': instance.email,
      'emailVerifiedAt': instance.emailVerifiedAt,
      'linkedAt': instance.linkedAt,
    };
