// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qq_o_auth_callback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QqOAuthCallbackDto _$QqOAuthCallbackDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QqOAuthCallbackDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'state']);
      final val = QqOAuthCallbackDto(
        code: $checkedConvert('code', (v) => v as String),
        state: $checkedConvert('state', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$QqOAuthCallbackDtoToJson(QqOAuthCallbackDto instance) =>
    <String, dynamic>{'code': instance.code, 'state': instance.state};
