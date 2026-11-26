/// How a model is loaded into memory.
///
/// Separated from [GenerationOptions] because the two have different lifetimes
/// and different costs: these settings decide **how much memory the process
/// holds for as long as the model is loaded**, whereas generation options are
/// per-call.
final class EngineOptions {
  EngineOptions({
    this.contextLength = 4096,
    this.batchSize = 512,
    this.threads = 4,
    this.gpuLayers = 0,
    this.useMmap = true,
  }) {
    RangeError.checkValueInInterval(
      contextLength,
      512,
      262144,
      'contextLength',
    );
    RangeError.checkValueInInterval(batchSize, 1, 4096, 'batchSize');
    RangeError.checkValueInInterval(threads, 1, 16, 'threads');
    if (gpuLayers < 0) {
      throw RangeError.value(gpuLayers, 'gpuLayers', 'must be >= 0');
    }
    if (batchSize > contextLength) {
      throw RangeError.value(
        batchSize,
        'batchSize',
        'must not exceed contextLength ($contextLength)',
      );
    }
  }

  /// The KV-cache window. **Memory scales linearly with this**, so it — not
  /// `maxTokens` — decides whether a given device can hold the model at all.
  ///
  /// 4096 is the default because it fits an assistant system prompt plus a
  /// short conversation on a 6 GB phone. Raising it to the model's trained
  /// maximum is a common and expensive mistake.
  final int contextLength;

  /// Prompt tokens decoded per `llama_decode` call; must not exceed
  /// [contextLength]. Larger batches process a long prompt faster but spike
  /// memory transiently.
  final int batchSize;

  /// Compute threads.
  ///
  /// Deliberately not "all cores": on a phone, pinning every core reaches the
  /// thermal limit sooner than it saves wall time, and the extra heat is
  /// user-visible. 4 is a safe default; expose it to a settings screen rather
  /// than guessing per device here.
  final int threads;

  /// Layers offloaded to the GPU.
  ///
  /// 0 is CPU only; a large value offloads as much as the backend supports
  /// (Metal on iOS/macOS, Vulkan/OpenCL elsewhere). GPU matters most for
  /// **prompt processing**, where a long system prompt is paid for — less so for
  /// per-token speed.
  final int gpuLayers;

  /// Memory-maps the weights instead of copying them into anonymous memory.
  ///
  /// On by default: it lets the OS evict clean pages under pressure instead of
  /// killing the app, which is the difference between "slow" and "crashed".
  final bool useMmap;

  EngineOptions copyWith({
    int? contextLength,
    int? batchSize,
    int? threads,
    int? gpuLayers,
    bool? useMmap,
  }) => EngineOptions(
    contextLength: contextLength ?? this.contextLength,
    batchSize: batchSize ?? this.batchSize,
    threads: threads ?? this.threads,
    gpuLayers: gpuLayers ?? this.gpuLayers,
    useMmap: useMmap ?? this.useMmap,
  );
}
