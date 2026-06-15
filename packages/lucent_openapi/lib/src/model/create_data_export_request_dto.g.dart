// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_data_export_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDataExportRequestDto _$CreateDataExportRequestDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateDataExportRequestDto', json, ($checkedConvert) {
  final val = CreateDataExportRequestDto(
    kind: $checkedConvert(
      'kind',
      (v) =>
          $enumDecodeNullable(
            _$CreateDataExportRequestDtoKindEnumEnumMap,
            v,
            unknownValue:
                CreateDataExportRequestDtoKindEnum.unknownDefaultOpenApi,
          ) ??
          CreateDataExportRequestDtoKindEnum.hospital,
    ),
    format: $checkedConvert(
      'format',
      (v) =>
          $enumDecodeNullable(
            _$CreateDataExportRequestDtoFormatEnumEnumMap,
            v,
            unknownValue:
                CreateDataExportRequestDtoFormatEnum.unknownDefaultOpenApi,
          ) ??
          CreateDataExportRequestDtoFormatEnum.pdf,
    ),
    range: $checkedConvert(
      'range',
      (v) =>
          $enumDecodeNullable(
            _$CreateDataExportRequestDtoRangeEnumEnumMap,
            v,
            unknownValue:
                CreateDataExportRequestDtoRangeEnum.unknownDefaultOpenApi,
          ) ??
          CreateDataExportRequestDtoRangeEnum.last7Days,
    ),
  );
  return val;
});

Map<String, dynamic> _$CreateDataExportRequestDtoToJson(
  CreateDataExportRequestDto instance,
) => <String, dynamic>{
  if (_$CreateDataExportRequestDtoKindEnumEnumMap[instance.kind] != null)
    'kind': _$CreateDataExportRequestDtoKindEnumEnumMap[instance.kind],
  if (_$CreateDataExportRequestDtoFormatEnumEnumMap[instance.format] != null)
    'format': _$CreateDataExportRequestDtoFormatEnumEnumMap[instance.format],
  if (_$CreateDataExportRequestDtoRangeEnumEnumMap[instance.range] != null)
    'range': _$CreateDataExportRequestDtoRangeEnumEnumMap[instance.range],
};

const _$CreateDataExportRequestDtoKindEnumEnumMap = {
  CreateDataExportRequestDtoKindEnum.hospital: 'hospital',
  CreateDataExportRequestDtoKindEnum.monthly: 'monthly',
  CreateDataExportRequestDtoKindEnum.print: 'print',
  CreateDataExportRequestDtoKindEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};

const _$CreateDataExportRequestDtoFormatEnumEnumMap = {
  CreateDataExportRequestDtoFormatEnum.pdf: 'pdf',
  CreateDataExportRequestDtoFormatEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};

const _$CreateDataExportRequestDtoRangeEnumEnumMap = {
  CreateDataExportRequestDtoRangeEnum.last7Days: 'last_7_days',
  CreateDataExportRequestDtoRangeEnum.last30Days: 'last_30_days',
  CreateDataExportRequestDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
