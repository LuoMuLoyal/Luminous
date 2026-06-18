// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversationResponseDto _$AssistantConversationResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantConversationResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = AssistantConversationResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : AssistantConversationDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantConversationResponseDtoToJson(
  AssistantConversationResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data?.toJson(),
};
