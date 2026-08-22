import 'package:luminous/features/assistant/domain/entities/models.dart';

/// Returns the stable local identity used for an assistant message.
String messageIdFor(AssistantMessage message) {
  return '${message.role.name}-${message.createdAt.toIso8601String()}-${message.content.hashCode}';
}
