// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettingsResponseDto _$UserSettingsResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserSettingsResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = UserSettingsResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => UserSettingsDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$UserSettingsResponseDtoToJson(
  UserSettingsResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
