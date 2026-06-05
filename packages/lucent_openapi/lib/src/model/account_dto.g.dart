// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountDto _$AccountDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AccountDto',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'email',
        'nickname',
        'avatar',
        'emailVerifiedAt',
        'hasPassword',
        'lastLoginAt',
        'linkedIdentities',
        'createdAt',
        'updatedAt',
      ],
    );
    final val = AccountDto(
      id: $checkedConvert('id', (v) => v as String),
      email: $checkedConvert('email', (v) => v),
      nickname: $checkedConvert('nickname', (v) => v),
      avatar: $checkedConvert('avatar', (v) => v),
      emailVerifiedAt: $checkedConvert('emailVerifiedAt', (v) => v),
      hasPassword: $checkedConvert('hasPassword', (v) => v as bool),
      lastLoginAt: $checkedConvert('lastLoginAt', (v) => v),
      linkedIdentities: $checkedConvert(
        'linkedIdentities',
        (v) => (v as List<dynamic>)
            .map((e) => AccountIdentityDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      createdAt: $checkedConvert('createdAt', (v) => v as String),
      updatedAt: $checkedConvert('updatedAt', (v) => v as String),
    );
    return val;
  },
);

Map<String, dynamic> _$AccountDtoToJson(
  AccountDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'emailVerifiedAt': instance.emailVerifiedAt,
  'hasPassword': instance.hasPassword,
  'lastLoginAt': instance.lastLoginAt,
  'linkedIdentities': instance.linkedIdentities.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
