//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_export_request_data_dto.g.dart';

@CopyWith()
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

    required this.completedAt,

    required this.downloadUrl,

    required this.fileName,

    required this.fileSizeBytes,

    required this.errorMessage,
  });

  /// Unique request identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportRequestDataDtoKindEnum.unknownDefaultOpenApi,
  )
  final DataExportRequestDataDtoKindEnum kind;

  @JsonKey(
    name: r'format',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportRequestDataDtoFormatEnum.unknownDefaultOpenApi,
  )
  final DataExportRequestDataDtoFormatEnum format;

  @JsonKey(
    name: r'range',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportRequestDataDtoRangeEnum.unknownDefaultOpenApi,
  )
  final DataExportRequestDataDtoRangeEnum range;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DataExportRequestDataDtoStatusEnum.unknownDefaultOpenApi,
  )
  final DataExportRequestDataDtoStatusEnum status;

  /// ISO-8601 timestamp when the request was created.
  @JsonKey(name: r'requestedAt', required: true, includeIfNull: false)
  final String requestedAt;

  @JsonKey(name: r'completedAt', required: true, includeIfNull: true)
  final String? completedAt;

  @JsonKey(name: r'downloadUrl', required: true, includeIfNull: true)
  final String? downloadUrl;

  @JsonKey(name: r'fileName', required: true, includeIfNull: true)
  final String? fileName;

  @JsonKey(name: r'fileSizeBytes', required: true, includeIfNull: true)
  final num? fileSizeBytes;

  @JsonKey(name: r'errorMessage', required: true, includeIfNull: true)
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

enum DataExportRequestDataDtoKindEnum {
  @JsonValue(r'hospital')
  hospital(r'hospital'),
  @JsonValue(r'monthly')
  monthly(r'monthly'),
  @JsonValue(r'print')
  print(r'print'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportRequestDataDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum DataExportRequestDataDtoFormatEnum {
  @JsonValue(r'pdf')
  pdf(r'pdf'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportRequestDataDtoFormatEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum DataExportRequestDataDtoRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportRequestDataDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum DataExportRequestDataDtoStatusEnum {
  @JsonValue(r'requested')
  requested(r'requested'),
  @JsonValue(r'processing')
  processing(r'processing'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportRequestDataDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
