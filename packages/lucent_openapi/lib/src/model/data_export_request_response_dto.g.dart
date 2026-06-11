// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_export_request_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataExportRequestResponseDto _$DataExportRequestResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataExportRequestResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = DataExportRequestResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => DataExportRequestDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DataExportRequestResponseDtoToJson(
  DataExportRequestResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
