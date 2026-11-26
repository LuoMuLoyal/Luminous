/// The outcome of one completed generation.
///
/// Carries `cancelled` rather than throwing: a user stopping a generation is a
/// normal end, not a failure, and the partial text they already saw should be
/// kept rather than discarded.
final class GenerationResult {
  const GenerationResult({
    required this.text,
    required this.completionTokens,
    required this.cancelled,
  });

  final String text;

  /// Tokens produced, for cost/telemetry. Not a token *count* of the prompt.
  final int completionTokens;

  /// True when generation stopped because the caller asked it to; [text] then
  /// holds everything produced up to that point.
  final bool cancelled;

  @override
  String toString() =>
      'GenerationResult(${text.length} chars, $completionTokens tokens, '
      'cancelled=$cancelled)';
}
