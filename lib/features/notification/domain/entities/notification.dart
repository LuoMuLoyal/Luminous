/// Notification type identifiers, mirroring the backend enum.
///
/// Domain-level enum decoupled from the generated [UserNotificationType].
/// The `$unknown` sentinel preserves forward compatibility when the backend
/// adds new notification types.
enum NotificationType {
  aiTodaySummary,
  aiProactiveSuggestion,
  medicineMissedDose,
  passwordChanged,
  reportGenerated,
  medicineReminder,
  systemAnnouncement,
  oauthLogin,
  identityLinked,
  unknown;

  /// Maps from the backend string value.
  static NotificationType fromJson(String? json) {
    return switch (json) {
      'ai_today_summary' => NotificationType.aiTodaySummary,
      'ai_proactive_suggestion' => NotificationType.aiProactiveSuggestion,
      'medicine_missed_dose' => NotificationType.medicineMissedDose,
      'password_changed' => NotificationType.passwordChanged,
      'report_generated' => NotificationType.reportGenerated,
      'medicine_reminder' => NotificationType.medicineReminder,
      'system_announcement' => NotificationType.systemAnnouncement,
      'oauth_login' => NotificationType.oauthLogin,
      'identity_linked' => NotificationType.identityLinked,
      _ => NotificationType.unknown,
    };
  }
}

/// A notification list item shown in the inbox.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.action,
    this.actionPayload,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String? action;

  /// Extra payload for the action (opaque to the domain layer).
  final dynamic actionPayload;
  final bool isRead;

  /// ISO-8601 timestamp.
  final String createdAt;

  /// Returns a copy with updated fields.
  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? content,
    String? action,
    dynamic actionPayload,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      action: action ?? this.action,
      actionPayload: actionPayload ?? this.actionPayload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Full notification detail with read timestamp.
class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.action,
    this.actionPayload,
    this.readAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String? action;
  final dynamic actionPayload;
  final bool isRead;

  /// ISO-8601 timestamp.
  final String createdAt;

  /// ISO-8601 timestamp when the notification was read, or null.
  final String? readAt;
}

/// A page of notification list results.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<NotificationItem> items;

  /// Total notification count for the user.
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => items.length < total;
}
