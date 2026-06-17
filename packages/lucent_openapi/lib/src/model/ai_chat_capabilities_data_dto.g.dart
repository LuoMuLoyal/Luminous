// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_capabilities_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatCapabilitiesDataDto _$AiChatCapabilitiesDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatCapabilitiesDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'phase',
      'aiChatEnabled',
      'aiChatContext',
      'chatModelConfigured',
      'interactiveChatReady',
      'langGraphReady',
      'streamingSupported',
      'streamingTransport',
      'markdownRenderingRecommended',
      'ragEnabled',
      'tools',
      'updatedAt',
    ],
  );
  final val = AiChatCapabilitiesDataDto(
    phase: $checkedConvert('phase', (v) => v as String),
    aiChatEnabled: $checkedConvert('aiChatEnabled', (v) => v as bool),
    aiChatContext: $checkedConvert(
      'aiChatContext',
      (v) => AiChatContextSettingsDto.fromJson(v as Map<String, dynamic>),
    ),
    chatModelConfigured: $checkedConvert(
      'chatModelConfigured',
      (v) => v as bool,
    ),
    interactiveChatReady: $checkedConvert(
      'interactiveChatReady',
      (v) => v as bool,
    ),
    langGraphReady: $checkedConvert('langGraphReady', (v) => v as bool),
    streamingSupported: $checkedConvert('streamingSupported', (v) => v as bool),
    streamingTransport: $checkedConvert(
      'streamingTransport',
      (v) => v as String,
    ),
    markdownRenderingRecommended: $checkedConvert(
      'markdownRenderingRecommended',
      (v) => v as bool,
    ),
    ragEnabled: $checkedConvert('ragEnabled', (v) => v as bool),
    tools: $checkedConvert(
      'tools',
      (v) => (v as List<dynamic>)
          .map(
            (e) => AiChatToolCapabilityDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AiChatCapabilitiesDataDtoToJson(
  AiChatCapabilitiesDataDto instance,
) => <String, dynamic>{
  'phase': instance.phase,
  'aiChatEnabled': instance.aiChatEnabled,
  'aiChatContext': instance.aiChatContext.toJson(),
  'chatModelConfigured': instance.chatModelConfigured,
  'interactiveChatReady': instance.interactiveChatReady,
  'langGraphReady': instance.langGraphReady,
  'streamingSupported': instance.streamingSupported,
  'streamingTransport': instance.streamingTransport,
  'markdownRenderingRecommended': instance.markdownRenderingRecommended,
  'ragEnabled': instance.ragEnabled,
  'tools': instance.tools.map((e) => e.toJson()).toList(),
  'updatedAt': instance.updatedAt,
};
