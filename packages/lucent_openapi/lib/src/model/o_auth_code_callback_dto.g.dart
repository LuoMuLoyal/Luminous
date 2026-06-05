// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_code_callback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthCodeCallbackDto _$OAuthCodeCallbackDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OAuthCodeCallbackDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code']);
  final val = OAuthCodeCallbackDto(
    code: $checkedConvert('code', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$OAuthCodeCallbackDtoToJson(
  OAuthCodeCallbackDto instance,
) => <String, dynamic>{'code': instance.code};
