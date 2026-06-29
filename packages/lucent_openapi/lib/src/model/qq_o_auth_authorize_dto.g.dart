// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qq_o_auth_authorize_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QqOAuthAuthorizeDto _$QqOAuthAuthorizeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QqOAuthAuthorizeDto', json, ($checkedConvert) {
      final val = QqOAuthAuthorizeDto(
        callbackUri: $checkedConvert('callbackUri', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$QqOAuthAuthorizeDtoToJson(
  QqOAuthAuthorizeDto instance,
) => <String, dynamic>{'callbackUri': ?instance.callbackUri};
