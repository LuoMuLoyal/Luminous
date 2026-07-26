import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for AssistantConversationMessageDto
void main() {
  final AssistantConversationMessageDto?
  instance = /* AssistantConversationMessageDto(...) */ null;
  // TODO add properties to the entity

  group(AssistantConversationMessageDto, () {
    // Persisted conversation role visible to the client.
    // String role
    test('to test the property `role`', () async {
      // TODO
    });

    // Persisted Markdown-ready message content.
    // String content
    test('to test the property `content`', () async {
      // TODO
    });

    // Tool names recorded for this message. Non-empty for assistant messages that used tools.
    // List<String> usedTools
    test('to test the property `usedTools`', () async {
      // TODO
    });

    // ISO-8601 timestamp when the message was created.
    // String createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });
  });
}
