// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_request_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataExportRequestDataDto _$DataExportRequestDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataExportRequestDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'kind',
      'format',
      'range',
      'status',
      'requestedAt',
    ],
  );
  final val = DataExportRequestDataDto(
    id: $checkedConvert('id', (v) => v as String),
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$DataExportKindEnumMap,
        v,
        unknownValue: DataExportKind.unknownDefaultOpenApi,
      ),
    ),
    format: $checkedConvert(
      'format',
      (v) => $enumDecode(
        _$DataExportFormatEnumMap,
        v,
        unknownValue: DataExportFormat.unknownDefaultOpenApi,
      ),
    ),
    range: $checkedConvert(
      'range',
      (v) => $enumDecode(
        _$DataExportRangeEnumMap,
        v,
        unknownValue: DataExportRange.unknownDefaultOpenApi,
      ),
    ),
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
    fileName: $checkedConvert('fileName', (v) => v as String?),
    fileSizeBytes: $checkedConvert('fileSizeBytes', (v) => v as num?),
    errorMessage: $checkedConvert('errorMessage', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$DataExportRequestDataDtoToJson(
  DataExportRequestDataDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': _$DataExportKindEnumMap[instance.kind]!,
  'format': _$DataExportFormatEnumMap[instance.format]!,
  'range': _$DataExportRangeEnumMap[instance.range]!,
  'status': _$DataExportStatusEnumMap[instance.status]!,
  'requestedAt': instance.requestedAt,
  if (instance.completedAt != null) 'completedAt': instance.completedAt,
  if (instance.downloadUrl != null) 'downloadUrl': instance.downloadUrl,
  if (instance.fileName != null) 'fileName': instance.fileName,
  if (instance.fileSizeBytes != null) 'fileSizeBytes': instance.fileSizeBytes,
  if (instance.errorMessage != null) 'errorMessage': instance.errorMessage,
};

const _$DataExportKindEnumMap = {
  DataExportKind.hospital: 'hospital',
  DataExportKind.monthly: 'monthly',
  DataExportKind.print: 'print',
  DataExportKind.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$DataExportFormatEnumMap = {
  DataExportFormat.pdf: 'pdf',
  DataExportFormat.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$DataExportRangeEnumMap = {
  DataExportRange.last7Days: 'last_7_days',
  DataExportRange.last30Days: 'last_30_days',
  DataExportRange.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$DataExportStatusEnumMap = {
  DataExportStatus.requested: 'requested',
  DataExportStatus.processing: 'processing',
  DataExportStatus.completed: 'completed',
  DataExportStatus.failed: 'failed',
  DataExportStatus.unavailable: 'unavailable',
  DataExportStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
