// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_report_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateReportSummaryDto _$GenerateReportSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('GenerateReportSummaryDto', json, ($checkedConvert) {
  final val = GenerateReportSummaryDto(
    range: $checkedConvert(
      'range',
      (v) => $enumDecodeNullable(
        _$GenerateReportSummaryDtoRangeEnumEnumMap,
        v,
        unknownValue: GenerateReportSummaryDtoRangeEnum.unknownDefaultOpenApi,
      ),
    ),
    startDate: $checkedConvert('startDate', (v) => v as String?),
    endDate: $checkedConvert('endDate', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$GenerateReportSummaryDtoToJson(
  GenerateReportSummaryDto instance,
) => <String, dynamic>{
  if (_$GenerateReportSummaryDtoRangeEnumEnumMap[instance.range] != null)
    'range': _$GenerateReportSummaryDtoRangeEnumEnumMap[instance.range],
  if (instance.startDate != null) 'startDate': instance.startDate,
  if (instance.endDate != null) 'endDate': instance.endDate,
};

const _$GenerateReportSummaryDtoRangeEnumEnumMap = {
  GenerateReportSummaryDtoRangeEnum.last7Days: 'last_7_days',
  GenerateReportSummaryDtoRangeEnum.last30Days: 'last_30_days',
  GenerateReportSummaryDtoRangeEnum.custom: 'custom',
  GenerateReportSummaryDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
