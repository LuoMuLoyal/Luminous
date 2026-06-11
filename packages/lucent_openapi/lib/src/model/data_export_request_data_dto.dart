//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/data_export_status.dart';
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

    required this.status,

    required this.requestedAt,

    this.completedAt,

    this.downloadUrl,

    this.errorMessage,
  });

  /// Unique request identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

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

  @JsonKey(name: r'errorMessage', required: false, includeIfNull: false)
  final String? errorMessage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataExportRequestDataDto &&
          other.id == id &&
          other.status == status &&
          other.requestedAt == requestedAt &&
          other.completedAt == completedAt &&
          other.downloadUrl == downloadUrl &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode =>
      id.hashCode +
      status.hashCode +
      requestedAt.hashCode +
      (completedAt == null ? 0 : completedAt.hashCode) +
      (downloadUrl == null ? 0 : downloadUrl.hashCode) +
      (errorMessage == null ? 0 : errorMessage.hashCode);

  factory DataExportRequestDataDto.fromJson(Map<String, dynamic> json) =>
      _$DataExportRequestDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DataExportRequestDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
