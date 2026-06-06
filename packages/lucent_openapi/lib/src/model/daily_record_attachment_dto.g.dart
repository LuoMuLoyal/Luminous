// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_attachment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordAttachmentDto _$DailyRecordAttachmentDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordAttachmentDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'kind', 'objectKey', 'createdAt'],
  );
  final val = DailyRecordAttachmentDto(
    id: $checkedConvert('id', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$DailyRecordAttachmentKindEnumMap,
        v,
        unknownValue: DailyRecordAttachmentKind.unknownDefaultOpenApi,
      ),
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
    createdAt: $checkedConvert('createdAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordAttachmentDtoToJson(
  DailyRecordAttachmentDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': _$DailyRecordAttachmentKindEnumMap[instance.kind]!,
  'objectKey': instance.objectKey,
  if (instance.bucket != null) 'bucket': instance.bucket,
  if (instance.provider != null) 'provider': instance.provider,
  if (instance.fileName != null) 'fileName': instance.fileName,
  if (instance.contentType != null) 'contentType': instance.contentType,
  if (instance.sizeBytes != null) 'sizeBytes': instance.sizeBytes,
  if (instance.width != null) 'width': instance.width,
  if (instance.height != null) 'height': instance.height,
  if (instance.publicUrl != null) 'publicUrl': instance.publicUrl,
  'createdAt': instance.createdAt,
};

const _$DailyRecordAttachmentKindEnumMap = {
  DailyRecordAttachmentKind.image: 'image',
  DailyRecordAttachmentKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};
