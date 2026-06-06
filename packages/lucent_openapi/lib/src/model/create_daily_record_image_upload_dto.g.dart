// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_daily_record_image_upload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDailyRecordImageUploadDto _$CreateDailyRecordImageUploadDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateDailyRecordImageUploadDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['contentType', 'sizeBytes']);
  final val = CreateDailyRecordImageUploadDto(
    contentType: $checkedConvert('contentType', (v) => v as String),
    sizeBytes: $checkedConvert('sizeBytes', (v) => v as num),
    fileName: $checkedConvert('fileName', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$CreateDailyRecordImageUploadDtoToJson(
  CreateDailyRecordImageUploadDto instance,
) => <String, dynamic>{
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
  if (instance.fileName != null) 'fileName': instance.fileName,
};
