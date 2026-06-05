// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_authorize_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthAuthorizeDataDto _$OAuthAuthorizeDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OAuthAuthorizeDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['authorizeUrl', 'state', 'expiresIn']);
  final val = OAuthAuthorizeDataDto(
    authorizeUrl: $checkedConvert('authorizeUrl', (v) => v as String),
    state: $checkedConvert('state', (v) => v as String),
    expiresIn: $checkedConvert('expiresIn', (v) => v as num),
    callbackUri: $checkedConvert('callbackUri', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$OAuthAuthorizeDataDtoToJson(
  OAuthAuthorizeDataDto instance,
) => <String, dynamic>{
  'authorizeUrl': instance.authorizeUrl,
  'state': instance.state,
  'expiresIn': instance.expiresIn,
  if (instance.callbackUri != null) 'callbackUri': instance.callbackUri,
};
