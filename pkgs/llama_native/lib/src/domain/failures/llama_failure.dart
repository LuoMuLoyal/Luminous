/// Stable failure categories.
///
/// These are **this package's** vocabulary, not llama.cpp's: upstream reports
/// problems as null pointers and log lines, which cannot cross an FFI boundary
/// usefully. The data layer maps them, and callers branch on this enum — never
/// on message text, which is diagnostic only.
enum LlamaFailureKind {
  /// The native library could not be loaded: wrong ABI, missing file, or a
  /// desktop build that did not ship the binary.
  libraryUnavailable,

  /// The GGUF could not be opened, is truncated, or is not a model.
  modelUnreadable,

  /// The context could not be created — almost always `contextLength` too large
  /// for available memory.
  contextUnavailable,

  /// The prompt could not be tokenised.
  promptRejected,

  /// A decode step failed mid-generation.
  decodeFailed,

  /// The supplied GBNF grammar is invalid.
  grammarInvalid,

  /// Generation was stopped by the caller. A normal end, not an error.
  cancelled,

  /// The engine was used after release, or two operations raced on one context.
  invalidState,
}

/// A failure with a stable [kind], a developer-facing [message], and the raw
/// native code for logs.
///
/// Deliberately not a bare `Exception`: callers must be able to tell "no model
/// file, offer a download" from "out of memory, offer a smaller context" without
/// string matching.
final class LlamaFailure implements Exception {
  const LlamaFailure({required this.kind, required this.message, this.cause});

  final LlamaFailureKind kind;

  /// Diagnostic detail. Not user-facing copy — the app owns its own strings.
  final String message;

  /// Underlying error, when one exists (a `PlatformException`, an OOM, …).
  final Object? cause;

  /// Whether retrying the same call could plausibly succeed.
  ///
  /// False for every configuration-shaped failure: retrying an unreadable model
  /// or an invalid grammar just fails again.
  bool get isRetryable => switch (kind) {
    LlamaFailureKind.decodeFailed => true,
    _ => false,
  };

  @override
  String toString() => 'LlamaFailure(${kind.name}): $message';
}
