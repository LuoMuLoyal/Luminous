// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_report_weekly_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateReportWeeklySummaryDto _$GenerateReportWeeklySummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GenerateReportWeeklySummaryDto', json, ($checkedConvert) {
  final val = GenerateReportWeeklySummaryDto(
    range: $checkedConvert(
      'range',
      (v) => $enumDecodeNullable(
        _$GenerateReportWeeklySummaryDtoRangeEnumEnumMap,
        v,
        unknownValue:
            GenerateReportWeeklySummaryDtoRangeEnum.unknownDefaultOpenApi,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$GenerateReportWeeklySummaryDtoToJson(
  GenerateReportWeeklySummaryDto instance,
) => <String, dynamic>{
  if (_$GenerateReportWeeklySummaryDtoRangeEnumEnumMap[instance.range] != null)
    'range': _$GenerateReportWeeklySummaryDtoRangeEnumEnumMap[instance.range],
};

const _$GenerateReportWeeklySummaryDtoRangeEnumEnumMap = {
  GenerateReportWeeklySummaryDtoRangeEnum.last7Days: 'last_7_days',
  GenerateReportWeeklySummaryDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
