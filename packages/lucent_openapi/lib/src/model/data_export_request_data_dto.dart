//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/data_export_status.dart';
import 'package:lucent_openapi/src/model/data_export_range.dart';
import 'package:lucent_openapi/src/model/data_export_format.dart';
import 'package:lucent_openapi/src/model/data_export_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_export_request_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataExportRequestDataDto {
  /// Returns a new [DataExportRequestDataDto] instance.
  DataExportRequestDataDto({
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

  /// Unique request identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportKind.unknownDefaultOpenApi,
  )
  final DataExportKind kind;

  @JsonKey(
    name: r'format',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportFormat.unknownDefaultOpenApi,
  )
  final DataExportFormat format;

  @JsonKey(
    name: r'range',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportRange.unknownDefaultOpenApi,
  )
  final DataExportRange range;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportStatus.unknownDefaultOpenApi,
  )
  final DataExportStatus status;

  /// ISO-8601 timestamp when the request was created.
  @JsonKey(name: r'requestedAt', required: true, includeIfNull: false)
  final String requestedAt;

  @JsonKey(name: r'completedAt', required: false, includeIfNull: false)
  final String? completedAt;

  @JsonKey(name: r'downloadUrl', required: false, includeIfNull: false)
  final String? downloadUrl;

  @JsonKey(name: r'fileName', required: false, includeIfNull: false)
  final String? fileName;

  @JsonKey(name: r'fileSizeBytes', required: false, includeIfNull: false)
  final num? fileSizeBytes;

  @JsonKey(name: r'errorMessage', required: false, includeIfNull: false)
  final String? errorMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataExportRequestDataDto &&
          other.id == id &&
          other.kind == kind &&
          other.format == format &&
          other.range == range &&
          other.status == status &&
          other.requestedAt == requestedAt &&
          other.completedAt == completedAt &&
          other.downloadUrl == downloadUrl &&
          other.fileName == fileName &&
          other.fileSizeBytes == fileSizeBytes &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      format.hashCode +
      range.hashCode +
      status.hashCode +
      requestedAt.hashCode +
      (completedAt == null ? 0 : completedAt.hashCode) +
      (downloadUrl == null ? 0 : downloadUrl.hashCode) +
      (fileName == null ? 0 : fileName.hashCode) +
      (fileSizeBytes == null ? 0 : fileSizeBytes.hashCode) +
      (errorMessage == null ? 0 : errorMessage.hashCode);

  factory DataExportRequestDataDto.fromJson(Map<String, dynamic> json) =>
      _$DataExportRequestDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DataExportRequestDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
