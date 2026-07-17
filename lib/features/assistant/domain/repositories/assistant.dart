import 'package:luminous/features/assistant/domain/entities/models.dart';

sealed class AssistantGenerationEvent {
  const AssistantGenerationEvent();
}

class AssistantGenerationChunkEvent extends AssistantGenerationEvent {
  const AssistantGenerationChunkEvent(this.content);

  final String content;
}

class AssistantGenerationResultEvent extends AssistantGenerationEvent {
  const AssistantGenerationResultEvent({
    required this.conversationId,
    required this.message,
  });

  final String conversationId;
  final AssistantMessage message;
}

abstract interface class AssistantRepository {
  Future<AssistantCapabilities> getCapabilities();

  Future<List<AssistantConversationSummary>> listRecentConversations();

  Future<AssistantConversation?> getLatestConversation();

  Future<AssistantConversation> openConversation(String conversationId);

  Future<bool> clearLatestConversation();

  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages,
  );
}
