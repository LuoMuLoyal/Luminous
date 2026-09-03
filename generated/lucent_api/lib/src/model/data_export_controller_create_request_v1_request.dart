//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_export_controller_create_request_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataExportControllerCreateRequestV1Request {
  /// Returns a new [DataExportControllerCreateRequestV1Request] instance.
  DataExportControllerCreateRequestV1Request({
    this.kind,

    this.format,

    this.range,

    required this.password,
  });

  /// Requested export kind.
  @JsonKey(
    name: r'kind',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DataExportControllerCreateRequestV1RequestKindEnum
        .unknownDefaultOpenApi,
  )
  final DataExportControllerCreateRequestV1RequestKindEnum? kind;

  /// Requested export format.
  @JsonKey(
    name: r'format',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DataExportControllerCreateRequestV1RequestFormatEnum
        .unknownDefaultOpenApi,
  )
  final DataExportControllerCreateRequestV1RequestFormatEnum? format;

  /// Requested report range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: DataExportControllerCreateRequestV1RequestRangeEnum
        .unknownDefaultOpenApi,
  )
  final DataExportControllerCreateRequestV1RequestRangeEnum? range;

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataExportControllerCreateRequestV1Request &&
          other.kind == kind &&
          other.format == format &&
          other.range == range &&
          other.password == password;

  @override
  int get hashCode =>
      kind.hashCode + format.hashCode + range.hashCode + password.hashCode;

  factory DataExportControllerCreateRequestV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$DataExportControllerCreateRequestV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DataExportControllerCreateRequestV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Requested export kind.
enum DataExportControllerCreateRequestV1RequestKindEnum {
  @JsonValue(r'hospital')
  hospital(r'hospital'),
  @JsonValue(r'monthly')
  monthly(r'monthly'),
  @JsonValue(r'print')
  print(r'print'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportControllerCreateRequestV1RequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested export format.
enum DataExportControllerCreateRequestV1RequestFormatEnum {
  @JsonValue(r'pdf')
  pdf(r'pdf'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportControllerCreateRequestV1RequestFormatEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested report range.
enum DataExportControllerCreateRequestV1RequestRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportControllerCreateRequestV1RequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
