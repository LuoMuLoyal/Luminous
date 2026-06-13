// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_summary_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryDataDto _$ReportSummaryDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportSummaryDataDto', json, ($checkedConvert) {
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
  final val = ReportSummaryDataDto(
    range: $checkedConvert(
      'range',
      (v) => $enumDecode(
        _$ReportSummaryDataDtoRangeEnumEnumMap,
        v,
        unknownValue: ReportSummaryDataDtoRangeEnum.unknownDefaultOpenApi,
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
            (e) => ReportSummaryBulletDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    actionLabel: $checkedConvert('actionLabel', (v) => v as String),
    confidenceNote: $checkedConvert('confidenceNote', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReportSummaryDataDtoToJson(
  ReportSummaryDataDto instance,
) => <String, dynamic>{
  'range': _$ReportSummaryDataDtoRangeEnumEnumMap[instance.range]!,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'generatedAt': instance.generatedAt,
  'summary': instance.summary,
  'bullets': instance.bullets.map((e) => e.toJson()).toList(),
  'actionLabel': instance.actionLabel,
  'confidenceNote': instance.confidenceNote,
};

const _$ReportSummaryDataDtoRangeEnumEnumMap = {
  ReportSummaryDataDtoRangeEnum.last7Days: 'last_7_days',
  ReportSummaryDataDtoRangeEnum.last30Days: 'last_30_days',
  ReportSummaryDataDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
