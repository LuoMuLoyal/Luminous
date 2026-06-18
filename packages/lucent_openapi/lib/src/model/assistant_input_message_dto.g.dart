// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_input_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantInputMessageDto _$AssistantInputMessageDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantInputMessageDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['role', 'content']);
  final val = AssistantInputMessageDto(
    role: $checkedConvert(
      'role',
      (v) => $enumDecode(
        _$AssistantInputMessageDtoRoleEnumEnumMap,
        v,
        unknownValue: AssistantInputMessageDtoRoleEnum.unknownDefaultOpenApi,
      ),
    ),
    content: $checkedConvert('content', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AssistantInputMessageDtoToJson(
  AssistantInputMessageDto instance,
) => <String, dynamic>{
  'role': _$AssistantInputMessageDtoRoleEnumEnumMap[instance.role]!,
  'content': instance.content,
};

const _$AssistantInputMessageDtoRoleEnumEnumMap = {
  AssistantInputMessageDtoRoleEnum.user: 'user',
  AssistantInputMessageDtoRoleEnum.assistant: 'assistant',
  AssistantInputMessageDtoRoleEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
