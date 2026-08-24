//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_data_export_request_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDataExportRequestDto {
  /// Returns a new [CreateDataExportRequestDto] instance.
  CreateDataExportRequestDto({
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
    unknownEnumValue: CreateDataExportRequestDtoKindEnum.unknownDefaultOpenApi,
  )
  final CreateDataExportRequestDtoKindEnum? kind;

  /// Requested export format.
  @JsonKey(
    name: r'format',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        CreateDataExportRequestDtoFormatEnum.unknownDefaultOpenApi,
  )
  final CreateDataExportRequestDtoFormatEnum? format;

  /// Requested report range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: CreateDataExportRequestDtoRangeEnum.unknownDefaultOpenApi,
  )
  final CreateDataExportRequestDtoRangeEnum? range;

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDataExportRequestDto &&
          other.kind == kind &&
          other.format == format &&
          other.range == range &&
          other.password == password;

  @override
  int get hashCode =>
      kind.hashCode + format.hashCode + range.hashCode + password.hashCode;

  factory CreateDataExportRequestDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDataExportRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDataExportRequestDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Requested export kind.
enum CreateDataExportRequestDtoKindEnum {
  /// Requested export kind.
  @JsonValue(r'hospital')
  hospital(r'hospital'),

  /// Requested export kind.
  @JsonValue(r'monthly')
  monthly(r'monthly'),

  /// Requested export kind.
  @JsonValue(r'print')
  print(r'print'),

  /// Requested export kind.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateDataExportRequestDtoKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested export format.
enum CreateDataExportRequestDtoFormatEnum {
  /// Requested export format.
  @JsonValue(r'pdf')
  pdf(r'pdf'),

  /// Requested export format.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateDataExportRequestDtoFormatEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested report range.
enum CreateDataExportRequestDtoRangeEnum {
  /// Requested report range.
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),

  /// Requested report range.
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),

  /// Requested report range.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateDataExportRequestDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
