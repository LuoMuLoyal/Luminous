// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
@JsonEnum()
enum UserNotificationType {
  @JsonValue('ai_today_summary')
  aiTodaySummary('ai_today_summary'),
  @JsonValue('ai_proactive_suggestion')
  aiProactiveSuggestion('ai_proactive_suggestion'),
  @JsonValue('medicine_missed_dose')
  medicineMissedDose('medicine_missed_dose'),
  @JsonValue('password_changed')
  passwordChanged('password_changed'),
  @JsonValue('report_generated')
  reportGenerated('report_generated'),
  @JsonValue('medicine_reminder')
  medicineReminder('medicine_reminder'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const UserNotificationType(this.json);

  factory UserNotificationType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<UserNotificationType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
