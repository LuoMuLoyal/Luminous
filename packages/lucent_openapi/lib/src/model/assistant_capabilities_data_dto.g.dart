// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_capabilities_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantCapabilitiesDataDto _$AssistantCapabilitiesDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantCapabilitiesDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'phase',
      'assistantEnabled',
      'assistantMemoryEnabled',
      'assistantContext',
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
  final val = AssistantCapabilitiesDataDto(
    phase: $checkedConvert('phase', (v) => v as String),
    assistantEnabled: $checkedConvert('assistantEnabled', (v) => v as bool),
    assistantMemoryEnabled: $checkedConvert(
      'assistantMemoryEnabled',
      (v) => v as bool,
    ),
    assistantContext: $checkedConvert(
      'assistantContext',
      (v) => AssistantContextSettingsDto.fromJson(v as Map<String, dynamic>),
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
            (e) =>
                AssistantToolCapabilityDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AssistantCapabilitiesDataDtoToJson(
  AssistantCapabilitiesDataDto instance,
) => <String, dynamic>{
  'phase': instance.phase,
  'assistantEnabled': instance.assistantEnabled,
  'assistantMemoryEnabled': instance.assistantMemoryEnabled,
  'assistantContext': instance.assistantContext.toJson(),
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
