// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordListResponseDto _$DailyRecordListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DailyRecordListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DailyRecordListDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordListResponseDtoToJson(
  DailyRecordListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
