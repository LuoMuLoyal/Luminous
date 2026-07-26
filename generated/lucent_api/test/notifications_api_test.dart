import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for NotificationsApi
void main() {
  final instance = LucentApi().getNotificationsApi();

  group(NotificationsApi, () {
    // Create a notification (internal/test)
    //
    //Future<NotificationListResponseDto> notificationsControllerCreateV1(CreateNotificationDto createNotificationDto) async
    test('test notificationsControllerCreateV1', () async {
      // TODO
    });

    // List user notifications
    //
    //Future<NotificationListResponseDto> notificationsControllerFindAllV1(num page, num pageSize) async
    test('test notificationsControllerFindAllV1', () async {
      // TODO
    });

    // Get a notification detail
    //
    //Future<NotificationDetailResponseDto> notificationsControllerFindOneV1(String id) async
    test('test notificationsControllerFindOneV1', () async {
      // TODO
    });

    // Get unread notification count
    //
    //Future<UnreadCountResponseDto> notificationsControllerGetUnreadCountV1() async
    test('test notificationsControllerGetUnreadCountV1', () async {
      // TODO
    });

    // Mark all notifications as read
    //
    //Future<UnreadCountResponseDto> notificationsControllerMarkAllAsReadV1() async
    test('test notificationsControllerMarkAllAsReadV1', () async {
      // TODO
    });

    // Mark a notification as read
    //
    //Future<NotificationDetailResponseDto> notificationsControllerMarkAsReadV1(String id) async
    test('test notificationsControllerMarkAsReadV1', () async {
      // TODO
    });

    // Mark a notification as unread
    //
    //Future<NotificationDetailResponseDto> notificationsControllerMarkAsUnreadV1(String id) async
    test('test notificationsControllerMarkAsUnreadV1', () async {
      // TODO
    });

    // Delete a notification
    //
    //Future notificationsControllerRemoveV1(String id) async
    test('test notificationsControllerRemoveV1', () async {
      // TODO
    });
  });
}
