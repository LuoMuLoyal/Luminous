//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sse_problem_details_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SseProblemDetailsDto {
  /// Returns a new [SseProblemDetailsDto] instance.
  SseProblemDetailsDto({
    required this.type,

    required this.title,

    required this.detail,

    required this.code,

    this.errors,

    this.retryable,

    this.retryAfter,

    this.traceId,

    required this.status,
  });

  /// Stable URI identifying the problem type.
  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final String type;

  /// Localized short summary of the problem.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Localized, actionable description for this request.
  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final String detail;

  /// Stable machine-readable business code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Safe structured validation errors keyed by field or general.
  @JsonKey(name: r'errors', required: false, includeIfNull: false)
  final Map<String, Object>? errors;

  /// Whether retrying may succeed, subject to client policy.
  @JsonKey(name: r'retryable', required: false, includeIfNull: false)
  final bool? retryable;

  /// Minimum delay before retrying, in seconds.
  // minimum: 0
  @JsonKey(name: r'retryAfter', required: false, includeIfNull: false)
  final num? retryAfter;

  /// Trace correlation identifier; never a business key.
  @JsonKey(name: r'traceId', required: false, includeIfNull: false)
  final String? traceId;

  /// Why the stream ended; this is not an HTTP status code.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SseProblemDetailsDtoStatusEnum.unknownDefaultOpenApi,
  )
  final SseProblemDetailsDtoStatusEnum status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SseProblemDetailsDto &&
          other.type == type &&
          other.title == title &&
          other.detail == detail &&
          other.code == code &&
          other.errors == errors &&
          other.retryable == retryable &&
          other.retryAfter == retryAfter &&
          other.traceId == traceId &&
          other.status == status;

  @override
  int get hashCode =>
      type.hashCode +
      title.hashCode +
      detail.hashCode +
      code.hashCode +
      errors.hashCode +
      retryable.hashCode +
      retryAfter.hashCode +
      traceId.hashCode +
      status.hashCode;

  factory SseProblemDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$SseProblemDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SseProblemDetailsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Why the stream ended; this is not an HTTP status code.
enum SseProblemDetailsDtoStatusEnum {
  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'client_error')
  clientError(r'client_error'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'server_error')
  serverError(r'server_error'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'cancelled')
  cancelled(r'cancelled'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'server_shutdown')
  serverShutdown(r'server_shutdown'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'unknown')
  unknown(r'unknown'),

  /// Why the stream ended; this is not an HTTP status code.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SseProblemDetailsDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
