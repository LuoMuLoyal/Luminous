import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for CreateNotificationDto
void main() {
  final CreateNotificationDto? instance = /* CreateNotificationDto(...) */ null;
  // TODO add properties to the entity

  group(CreateNotificationDto, () {
    // Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
    // UserNotificationType type
    test('to test the property `type`', () async {
      // TODO
    });

    // Notification title.
    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Notification content body.
    // String content
    test('to test the property `content`', () async {
      // TODO
    });

    // Action route target for the frontend.
    // String action
    test('to test the property `action`', () async {
      // TODO
    });

    // Extra payload for the action.
    // Object actionPayload
    test('to test the property `actionPayload`', () async {
      // TODO
    });
  });
}
