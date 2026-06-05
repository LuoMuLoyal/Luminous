// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'o_auth_authorize_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthAuthorizeResponseDto _$OAuthAuthorizeResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OAuthAuthorizeResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = OAuthAuthorizeResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => OAuthAuthorizeDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$OAuthAuthorizeResponseDtoToJson(
  OAuthAuthorizeResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
