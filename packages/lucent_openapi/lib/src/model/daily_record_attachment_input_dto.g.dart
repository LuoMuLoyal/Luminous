// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_attachment_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordAttachmentInputDto _$DailyRecordAttachmentInputDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordAttachmentInputDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['objectKey']);
  final val = DailyRecordAttachmentInputDto(
    kind: $checkedConvert(
      'kind',
      (v) =>
          $enumDecodeNullable(
            _$DailyRecordAttachmentKindEnumMap,
            v,
            unknownValue: DailyRecordAttachmentKind.unknownDefaultOpenApi,
          ) ??
          DailyRecordAttachmentKind.image,
    ),
    objectKey: $checkedConvert('objectKey', (v) => v as String),
    bucket: $checkedConvert('bucket', (v) => v),
    provider: $checkedConvert('provider', (v) => v),
    fileName: $checkedConvert('fileName', (v) => v),
    contentType: $checkedConvert('contentType', (v) => v),
    sizeBytes: $checkedConvert('sizeBytes', (v) => v),
    width: $checkedConvert('width', (v) => v),
    height: $checkedConvert('height', (v) => v),
    publicUrl: $checkedConvert('publicUrl', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordAttachmentInputDtoToJson(
  DailyRecordAttachmentInputDto instance,
) => <String, dynamic>{
  if (_$DailyRecordAttachmentKindEnumMap[instance.kind] != null)
    'kind': _$DailyRecordAttachmentKindEnumMap[instance.kind],
  'objectKey': instance.objectKey,
  if (instance.bucket != null) 'bucket': instance.bucket,
  if (instance.provider != null) 'provider': instance.provider,
  if (instance.fileName != null) 'fileName': instance.fileName,
  if (instance.contentType != null) 'contentType': instance.contentType,
  if (instance.sizeBytes != null) 'sizeBytes': instance.sizeBytes,
  if (instance.width != null) 'width': instance.width,
  if (instance.height != null) 'height': instance.height,
  if (instance.publicUrl != null) 'publicUrl': instance.publicUrl,
};

const _$DailyRecordAttachmentKindEnumMap = {
  DailyRecordAttachmentKind.image: 'image',
  DailyRecordAttachmentKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};
