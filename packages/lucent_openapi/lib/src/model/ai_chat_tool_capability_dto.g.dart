// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_tool_capability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatToolCapabilityDto _$AiChatToolCapabilityDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatToolCapabilityDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'name',
      'requiredContextSources',
      'permittedByUser',
      'enabled',
      'implemented',
      'disabledReason',
    ],
  );
  final val = AiChatToolCapabilityDto(
    name: $checkedConvert(
      'name',
      (v) => $enumDecode(
        _$AiChatToolCapabilityDtoNameEnumEnumMap,
        v,
        unknownValue: AiChatToolCapabilityDtoNameEnum.unknownDefaultOpenApi,
      ),
    ),
    requiredContextSources: $checkedConvert(
      'requiredContextSources',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    permittedByUser: $checkedConvert('permittedByUser', (v) => v as bool),
    enabled: $checkedConvert('enabled', (v) => v as bool),
    implemented: $checkedConvert('implemented', (v) => v as bool),
    disabledReason: $checkedConvert(
      'disabledReason',
      (v) => $enumDecodeNullable(
        _$AiChatToolCapabilityDtoDisabledReasonEnumEnumMap,
        v,
        unknownValue:
            AiChatToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$AiChatToolCapabilityDtoToJson(
  AiChatToolCapabilityDto instance,
) => <String, dynamic>{
  'name': _$AiChatToolCapabilityDtoNameEnumEnumMap[instance.name]!,
  'requiredContextSources': instance.requiredContextSources,
  'permittedByUser': instance.permittedByUser,
  'enabled': instance.enabled,
  'implemented': instance.implemented,
  'disabledReason':
      _$AiChatToolCapabilityDtoDisabledReasonEnumEnumMap[instance
          .disabledReason],
};

const _$AiChatToolCapabilityDtoNameEnumEnumMap = {
  AiChatToolCapabilityDtoNameEnum.healthContextSnapshot:
      'health_context_snapshot',
  AiChatToolCapabilityDtoNameEnum.recentDailyRecords: 'recent_daily_records',
  AiChatToolCapabilityDtoNameEnum.recentSleepSummary: 'recent_sleep_summary',
  AiChatToolCapabilityDtoNameEnum.currentMedicines: 'current_medicines',
  AiChatToolCapabilityDtoNameEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};

const _$AiChatToolCapabilityDtoDisabledReasonEnumEnumMap = {
  AiChatToolCapabilityDtoDisabledReasonEnum.chatDisabled: 'chat_disabled',
  AiChatToolCapabilityDtoDisabledReasonEnum.contextDisabled: 'context_disabled',
  AiChatToolCapabilityDtoDisabledReasonEnum.modelNotConfigured:
      'model_not_configured',
  AiChatToolCapabilityDtoDisabledReasonEnum.notImplemented: 'not_implemented',
  AiChatToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
