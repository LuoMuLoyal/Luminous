// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apple_o_auth_callback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppleOAuthCallbackDto _$AppleOAuthCallbackDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AppleOAuthCallbackDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['identityToken']);
  final val = AppleOAuthCallbackDto(
    identityToken: $checkedConvert('identityToken', (v) => v as String),
    authorizationCode: $checkedConvert(
      'authorizationCode',
      (v) => v as String?,
    ),
    givenName: $checkedConvert('givenName', (v) => v as String?),
    familyName: $checkedConvert('familyName', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AppleOAuthCallbackDtoToJson(
  AppleOAuthCallbackDto instance,
) => <String, dynamic>{
  'identityToken': instance.identityToken,
  if (instance.authorizationCode != null)
    'authorizationCode': instance.authorizationCode,
  if (instance.givenName != null) 'givenName': instance.givenName,
  if (instance.familyName != null) 'familyName': instance.familyName,
};
