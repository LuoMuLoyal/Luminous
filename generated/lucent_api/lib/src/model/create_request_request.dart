//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_request_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateRequestRequest {
  /// Returns a new [CreateRequestRequest] instance.
  CreateRequestRequest({
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
    unknownEnumValue: CreateRequestRequestKindEnum.unknownDefaultOpenApi,
  )
  final CreateRequestRequestKindEnum? kind;

  /// Requested export format.
  @JsonKey(
    name: r'format',
    required: false,
    includeIfNull: false,
    unknownEnumValue: CreateRequestRequestFormatEnum.unknownDefaultOpenApi,
  )
  final CreateRequestRequestFormatEnum? format;

  /// Requested report range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: CreateRequestRequestRangeEnum.unknownDefaultOpenApi,
  )
  final CreateRequestRequestRangeEnum? range;

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRequestRequest &&
          other.kind == kind &&
          other.format == format &&
          other.range == range &&
          other.password == password;

  @override
  int get hashCode =>
      kind.hashCode + format.hashCode + range.hashCode + password.hashCode;

  factory CreateRequestRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRequestRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRequestRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Requested export kind.
enum CreateRequestRequestKindEnum {
  @JsonValue(r'hospital')
  hospital(r'hospital'),
  @JsonValue(r'monthly')
  monthly(r'monthly'),
  @JsonValue(r'print')
  print(r'print'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateRequestRequestKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested export format.
enum CreateRequestRequestFormatEnum {
  @JsonValue(r'pdf')
  pdf(r'pdf'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateRequestRequestFormatEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// Requested report range.
enum CreateRequestRequestRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const CreateRequestRequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
