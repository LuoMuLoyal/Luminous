import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification type identifiers, mirroring the backend enum.
///
/// Domain-level enum decoupled from the generated [UserNotificationType].
/// The `unknown` sentinel preserves forward compatibility when the backend
/// adds new notification types.
@JsonEnum(valueField: 'wire')
enum NotificationType {
  aiTodaySummary('ai_today_summary'),
  aiWeeklyInsight('ai_weekly_insight'),
  aiProactiveSuggestion('ai_proactive_suggestion'),
  medicineMissedDose('medicine_missed_dose'),
  passwordChanged('password_changed'),
  reportGenerated('report_generated'),
  medicineReminder('medicine_reminder'),
  systemAnnouncement('system_announcement'),
  oauthLogin('oauth_login'),
  identityLinked('identity_linked'),
  unknown('');

  const NotificationType(this.wire);

  /// Backend string value.
  final String wire;

  /// Maps from the backend string value.
  static NotificationType fromWire(String? value) {
    for (final type in NotificationType.values) {
      if (type != NotificationType.unknown && type.wire == value) {
        return type;
      }
    }
    return NotificationType.unknown;
  }
}

/// A notification list item shown in the inbox.
@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required NotificationType type,
    required String title,
    required String content,
    required bool isRead,

    /// ISO-8601 timestamp.
    required String createdAt,
    String? action,

    /// Extra payload for the action (opaque to the domain layer).
    Object? actionPayload,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

/// Full notification detail with read timestamp.
@freezed
abstract class NotificationDetail with _$NotificationDetail {
  const factory NotificationDetail({
    required String id,
    required NotificationType type,
    required String title,
    required String content,
    required bool isRead,

    /// ISO-8601 timestamp.
    required String createdAt,
    String? action,
    Object? actionPayload,

    /// ISO-8601 timestamp when the notification was read, or null.
    String? readAt,
  }) = _NotificationDetail;

  factory NotificationDetail.fromJson(Map<String, dynamic> json) =>
      _$NotificationDetailFromJson(json);
}

/// A page of notification list results.
@freezed
abstract class NotificationPage with _$NotificationPage {
  const NotificationPage._();

  const factory NotificationPage({
    required List<NotificationItem> items,

    /// Total notification count for the user.
    required int total,
    required int page,
    required int pageSize,
  }) = _NotificationPage;

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      _$NotificationPageFromJson(json);

  bool get hasMore => items.length < total;
}
