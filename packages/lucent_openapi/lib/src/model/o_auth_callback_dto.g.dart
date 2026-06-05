// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_callback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthCallbackDto _$OAuthCallbackDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OAuthCallbackDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'state']);
      final val = OAuthCallbackDto(
        code: $checkedConvert('code', (v) => v as String),
        state: $checkedConvert('state', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$OAuthCallbackDtoToJson(OAuthCallbackDto instance) =>
    <String, dynamic>{'code': instance.code, 'state': instance.state};
