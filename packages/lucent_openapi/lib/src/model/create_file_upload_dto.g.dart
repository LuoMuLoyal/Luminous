// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_file_upload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateFileUploadDto _$CreateFileUploadDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CreateFileUploadDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['contentType', 'sizeBytes']);
      final val = CreateFileUploadDto(
        contentType: $checkedConvert('contentType', (v) => v as String),
        sizeBytes: $checkedConvert('sizeBytes', (v) => v as num),
        fileName: $checkedConvert('fileName', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CreateFileUploadDtoToJson(
  CreateFileUploadDto instance,
) => <String, dynamic>{
  'contentType': instance.contentType,
  'sizeBytes': instance.sizeBytes,
  if (instance.fileName != null) 'fileName': instance.fileName,
};
