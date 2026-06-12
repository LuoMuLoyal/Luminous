// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_weekly_summary_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportWeeklySummaryDataDto _$ReportWeeklySummaryDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportWeeklySummaryDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'range',
      'startDate',
      'endDate',
      'generatedAt',
      'summary',
      'bullets',
      'actionLabel',
      'confidenceNote',
    ],
  );
  final val = ReportWeeklySummaryDataDto(
    range: $checkedConvert(
      'range',
      (v) => $enumDecode(
        _$ReportWeeklySummaryDataDtoRangeEnumEnumMap,
        v,
        unknownValue: ReportWeeklySummaryDataDtoRangeEnum.unknownDefaultOpenApi,
      ),
    ),
    startDate: $checkedConvert('startDate', (v) => v as String),
    endDate: $checkedConvert('endDate', (v) => v as String),
    generatedAt: $checkedConvert('generatedAt', (v) => v as String),
    summary: $checkedConvert('summary', (v) => v as String),
    bullets: $checkedConvert(
      'bullets',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ReportWeeklySummaryBulletDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
    actionLabel: $checkedConvert('actionLabel', (v) => v as String),
    confidenceNote: $checkedConvert('confidenceNote', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReportWeeklySummaryDataDtoToJson(
  ReportWeeklySummaryDataDto instance,
) => <String, dynamic>{
  'range': _$ReportWeeklySummaryDataDtoRangeEnumEnumMap[instance.range]!,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'generatedAt': instance.generatedAt,
  'summary': instance.summary,
  'bullets': instance.bullets.map((e) => e.toJson()).toList(),
  'actionLabel': instance.actionLabel,
  'confidenceNote': instance.confidenceNote,
};

const _$ReportWeeklySummaryDataDtoRangeEnumEnumMap = {
  ReportWeeklySummaryDataDtoRangeEnum.last7Days: 'last_7_days',
  ReportWeeklySummaryDataDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
