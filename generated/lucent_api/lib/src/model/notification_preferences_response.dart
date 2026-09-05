//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferencesResponse {
  /// Returns a new [NotificationPreferencesResponse] instance.
  NotificationPreferencesResponse({
    required this.healthAlertsEnabled,

    required this.weeklyInsightEnabled,

    required this.waterRemindersEnabled,

    required this.sleepReminderEnabled,

    required this.sleepBedtimeMinutes,

    required this.sleepWakeTimeMinutes,

    required this.configured,

    required this.updatedAt,
  });

  @JsonKey(name: r'healthAlertsEnabled', required: true, includeIfNull: false)
  final bool healthAlertsEnabled;

  @JsonKey(name: r'weeklyInsightEnabled', required: true, includeIfNull: false)
  final bool weeklyInsightEnabled;

  @JsonKey(name: r'waterRemindersEnabled', required: true, includeIfNull: false)
  final bool waterRemindersEnabled;

  @JsonKey(name: r'sleepReminderEnabled', required: true, includeIfNull: false)
  final bool sleepReminderEnabled;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'sleepBedtimeMinutes', required: true, includeIfNull: true)
  final int? sleepBedtimeMinutes;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'sleepWakeTimeMinutes', required: true, includeIfNull: true)
  final int? sleepWakeTimeMinutes;

  /// Whether the user has a persisted preference row.
  @JsonKey(name: r'configured', required: true, includeIfNull: false)
  final bool configured;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: true)
  final String? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesResponse &&
          other.healthAlertsEnabled == healthAlertsEnabled &&
          other.weeklyInsightEnabled == weeklyInsightEnabled &&
          other.waterRemindersEnabled == waterRemindersEnabled &&
          other.sleepReminderEnabled == sleepReminderEnabled &&
          other.sleepBedtimeMinutes == sleepBedtimeMinutes &&
          other.sleepWakeTimeMinutes == sleepWakeTimeMinutes &&
          other.configured == configured &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      healthAlertsEnabled.hashCode +
      weeklyInsightEnabled.hashCode +
      waterRemindersEnabled.hashCode +
      sleepReminderEnabled.hashCode +
      (sleepBedtimeMinutes == null ? 0 : sleepBedtimeMinutes.hashCode) +
      (sleepWakeTimeMinutes == null ? 0 : sleepWakeTimeMinutes.hashCode) +
      configured.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode);

  factory NotificationPreferencesResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPreferencesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
