// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_image_upload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordImageUploadDto _$DailyRecordImageUploadDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordImageUploadDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'provider',
      'bucket',
      'objectKey',
      'uploadUrl',
      'headers',
      'publicUrl',
      'expiresAt',
      'maxSizeBytes',
    ],
  );
  final val = DailyRecordImageUploadDto(
    provider: $checkedConvert('provider', (v) => v as String),
    bucket: $checkedConvert('bucket', (v) => v as String),
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    uploadUrl: $checkedConvert('uploadUrl', (v) => v as String),
    headers: $checkedConvert('headers', (v) => v as Object),
    publicUrl: $checkedConvert('publicUrl', (v) => v as Object),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
    maxSizeBytes: $checkedConvert('maxSizeBytes', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordImageUploadDtoToJson(
  DailyRecordImageUploadDto instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'bucket': instance.bucket,
  'objectKey': instance.objectKey,
  'uploadUrl': instance.uploadUrl,
  'headers': instance.headers,
  'publicUrl': instance.publicUrl,
  'expiresAt': instance.expiresAt,
  'maxSizeBytes': instance.maxSizeBytes,
};
