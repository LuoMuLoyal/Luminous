import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for AssistantApi
void main() {
  final instance = LucentApi().getAssistantApi();

  group(AssistantApi, () {
    // Archive the authenticated user latest active assistant conversation
    //
    //Future<AssistantClearResultResponseDto> assistantControllerClearLatestConversationV1() async
    test('test assistantControllerClearLatestConversationV1', () async {
      // TODO
    });

    // Get authenticated user assistant capabilities and permissions
    //
    //Future<AssistantCapabilitiesResponseDto> assistantControllerGetCapabilitiesV1() async
    test('test assistantControllerGetCapabilitiesV1', () async {
      // TODO
    });

    // Get the authenticated user latest persisted assistant conversation
    //
    //Future<AssistantConversationResponseDto> assistantControllerGetLatestConversationV1() async
    test('test assistantControllerGetLatestConversationV1', () async {
      // TODO
    });

    // List recent persisted assistant conversations for the user
    //
    //Future<AssistantConversationListResponseDto> assistantControllerListRecentConversationsV1() async
    test('test assistantControllerListRecentConversationsV1', () async {
      // TODO
    });

    // Activate one persisted assistant conversation and return its full history
    //
    //Future<AssistantConversationResponseDto> assistantControllerOpenConversationV1(String conversationId) async
    test('test assistantControllerOpenConversationV1', () async {
      // TODO
    });

    // Stream authenticated user assistant response
    //
    //Future<String> assistantControllerStreamMessagesV1(StreamAssistantMessagesDto streamAssistantMessagesDto) async
    test('test assistantControllerStreamMessagesV1', () async {
      // TODO
    });
  });
}
