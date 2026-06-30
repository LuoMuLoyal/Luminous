// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_tool_capability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantToolCapabilityDto _$AssistantToolCapabilityDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantToolCapabilityDto', json, ($checkedConvert) {
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
  final val = AssistantToolCapabilityDto(
    name: $checkedConvert(
      'name',
      (v) => $enumDecode(
        _$AssistantToolCapabilityDtoNameEnumEnumMap,
        v,
        unknownValue: AssistantToolCapabilityDtoNameEnum.unknownDefaultOpenApi,
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
        _$AssistantToolCapabilityDtoDisabledReasonEnumEnumMap,
        v,
        unknownValue:
            AssistantToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantToolCapabilityDtoToJson(
  AssistantToolCapabilityDto instance,
) => <String, dynamic>{
  'name': _$AssistantToolCapabilityDtoNameEnumEnumMap[instance.name]!,
  'requiredContextSources': instance.requiredContextSources,
  'permittedByUser': instance.permittedByUser,
  'enabled': instance.enabled,
  'implemented': instance.implemented,
  'disabledReason':
      _$AssistantToolCapabilityDtoDisabledReasonEnumEnumMap[instance
          .disabledReason],
};

const _$AssistantToolCapabilityDtoNameEnumEnumMap = {
  AssistantToolCapabilityDtoNameEnum.getTodayRecords: 'get_today_records',
  AssistantToolCapabilityDtoNameEnum.getRecordsByDate: 'get_records_by_date',
  AssistantToolCapabilityDtoNameEnum.getRecordsByRange: 'get_records_by_range',
  AssistantToolCapabilityDtoNameEnum.getTodaySummaryByDate:
      'get_today_summary_by_date',
  AssistantToolCapabilityDtoNameEnum.getReportSummaryByRange:
      'get_report_summary_by_range',
  AssistantToolCapabilityDtoNameEnum.getRecentTodaySummaries:
      'get_recent_today_summaries',
  AssistantToolCapabilityDtoNameEnum.getRecentReportSummaries:
      'get_recent_report_summaries',
  AssistantToolCapabilityDtoNameEnum.getUserProfile: 'get_user_profile',
  AssistantToolCapabilityDtoNameEnum.getUserSettings: 'get_user_settings',
  AssistantToolCapabilityDtoNameEnum.getCurrentMedicines:
      'get_current_medicines',
  AssistantToolCapabilityDtoNameEnum.getSleepSummaryByRange:
      'get_sleep_summary_by_range',
  AssistantToolCapabilityDtoNameEnum.getMedicineLeafletContext:
      'get_medicine_leaflet_context',
  AssistantToolCapabilityDtoNameEnum.getMedicalKnowledge:
      'get_medical_knowledge',
  AssistantToolCapabilityDtoNameEnum.proposeCreateDailyRecord:
      'propose_create_daily_record',
  AssistantToolCapabilityDtoNameEnum.proposeUpdateDailyRecord:
      'propose_update_daily_record',
  AssistantToolCapabilityDtoNameEnum.proposeDeleteDailyRecord:
      'propose_delete_daily_record',
  AssistantToolCapabilityDtoNameEnum.proposeUpdateUserSettings:
      'propose_update_user_settings',
  AssistantToolCapabilityDtoNameEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};

const _$AssistantToolCapabilityDtoDisabledReasonEnumEnumMap = {
  AssistantToolCapabilityDtoDisabledReasonEnum.chatDisabled: 'chat_disabled',
  AssistantToolCapabilityDtoDisabledReasonEnum.contextDisabled:
      'context_disabled',
  AssistantToolCapabilityDtoDisabledReasonEnum.modelNotConfigured:
      'model_not_configured',
  AssistantToolCapabilityDtoDisabledReasonEnum.notImplemented:
      'not_implemented',
  AssistantToolCapabilityDtoDisabledReasonEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
