//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patch_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchRequest {
  /// Returns a new [PatchRequest] instance.
  PatchRequest({
    this.isHealthAlertsEnabled,

    this.isWeeklyInsightEnabled,

    this.isWaterRemindersEnabled,

    this.isSleepReminderEnabled,

    this.sleepBedtimeMinutes,

    this.sleepWakeTimeMinutes,
  });

  /// Enable health-rule notifications.
  @JsonKey(
    name: r'isHealthAlertsEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? isHealthAlertsEnabled;

  /// Enable weekly longitudinal insights.
  @JsonKey(
    name: r'isWeeklyInsightEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? isWeeklyInsightEnabled;

  /// Enable water shortfall notifications.
  @JsonKey(
    name: r'isWaterRemindersEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? isWaterRemindersEnabled;

  /// Enable local bedtime sleep reminders.
  @JsonKey(
    name: r'isSleepReminderEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? isSleepReminderEnabled;

  /// Bedtime as minutes after local midnight.
  // minimum: 0
  // maximum: 1439
  @JsonKey(name: r'sleepBedtimeMinutes', required: false, includeIfNull: false)
  final int? sleepBedtimeMinutes;

  /// Wake time as minutes after local midnight.
  // minimum: 0
  // maximum: 1439
  @JsonKey(name: r'sleepWakeTimeMinutes', required: false, includeIfNull: false)
  final int? sleepWakeTimeMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchRequest &&
          other.isHealthAlertsEnabled == isHealthAlertsEnabled &&
          other.isWeeklyInsightEnabled == isWeeklyInsightEnabled &&
          other.isWaterRemindersEnabled == isWaterRemindersEnabled &&
          other.isSleepReminderEnabled == isSleepReminderEnabled &&
          other.sleepBedtimeMinutes == sleepBedtimeMinutes &&
          other.sleepWakeTimeMinutes == sleepWakeTimeMinutes;

  @override
  int get hashCode =>
      isHealthAlertsEnabled.hashCode +
      isWeeklyInsightEnabled.hashCode +
      isWaterRemindersEnabled.hashCode +
      isSleepReminderEnabled.hashCode +
      (sleepBedtimeMinutes == null ? 0 : sleepBedtimeMinutes.hashCode) +
      (sleepWakeTimeMinutes == null ? 0 : sleepWakeTimeMinutes.hashCode);

  factory PatchRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PatchRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
