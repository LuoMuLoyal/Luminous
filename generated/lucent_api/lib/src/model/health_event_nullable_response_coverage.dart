//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_nullable_response_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventNullableResponseCoverage {
  /// Returns a new [HealthEventNullableResponseCoverage] instance.
  HealthEventNullableResponseCoverage({
    required this.checkInCount,

    required this.firstCheckInDate,

    required this.lastCheckInDate,
  });

  /// Number of user-confirmed daily check-ins.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'checkInCount', required: true, includeIfNull: false)
  final int checkInCount;

  /// First check-in calendar date, or null when none exists.
  @JsonKey(name: r'firstCheckInDate', required: true, includeIfNull: true)
  final String? firstCheckInDate;

  /// Last check-in calendar date, or null when none exists.
  @JsonKey(name: r'lastCheckInDate', required: true, includeIfNull: true)
  final String? lastCheckInDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventNullableResponseCoverage &&
          other.checkInCount == checkInCount &&
          other.firstCheckInDate == firstCheckInDate &&
          other.lastCheckInDate == lastCheckInDate;

  @override
  int get hashCode =>
      checkInCount.hashCode +
      (firstCheckInDate == null ? 0 : firstCheckInDate.hashCode) +
      (lastCheckInDate == null ? 0 : lastCheckInDate.hashCode);

  factory HealthEventNullableResponseCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthEventNullableResponseCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthEventNullableResponseCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
