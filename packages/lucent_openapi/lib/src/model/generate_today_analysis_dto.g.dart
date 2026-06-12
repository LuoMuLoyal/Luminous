// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_today_analysis_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateTodayAnalysisDto _$GenerateTodayAnalysisDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GenerateTodayAnalysisDto', json, ($checkedConvert) {
  final val = GenerateTodayAnalysisDto(
    date: $checkedConvert('date', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$GenerateTodayAnalysisDtoToJson(
  GenerateTodayAnalysisDto instance,
) => <String, dynamic>{'date': ?instance.date};
