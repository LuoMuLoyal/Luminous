import '../../domain/entities/chat_message.dart';
import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/failures/llama_failure.dart';
import '../../domain/ports/llama_engine.dart';
import '../worker/worker_connection.dart';

/// The [LlamaEngine] implementation over llama.cpp.
///
/// Its whole job is translation: domain values in, worker protocol out. It owns
/// no native handles — those belong to the worker isolate — and it holds no
/// llama.cpp types, so the app never sees either.
///
/// ## Why a connection and not an engine per call
///
/// Spawning an isolate and loading a 2 GB model costs seconds. The connection is
/// created once, kept for the app's lifetime, and released in `dispose`; that is
/// the difference between "opens the assistant" and "opens the assistant in 40
/// seconds".
final class LlamaCppEngine implements LlamaEngine {
  LlamaCppEngine._(this._connection);

  /// Starts a worker and returns an engine ready to [load].
  static Future<LlamaCppEngine> start() async {
    final connection = await WorkerConnection.open();
    return LlamaCppEngine._(connection);
  }

  final WorkerConnection _connection;
  bool _released = false;

  @override
  Future<ModelInfo> load(String modelPath, {EngineOptions? options}) async {
    if (_released) {
      throw const LlamaFailure(
        kind: LlamaFailureKind.invalidState,
        message: 'This engine has been released.',
      );
    }
    await _connection.load(modelPath, options ?? EngineOptions());
    return _connection.info();
  }

  @override
  Future<String?> formatChatPrompt(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Future.error(
        const LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'Cannot format an empty conversation.',
        ),
      );
    }
    return _connection.formatPrompt(
      [for (final message in messages) message.role],
      [for (final message in messages) message.content],
    );
  }

  @override
  Stream<String> generate(String prompt, {GenerationOptions? options}) {
    if (prompt.isEmpty) {
      return Stream.error(
        const LlamaFailure(
          kind: LlamaFailureKind.promptRejected,
          message: 'The prompt is empty.',
        ),
      );
    }
    return _connection.generate(prompt, options ?? GenerationOptions());
  }

  @override
  Future<void> reset() => _connection.reset();

  @override
  Future<void> release() async {
    if (_released) return;
    _released = true;
    await _connection.close();
  }
}
