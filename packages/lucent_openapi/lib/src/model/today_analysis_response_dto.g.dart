// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_analysis_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayAnalysisResponseDto _$TodayAnalysisResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TodayAnalysisResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = TodayAnalysisResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => TodayAnalysisDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$TodayAnalysisResponseDtoToJson(
  TodayAnalysisResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
