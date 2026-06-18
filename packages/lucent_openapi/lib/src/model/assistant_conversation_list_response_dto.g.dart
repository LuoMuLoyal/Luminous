// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversation_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantConversationListResponseDto
_$AssistantConversationListResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AssistantConversationListResponseDto', json, (
      $checkedConvert,
    ) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = AssistantConversationListResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>)
              .map(
                (e) => AssistantConversationSummaryDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AssistantConversationListResponseDtoToJson(
  AssistantConversationListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.map((e) => e.toJson()).toList(),
};
