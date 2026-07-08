// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'data_export_request_data_dto.dart';

part 'data_export_request_response_dto.g.dart';

@JsonSerializable()
class DataExportRequestResponseDto {
  const DataExportRequestResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DataExportRequestResponseDto.fromJson(Map<String, Object?> json) =>
      _$DataExportRequestResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final DataExportRequestDataDto data;

  Map<String, Object?> toJson() => _$DataExportRequestResponseDtoToJson(this);
}
