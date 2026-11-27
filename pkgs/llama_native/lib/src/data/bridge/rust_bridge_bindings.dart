import 'dart:async';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/failures/llama_failure.dart';
import '../ffi/api.dart' as ffi;
import '../ffi/frb_generated.dart' as frb;
import '../ffi/options.dart' as ffi;
import 'llama_bridge.dart';

/// The [LlamaBridge] implementation over the generated bindings.
///
/// ## Why this adapter is the only file naming generated symbols
///
/// `flutter_rust_bridge_codegen` rewrites `lib/src/data/ffi/` wholesale on every
/// run, and its names are mechanical (`crateApiLoadSession`,
/// `RustLib.instance.api`). Call sites depending on them would make a
/// regeneration a repository-wide change. Everything the generator owns is named
/// here and nowhere else.
///
/// ## Why initialisation lives here
///
/// The native library must be loaded before any call, and forgetting that fails
/// deep inside the generated code with an opaque error. Doing it lazily, once,
/// removes a step every caller would otherwise have to remember.
final class RustBridgeBindings implements LlamaBridge {
  RustBridgeBindings();

  bool _ready = false;

  /// Loads the native library. Safe to call repeatedly.
  ///
  /// A failure is reported as [LlamaFailureKind.libraryUnavailable]: it means the
  /// Rust cdylib was not built for this platform/architecture, which is a build
  /// problem rather than a runtime one.
  Future<void> _ensureReady() async {
    if (_ready) return;
    try {
      await frb.RustLib.init();
      _ready = true;
    } on Object catch (error) {
      throw LlamaFailure(
        kind: LlamaFailureKind.libraryUnavailable,
        message: 'could not load the llama_native Rust library: $error',
        cause: error,
      );
    }
  }

  @override
  Future<Object> loadSession({
    required String modelPath,
    required EngineOptions options,
  }) async {
    await _ensureReady();
    // The generated options type mirrors the Rust struct field-for-field; the
    // mapping is explicit so a field rename surfaces here as a compile error
    // rather than as a silently wrong default.
    return ffi.loadSession(
      modelPath: modelPath,
      options: ffi.EngineOptions(
        contextLength: options.contextLength,
        batchSize: options.batchSize,
        threads: options.threads,
        gpuLayers: options.gpuLayers,
        useMmap: options.useMmap,
      ),
    );
  }

  @override
  Future<ModelInfo> sessionInfo(Object session) async {
    await _ensureReady();
    final info = await ffi.sessionInfo(session: session as ffi.LlamaSession);
    return ModelInfo(
      architecture: info.architecture,
      name: info.name,
      trainedContextLength: info.trainedContextLength,
      embeddingSize: info.embeddingSize,
      layerCount: info.layerCount,
      hasChatTemplate: info.hasChatTemplate,
    );
  }

  @override
  Future<String?> formatChatPrompt({
    required Object session,
    required List<ChatMessage> messages,
  }) async {
    await _ensureReady();
    return ffi.formatChatPrompt(
      session: session as ffi.LlamaSession,
      roles: [for (final message in messages) message.role],
      contents: [for (final message in messages) message.content],
    );
  }

  @override
  Stream<TokenEvent> generate({
    required Object session,
    required String prompt,
    required GenerationOptions options,
  }) {
    // A stream cannot await a precondition, so the readiness check runs before
    // the stream is created and a failure becomes a stream error.
    return Stream<TokenEvent>.multi((controller) {
      unawaited(
        _ensureReady().then(
          (_) {
            final subscription = ffi
                .generate(
                  session: session as ffi.LlamaSession,
                  prompt: prompt,
                  options: ffi.GenerationOptions(
                    maxTokens: options.maxTokens,
                    temperature: options.temperature,
                    topP: options.topP,
                    topK: options.topK,
                    repeatPenalty: options.repeatPenalty,
                    repeatLastN: options.repeatLastN,
                    stopSequences: options.stopSequences,
                    grammar: options.grammar,
                  ),
                )
                .listen(
                  (piece) => controller.add(TokenEvent.piece(piece)),
                  onError: (Object error, StackTrace stack) {
                    controller.addError(error, stack);
                    unawaited(controller.close());
                  },
                  onDone: () => unawaited(controller.close()),
                );
            // Cancelling the Dart subscription closes the Rust stream sink, which
            // makes `send` fail and stops the decode loop.
            controller.onCancel = () {
              unawaited(subscription.cancel());
            };
          },
          onError: (Object error, StackTrace stack) {
            controller.addError(error, stack);
            unawaited(controller.close());
          },
        ),
      );
    });
  }

  @override
  Future<void> releaseSession(Object session) async {
    await _ensureReady();
    await ffi.releaseSession(session: session as ffi.LlamaSession);
  }
}
