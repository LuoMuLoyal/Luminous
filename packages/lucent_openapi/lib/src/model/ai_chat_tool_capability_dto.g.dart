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
  AiChatToolCapabilityDtoNameEnum.getTodayRecords: 'get_today_records',
  AiChatToolCapabilityDtoNameEnum.getRecordsByDate: 'get_records_by_date',
  AiChatToolCapabilityDtoNameEnum.getRecordsByRange: 'get_records_by_range',
  AiChatToolCapabilityDtoNameEnum.getRecentTodaySummaries:
      'get_recent_today_summaries',
  AiChatToolCapabilityDtoNameEnum.getRecentReportSummaries:
      'get_recent_report_summaries',
  AiChatToolCapabilityDtoNameEnum.getUserProfile: 'get_user_profile',
  AiChatToolCapabilityDtoNameEnum.getUserSettings: 'get_user_settings',
  AiChatToolCapabilityDtoNameEnum.getCurrentMedicines: 'get_current_medicines',
  AiChatToolCapabilityDtoNameEnum.getSleepSummaryByRange:
      'get_sleep_summary_by_range',
  AiChatToolCapabilityDtoNameEnum.proposeCreateDailyRecord:
      'propose_create_daily_record',
  AiChatToolCapabilityDtoNameEnum.proposeUpdateDailyRecord:
      'propose_update_daily_record',
  AiChatToolCapabilityDtoNameEnum.proposeDeleteDailyRecord:
      'propose_delete_daily_record',
  AiChatToolCapabilityDtoNameEnum.proposeUpdateUserSettings:
      'propose_update_user_settings',
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
