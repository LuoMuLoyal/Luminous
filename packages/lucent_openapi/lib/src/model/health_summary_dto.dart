//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'health_summary_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthSummaryDto {
  /// Returns a new [HealthSummaryDto] instance.
  HealthSummaryDto({
    required this.total,

    required this.passed,

    required this.failed,
  });

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @JsonKey(name: r'passed', required: true, includeIfNull: false)
  final num passed;

  @JsonKey(name: r'failed', required: true, includeIfNull: false)
  final num failed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSummaryDto &&
          other.total == total &&
          other.passed == passed &&
          other.failed == failed;

  @override
  int get hashCode => total.hashCode + passed.hashCode + failed.hashCode;

  factory HealthSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$HealthSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
