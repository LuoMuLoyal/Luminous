import 'package:llama_native/llama_native.dart';
import 'package:luminous/core/ai/local_model.dart';
import 'package:luminous/core/ai/model_manifest_source.dart';
import 'package:luminous/core/ai/model_store.dart';

/// Everything the app needs to run an on-device model, assembled.
///
/// ## Why this is a facade
///
/// Three concerns have to line up before a token can be produced: the manifest
/// says which model exists and what its digest is, the store holds the verified
/// bytes, and the engine needs a path to them. Each is testable on its own, but
/// none is useful alone — this class is the one place that wires them, so the UI
/// deals in "load the assistant" rather than in three collaborators.
///
/// ## Why loading is explicit
///
/// A model is gigabytes of resident memory. Loading it because a settings screen
/// was opened would be wrong, so [load] is a separate call the caller makes at the
/// point it actually needs the model, and [release] gives it back.
// Named parameters cannot be private in Dart, so `this._store` is not an option
// here; the lint's suggestion does not apply.
// ignore_for_file: prefer_initializing_formals
final class LocalAssistant {
  LocalAssistant({
    required ModelStore store,
    required ModelManifestSource manifest,
    required LlamaBridge bridge,
  }) : _store = store,
       _manifest = manifest,
       _bridge = bridge;

  final ModelStore _store;
  final ModelManifestSource _manifest;
  final LlamaBridge _bridge;

  LlamaEngine? _engine;
  LocalModel? _loaded;

  /// The model currently in memory, if any.
  LocalModel? get loadedModel => _loaded;

  /// Whether a model is loaded and usable.
  bool get isReady => _engine != null;

  /// The models this build can offer.
  ///
  /// Fetches the manifest; it is a few kilobytes, and the model behind it is
  /// gigabytes, so this is not the expensive step.
  Future<List<LocalModel>> availableModels() async {
    final manifest = await _manifest.fetch();
    return manifest.models;
  }

  /// Downloads [model] if needed, verifies it, and loads it.
  ///
  /// Replaces any previously loaded model: two resident models is two KV caches,
  /// and phones do not have the memory for that.
  ///
  /// [onProgress] reports 0.0–1.0 across the download. It is **not** called for
  /// the load itself, which is a single blocking step with no meaningful fraction.
  Future<ModelInfo> load(
    LocalModel model, {
    void Function(double progress)? onProgress,
    int? contextLength,
  }) async {
    await unload();

    await _store.ensure(model, onProgress: onProgress);

    final engine = await RustLlamaEngine.open(
      _bridge,
      _store.pathOf(model),
      options: EngineOptions(
        // The runtime window is the caller's decision, defaulting to the smaller
        // of the model's trained length and 4096: KV memory scales linearly with
        // this, and a model trained for 128K does not need 128K for an assistant
        // turn.
        contextLength: contextLength ?? _defaultContextLength(model),
      ),
    );

    final info = await engine.info();
    _engine = engine;
    _loaded = model;
    return info;
  }

  /// Clears messages so the next generation starts from an empty history.
  Future<void> reset() async {
    await _engine?.reset();
  }

  /// Releases the loaded model.
  Future<void> unload() async {
    final engine = _engine;
    _engine = null;
    _loaded = null;
    await engine?.release();
  }

  /// Formats [messages] with the model's own template, or a plain fallback.
  ///
  /// Returns null when no model is loaded; callers use [isReady] to decide what
  /// to show rather than handling an exception for a normal state.
  Future<String?> buildPrompt(List<ChatMessage> messages) async {
    final engine = _engine;
    if (engine == null) return null;

    final templated = await engine.formatChatPrompt(messages);
    // A model without a template is supported: the fallback is a plain
    // `Role: content` transcript, which is what most instruction-tuned models
    // accept when their own format is unavailable.
    return templated ?? fallbackChatPrompt(messages);
  }

  /// Streams a completion for [prompt].
  ///
  /// Throws [LlamaFailure] with `invalidState` when no model is loaded.
  Stream<String> generate(String prompt, {GenerationOptions? options}) {
    final engine = _engine;
    if (engine == null) {
      return Stream.error(
        const LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'No model is loaded.',
        ),
      );
    }
    return engine.generate(prompt, options: options);
  }

  /// Collects a whole completion, keeping partial text on cancellation.
  Future<GenerationResult> generateToCompletion(
    String prompt, {
    GenerationOptions? options,
    bool Function(String soFar)? shouldCancel,
  }) async {
    return const CollectGeneration()(
      stream: generate(prompt, options: options),
      shouldCancel: shouldCancel,
    );
  }

  int _defaultContextLength(LocalModel model) {
    const cap = 4096;
    return model.contextLength < cap ? model.contextLength : cap;
  }
}
