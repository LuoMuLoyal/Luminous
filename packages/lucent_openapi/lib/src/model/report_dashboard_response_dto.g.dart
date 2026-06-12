// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dashboard_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDashboardResponseDto _$ReportDashboardResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportDashboardResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ReportDashboardResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => ReportDashboardDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ReportDashboardResponseDtoToJson(
  ReportDashboardResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
