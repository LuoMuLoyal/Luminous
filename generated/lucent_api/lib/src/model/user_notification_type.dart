//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
enum UserNotificationType {
  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'ai_today_summary')
  aiTodaySummary(r'ai_today_summary'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'ai_weekly_insight')
  aiWeeklyInsight(r'ai_weekly_insight'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'ai_proactive_suggestion')
  aiProactiveSuggestion(r'ai_proactive_suggestion'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'medicine_missed_dose')
  medicineMissedDose(r'medicine_missed_dose'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'password_changed')
  passwordChanged(r'password_changed'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'report_generated')
  reportGenerated(r'report_generated'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'medicine_reminder')
  medicineReminder(r'medicine_reminder'),

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserNotificationType(this.value);

  final String value;

  @override
  String toString() => value;
}
