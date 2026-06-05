// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_email_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountEmailResponseDto _$AccountEmailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AccountEmailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = AccountEmailResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => AccountEmailDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AccountEmailResponseDtoToJson(
  AccountEmailResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
