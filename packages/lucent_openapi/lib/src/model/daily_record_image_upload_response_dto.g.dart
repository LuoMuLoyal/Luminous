// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_image_upload_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordImageUploadResponseDto _$DailyRecordImageUploadResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordImageUploadResponseDto', json, (
  $checkedConvert,
) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DailyRecordImageUploadResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DailyRecordImageUploadDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordImageUploadResponseDtoToJson(
  DailyRecordImageUploadResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
