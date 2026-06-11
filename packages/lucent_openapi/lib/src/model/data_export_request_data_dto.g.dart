// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_request_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataExportRequestDataDto _$DataExportRequestDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataExportRequestDataDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'status', 'requestedAt']);
  final val = DataExportRequestDataDto(
    id: $checkedConvert('id', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$DataExportStatusEnumMap,
        v,
        unknownValue: DataExportStatus.unknownDefaultOpenApi,
      ),
    ),
    requestedAt: $checkedConvert('requestedAt', (v) => v as String),
    completedAt: $checkedConvert('completedAt', (v) => v as String?),
    downloadUrl: $checkedConvert('downloadUrl', (v) => v as String?),
    errorMessage: $checkedConvert('errorMessage', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DataExportRequestDataDtoToJson(
  DataExportRequestDataDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$DataExportStatusEnumMap[instance.status]!,
  'requestedAt': instance.requestedAt,
  if (instance.completedAt != null) 'completedAt': instance.completedAt,
  if (instance.downloadUrl != null) 'downloadUrl': instance.downloadUrl,
  if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
};

const _$DataExportStatusEnumMap = {
  DataExportStatus.requested: 'requested',
  DataExportStatus.processing: 'processing',
  DataExportStatus.completed: 'completed',
  DataExportStatus.failed: 'failed',
  DataExportStatus.unavailable: 'unavailable',
  DataExportStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
