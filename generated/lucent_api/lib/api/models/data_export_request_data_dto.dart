// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'data_export_format.dart';
import 'data_export_kind.dart';
import 'data_export_range.dart';
import 'data_export_status.dart';

part 'data_export_request_data_dto.g.dart';

@JsonSerializable()
class DataExportRequestDataDto {
  const DataExportRequestDataDto({
    required this.id,
    required this.kind,
    required this.format,
    required this.range,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.downloadUrl,
    this.fileName,
    this.fileSizeBytes,
    this.errorMessage,
  });

  factory DataExportRequestDataDto.fromJson(Map<String, Object?> json) =>
      _$DataExportRequestDataDtoFromJson(json);

  /// Unique request identifier.
  final String id;
  final DataExportKind kind;
  final DataExportFormat format;
  final DataExportRange range;
  final DataExportStatus status;

  /// ISO-8601 timestamp when the request was created.
  final String requestedAt;
  final String? completedAt;
  final String? downloadUrl;
  final String? fileName;
  final num? fileSizeBytes;
  final String? errorMessage;

  Map<String, Object?> toJson() => _$DataExportRequestDataDtoToJson(this);
}
