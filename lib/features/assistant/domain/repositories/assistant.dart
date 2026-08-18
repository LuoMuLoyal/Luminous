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

  /// Renames one persisted conversation (title only) on the backend.
  Future<void> renameConversation({
    required String conversationId,
    required String title,
  });

  /// Soft-deletes one persisted conversation on the backend.
  Future<void> deleteConversation(String conversationId);

  Stream<AssistantGenerationEvent> streamMessages(
    List<AssistantMessage> messages, {
    String? conversationId,
  });

  /// Confirms or rejects pending assistant write proposals on the backend and
  /// resumes the suspended graph thread. Returns the final assistant content
  /// produced after the decision is applied, or null when unavailable.
  Future<String?> confirmProposals({
    required String conversationId,
    required List<String> proposalIds,
    required String decision,
    String? note,
  });
}
