//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum UserNotificationType {
  @JsonValue(r'ai_today_summary')
  aiTodaySummary(r'ai_today_summary'),
  @JsonValue(r'ai_proactive_suggestion')
  aiProactiveSuggestion(r'ai_proactive_suggestion'),
  @JsonValue(r'medicine_missed_dose')
  medicineMissedDose(r'medicine_missed_dose'),
  @JsonValue(r'password_changed')
  passwordChanged(r'password_changed'),
  @JsonValue(r'report_generated')
  reportGenerated(r'report_generated'),
  @JsonValue(r'medicine_reminder')
  medicineReminder(r'medicine_reminder'),
  @JsonValue(r'system_announcement')
  systemAnnouncement(r'system_announcement'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserNotificationType(this.value);

  final String value;

  @override
  String toString() => value;
}
