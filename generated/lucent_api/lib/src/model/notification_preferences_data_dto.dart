//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_preferences_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationPreferencesDataDto {
  /// Returns a new [NotificationPreferencesDataDto] instance.
  NotificationPreferencesDataDto({
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

  @JsonKey(name: r'sleepBedtimeMinutes', required: true, includeIfNull: true)
  final num? sleepBedtimeMinutes;

  @JsonKey(name: r'sleepWakeTimeMinutes', required: true, includeIfNull: true)
  final num? sleepWakeTimeMinutes;

  /// Whether the user has a persisted preference row.
  @JsonKey(name: r'configured', required: true, includeIfNull: false)
  final bool configured;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: true)
  final String? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesDataDto &&
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

  factory NotificationPreferencesDataDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
