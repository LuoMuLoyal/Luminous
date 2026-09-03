//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_controller_patch_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferencesControllerPatchV1Request {
  /// Returns a new [NotificationPreferencesControllerPatchV1Request] instance.
  NotificationPreferencesControllerPatchV1Request({
    this.healthAlertsEnabled,

    this.weeklyInsightEnabled,

    this.waterRemindersEnabled,

    this.sleepReminderEnabled,

    this.sleepBedtimeMinutes,

    this.sleepWakeTimeMinutes,
  });

  /// Enable health-rule notifications.
  @JsonKey(name: r'healthAlertsEnabled', required: false, includeIfNull: false)
  final bool? healthAlertsEnabled;

  /// Enable weekly longitudinal insights.
  @JsonKey(name: r'weeklyInsightEnabled', required: false, includeIfNull: false)
  final bool? weeklyInsightEnabled;

  /// Enable water shortfall notifications.
  @JsonKey(
    name: r'waterRemindersEnabled',
    required: false,
    includeIfNull: false,
  )
  final bool? waterRemindersEnabled;

  /// Enable local bedtime sleep reminders.
  @JsonKey(name: r'sleepReminderEnabled', required: false, includeIfNull: false)
  final bool? sleepReminderEnabled;

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
      other is NotificationPreferencesControllerPatchV1Request &&
          other.healthAlertsEnabled == healthAlertsEnabled &&
          other.weeklyInsightEnabled == weeklyInsightEnabled &&
          other.waterRemindersEnabled == waterRemindersEnabled &&
          other.sleepReminderEnabled == sleepReminderEnabled &&
          other.sleepBedtimeMinutes == sleepBedtimeMinutes &&
          other.sleepWakeTimeMinutes == sleepWakeTimeMinutes;

  @override
  int get hashCode =>
      healthAlertsEnabled.hashCode +
      weeklyInsightEnabled.hashCode +
      waterRemindersEnabled.hashCode +
      sleepReminderEnabled.hashCode +
      (sleepBedtimeMinutes == null ? 0 : sleepBedtimeMinutes.hashCode) +
      (sleepWakeTimeMinutes == null ? 0 : sleepWakeTimeMinutes.hashCode);

  factory NotificationPreferencesControllerPatchV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationPreferencesControllerPatchV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesControllerPatchV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
