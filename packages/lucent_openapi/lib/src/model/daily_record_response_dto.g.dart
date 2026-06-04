// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordResponseDto _$DailyRecordResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DailyRecordResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DailyRecordItemDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordResponseDtoToJson(
  DailyRecordResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
