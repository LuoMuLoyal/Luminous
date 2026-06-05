// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_authorize_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthAuthorizeDto _$OAuthAuthorizeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OAuthAuthorizeDto', json, ($checkedConvert) {
      final val = OAuthAuthorizeDto(
        callbackUri: $checkedConvert('callbackUri', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$OAuthAuthorizeDtoToJson(OAuthAuthorizeDto instance) =>
    <String, dynamic>{'callbackUri': ?instance.callbackUri};
