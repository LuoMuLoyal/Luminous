//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthSummary {
  /// Returns a new [HealthSummary] instance.
  HealthSummary({
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
      other is HealthSummary &&
          other.total == total &&
          other.passed == passed &&
          other.failed == failed;

  @override
  int get hashCode => total.hashCode + passed.hashCode + failed.hashCode;

  factory HealthSummary.fromJson(Map<String, dynamic> json) =>
      _$HealthSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$HealthSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
