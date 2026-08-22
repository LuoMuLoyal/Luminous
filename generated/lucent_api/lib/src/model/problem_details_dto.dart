//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'problem_details_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProblemDetailsDto {
  /// Returns a new [ProblemDetailsDto] instance.
  ProblemDetailsDto({
    required this.type,

    required this.title,

    required this.detail,

    required this.code,

    this.errors,

    this.retryable,

    this.retryAfter,

    this.traceId,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemDetailsDto &&
          other.type == type &&
          other.title == title &&
          other.detail == detail &&
          other.code == code &&
          other.errors == errors &&
          other.retryable == retryable &&
          other.retryAfter == retryAfter &&
          other.traceId == traceId;

  @override
  int get hashCode =>
      type.hashCode +
      title.hashCode +
      detail.hashCode +
      code.hashCode +
      errors.hashCode +
      retryable.hashCode +
      retryAfter.hashCode +
      traceId.hashCode;

  factory ProblemDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProblemDetailsDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
