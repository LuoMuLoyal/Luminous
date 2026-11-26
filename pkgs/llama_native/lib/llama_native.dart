/// On-device LLM inference via llama.cpp.
///
/// ## Layout
///
/// Clean architecture, three layers with one-way dependencies:
///
/// ```text
/// domain/          pure Dart: entities, ports, rules. No FFI, no isolates.
///   entities/      GenerationOptions, EngineOptions, ModelInfo, ChatMessage …
///   failures/      LlamaFailure and its stable kinds
///   ports/         LlamaEngine — what the app depends on
///   services/      CollectGeneration, fallbackChatPrompt
///
/// data/            the llama.cpp implementation of the port.
///   ffi/           raw bindings mirroring llama_shim.h
///   isolate/       worker isolate: the only owner of native handles
///   worker/        main-isolate side of the worker conversation
///   repositories/  LlamaCppEngine — translates domain ⇄ worker
/// ```
///
/// The app imports [`LlamaEngine`][LlamaEngine] and the value types; it never
/// imports `data/`. That is what makes a fake engine possible in tests and a
/// second backend (LiteRT-LM, MLC) a new folder rather than a rewrite.
///
/// ## Why inference runs on an isolate
///
/// `llama_decode` blocks for hundreds of milliseconds per token. On the platform
/// thread that freezes the UI for the whole generation — which reads as a hang.
/// The worker isolate is a correctness requirement here, not an optimisation.
///
/// ## What this package deliberately does not do
///
/// - **Model download.** The app decides where models come from and verifies
///   them; this package opens a path.
/// - **Chat templates.** They come from the GGUF, via llama.cpp. Guessing a
///   format the model was not trained on produces plausible garbage.
/// - **Prompt construction from app data.** Callers assemble the conversation.
library;

export 'src/data/repositories/llama_cpp_engine.dart' show LlamaCppEngine;
export 'src/domain/entities/chat_message.dart' show ChatMessage;
export 'src/domain/entities/engine_options.dart' show EngineOptions;
export 'src/domain/entities/generation_options.dart' show GenerationOptions;
export 'src/domain/entities/generation_result.dart' show GenerationResult;
export 'src/domain/entities/model_info.dart' show ModelInfo;
export 'src/domain/failures/llama_failure.dart'
    show LlamaFailure, LlamaFailureKind;
export 'src/domain/ports/llama_engine.dart' show LlamaEngine;
export 'src/domain/services/collect_generation.dart'
    show CollectGeneration, fallbackChatPrompt, requireLoaded;
