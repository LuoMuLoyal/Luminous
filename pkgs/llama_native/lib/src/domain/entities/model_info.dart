/// What the GGUF reports about itself.
///
/// Read without allocating a context, so the app can show the user what they
/// have and choose parameters before paying for the KV cache — which on a phone
/// is the difference between loading and being killed.
final class ModelInfo {
  const ModelInfo({
    required this.architecture,
    required this.name,
    required this.trainedContextLength,
    required this.embeddingSize,
    required this.layerCount,
    required this.hasChatTemplate,
  });

  /// e.g. `llama`, `qwen3`, `gemma3`.
  final String architecture;

  final String name;

  /// The context length the model was **trained** for.
  ///
  /// An upper bound, not a recommendation: the runtime context may be smaller,
  /// and usually should be — KV memory scales linearly with it.
  final int trainedContextLength;

  final int embeddingSize;
  final int layerCount;

  /// Whether the file carries a chat template.
  ///
  /// When false, the caller must build the prompt itself; this package will not
  /// invent a format the model was not trained on.
  final bool hasChatTemplate;

  @override
  String toString() =>
      'ModelInfo($name, $architecture, ctx=$trainedContextLength, '
      'layers=$layerCount)';
}
