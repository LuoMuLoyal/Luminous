// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountResponseDto _$AccountResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = AccountResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => AccountDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AccountResponseDtoToJson(AccountResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
    };
