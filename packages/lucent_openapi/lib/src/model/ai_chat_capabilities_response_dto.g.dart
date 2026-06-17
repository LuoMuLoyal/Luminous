// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_capabilities_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatCapabilitiesResponseDto _$AiChatCapabilitiesResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatCapabilitiesResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = AiChatCapabilitiesResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => AiChatCapabilitiesDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AiChatCapabilitiesResponseDtoToJson(
  AiChatCapabilitiesResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
