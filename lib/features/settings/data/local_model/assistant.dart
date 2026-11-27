// Named parameters cannot be private in Dart: `this._store` is not available, so
// the public parameter names stay.
// ignore_for_file: prefer_initializing_formals

import 'package:llama_native/llama_native.dart';
import 'package:luminous/features/settings/data/local_model/resolver.dart';
import 'package:luminous/features/settings/data/local_model/store.dart';
import 'package:luminous/features/settings/domain/local_model/catalog.dart';

/// Everything the app needs to run an on-device model, assembled.
///
/// ## Why this is a facade
///
/// Three concerns have to line up before a token is produced: the resolver turns a
/// catalogue entry into a digest-bearing descriptor, the store holds the verified
/// bytes, and the engine needs a path to them. Each is testable alone, none is
/// useful alone — this class is the one place that wires them, so the UI deals in
/// "switch to this model" rather than in three collaborators.
///
/// ## Why loading is explicit
///
/// A model is gigabytes of resident memory. Loading because a settings screen was
/// opened would be wrong, so [load] is a separate call made at the point the model
/// is actually needed, and [unload] gives it back.
final class LocalAssistant {
  LocalAssistant({
    required ModelStore store,
    required ModelSourceResolver resolver,
    required LlamaBridge bridge,
  }) : _store = store,
       _resolver = resolver,
       _bridge = bridge;

  final ModelStore _store;
  final ModelSourceResolver _resolver;
  final LlamaBridge _bridge;

  LlamaEngine? _engine;
  LocalModel? _loaded;

  /// The model currently in memory, if any.
  LocalModel? get loadedModel => _loaded;

  /// Whether a model is loaded and usable.
  bool get isReady => _engine != null;

  /// Resolves [source] to a descriptor with the host's digest, downloading nothing.
  ///
  /// The picker calls this to show real sizes; a model that cannot be resolved
  /// surfaces here rather than as a download that always fails.
  Future<LocalModel> describe(ModelSource source) => _resolver.resolve(source);

  /// Whether [model]'s bytes are already on disk and verified.
  bool isDownloaded(LocalModel model) => _store.isAvailable(model);

  /// Downloads [model] if needed and verifies it, without loading.
  ///
  /// Split from [load] so a picker can pre-fetch a model in the background and
  /// switch to it instantly later — loading is the step that costs memory, and it
  /// should happen when the user asks for the assistant, not when they choose a
  /// model.
  Future<void> download(
    LocalModel model, {
    void Function(double progress)? onProgress,
  }) => _store.ensure(model, onProgress: onProgress);

  /// Loads [model], downloading first if its bytes are absent.
  ///
  /// Replaces any previously loaded model: two resident models is two KV caches,
  /// and phones do not have the memory for that.
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
        // The runtime window is a deliberate cap, not the model's trained maximum:
        // KV memory scales linearly with it, and a model trained for 32K does not
        // need 32K to answer an assistant turn.
        contextLength: contextLength ?? _contextLengthFor(model),
      ),
    );

    final info = await engine.info();
    _engine = engine;
    _loaded = model;
    return info;
  }

  /// Deletes [model]'s bytes from disk without touching the loaded model.
  ///
  /// Separate from [unload] because the two answer different questions: free the
  /// memory, and reclaim the storage. Deleting a file the engine has mapped would be
  /// unsafe, so a caller removing the *loaded* model unloads first — the picker does
  /// that, and this method stays deliberately ignorant of it.
  Future<void> discard(LocalModel model) => _store.remove(model);

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
  /// Returns null when no model is loaded; callers use [isReady] to decide what to
  /// show rather than handling an exception for a normal state.
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

  /// The window to allocate for [model].
  ///
  /// Capped at 4096 because KV memory is the difference between a model that fits
  /// and one the OS kills, and an assistant turn does not need more. A model trained
  /// for less keeps its own limit.
  int _contextLengthFor(LocalModel model) {
    const cap = 4096;
    return model.contextLength < cap ? model.contextLength : cap;
  }
}
