// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_candidate_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordCandidateResponseDto _$DailyRecordCandidateResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordCandidateResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DailyRecordCandidateResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DailyRecordCandidateDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordCandidateResponseDtoToJson(
  DailyRecordCandidateResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
