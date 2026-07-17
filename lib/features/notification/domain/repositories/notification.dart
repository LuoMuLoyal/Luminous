import '../entities/notification.dart';

/// Repository interface for user notifications.
///
/// All methods require an authenticated session; callers should guard with
/// [authGuarded] or equivalent session checks at the provider layer.
abstract interface class NotificationRepository {
  /// Returns a single page of notifications.
  Future<NotificationPage> findAll({required int page, required int pageSize});

  /// Returns the full detail of a single notification, or null if not found.
  Future<NotificationDetail?> findOne(String id);

  /// Returns the count of unread notifications for the current user.
  Future<int> getUnreadCount();

  /// Marks all notifications as read.
  Future<void> markAllAsRead();

  /// Marks a single notification as unread.
  Future<void> markAsUnread(String id);

  /// Deletes a notification by id.
  Future<void> delete(String id);
}
