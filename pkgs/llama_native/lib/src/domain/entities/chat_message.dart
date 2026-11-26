/// A chat turn, in the shape GGUF chat templates consume.
///
/// Value type with no behaviour beyond JSON projection: the worker serialises it
/// and llama.cpp's own template engine interprets it. Prompt format therefore
/// belongs to the model file, not to this class — which is why there is no
/// "format for model X" branch anywhere in the package.
final class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  const ChatMessage.system(this.content) : role = 'system';
  const ChatMessage.user(this.content) : role = 'user';
  const ChatMessage.assistant(this.content) : role = 'assistant';

  final String role;
  final String content;

  Map<String, Object?> toJson() => {'role': role, 'content': content};

  @override
  String toString() => 'ChatMessage($role, ${content.length} chars)';
}
