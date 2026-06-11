// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_latest_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataExportLatestResponseDto _$DataExportLatestResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataExportLatestResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DataExportLatestResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => v == null
          ? null
          : DataExportRequestDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DataExportLatestResponseDtoToJson(
  DataExportLatestResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data?.toJson(),
};
