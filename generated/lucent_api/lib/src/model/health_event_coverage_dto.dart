//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_coverage_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventCoverageDto {
  /// Returns a new [HealthEventCoverageDto] instance.
  HealthEventCoverageDto({
    required this.checkInCount,

    this.firstCheckInDate,

    this.lastCheckInDate,
  });

  /// Number of user-confirmed daily check-ins.
  @JsonKey(name: r'checkInCount', required: true, includeIfNull: false)
  final num checkInCount;

  /// First check-in calendar date, or null when none exists.
  @JsonKey(name: r'firstCheckInDate', required: false, includeIfNull: false)
  final String? firstCheckInDate;

  /// Last check-in calendar date, or null when none exists.
  @JsonKey(name: r'lastCheckInDate', required: false, includeIfNull: false)
  final String? lastCheckInDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventCoverageDto &&
          other.checkInCount == checkInCount &&
          other.firstCheckInDate == firstCheckInDate &&
          other.lastCheckInDate == lastCheckInDate;

  @override
  int get hashCode =>
      checkInCount.hashCode +
      (firstCheckInDate == null ? 0 : firstCheckInDate.hashCode) +
      (lastCheckInDate == null ? 0 : lastCheckInDate.hashCode);

  factory HealthEventCoverageDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventCoverageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventCoverageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
