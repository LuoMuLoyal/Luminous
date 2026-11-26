/// Sampling and decoding settings for one generation.
///
/// Values are validated in the constructor rather than at the call site: an
/// out-of-range `topP` reaching llama.cpp silently changes decoding behaviour
/// instead of failing, and "the model got worse" is very hard to trace back to a
/// typo in a float.
final class GenerationOptions {
  GenerationOptions({
    this.maxTokens = 512,
    this.temperature = 0.7,
    this.topP = 0.95,
    this.topK = 40,
    this.repeatPenalty = 1.1,
    this.repeatLastN = 64,
    this.stopSequences = const [],
    this.grammar,
  }) {
    RangeError.checkValueInInterval(maxTokens, 1, 32768, 'maxTokens');
    if (temperature < 0 || temperature > 2) {
      throw RangeError.range(temperature, 0, 2, 'temperature');
    }
    if (topP <= 0 || topP > 1) {
      throw RangeError.value(topP, 'topP', 'must be in (0, 1]');
    }
    if (topK < 0) throw RangeError.value(topK, 'topK', 'must be >= 0');
    if (repeatPenalty <= 0) {
      throw RangeError.value(repeatPenalty, 'repeatPenalty', 'must be > 0');
    }
    if (repeatLastN < 0) {
      throw RangeError.value(repeatLastN, 'repeatLastN', 'must be >= 0');
    }
  }

  /// Hard cap on generated tokens — also the main guard on runaway latency.
  final int maxTokens;

  /// 0 means greedy, and `topP` / `topK` are then ignored (matching llama.cpp).
  final double temperature;

  final double topP;
  final int topK;
  final double repeatPenalty;

  /// Recent tokens the repetition penalty looks at; 0 disables it.
  final double repeatLastN;

  /// Sequences that end generation when matched, across token boundaries.
  final List<String> stopSequences;

  /// A GBNF grammar constraining every sampled token.
  ///
  /// This is what makes a device-local model trustworthy for machine-readable
  /// output: the sampler cannot emit a token the grammar rejects, so a JSON
  /// result parses by construction instead of by hope. Without it, a small model
  /// will eventually produce a truncated object — usually at the worst time.
  final String? grammar;

  GenerationOptions copyWith({
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    double? repeatPenalty,
    double? repeatLastN,
    List<String>? stopSequences,
    String? grammar,
  }) => GenerationOptions(
    maxTokens: maxTokens ?? this.maxTokens,
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    topK: topK ?? this.topK,
    repeatPenalty: repeatPenalty ?? this.repeatPenalty,
    repeatLastN: repeatLastN ?? this.repeatLastN,
    stopSequences: stopSequences ?? this.stopSequences,
    grammar: grammar ?? this.grammar,
  );
}
