// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_analysis_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayAnalysisDataDto _$TodayAnalysisDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TodayAnalysisDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'date',
      'generatedAt',
      'summary',
      'bullets',
      'actionLabel',
      'confidenceNote',
    ],
  );
  final val = TodayAnalysisDataDto(
    date: $checkedConvert('date', (v) => v as String),
    generatedAt: $checkedConvert('generatedAt', (v) => v as String),
    summary: $checkedConvert('summary', (v) => v as String),
    bullets: $checkedConvert(
      'bullets',
      (v) => (v as List<dynamic>)
          .map(
            (e) => TodayAnalysisBulletDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    actionLabel: $checkedConvert('actionLabel', (v) => v as String),
    confidenceNote: $checkedConvert('confidenceNote', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$TodayAnalysisDataDtoToJson(
  TodayAnalysisDataDto instance,
) => <String, dynamic>{
  'date': instance.date,
  'generatedAt': instance.generatedAt,
  'summary': instance.summary,
  'bullets': instance.bullets.map((e) => e.toJson()).toList(),
  'actionLabel': instance.actionLabel,
  'confidenceNote': instance.confidenceNote,
};
