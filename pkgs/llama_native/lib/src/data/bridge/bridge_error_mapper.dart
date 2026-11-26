import '../../domain/failures/llama_failure.dart';

/// Maps an error thrown by the generated bridge onto a [LlamaFailure].
///
/// ## Why text matching
///
/// `flutter_rust_bridge` surfaces a Rust `Err` as a `PanicException` whose message
/// is the `Display` of the error, because the generated bindings have no typed
/// error channel in this version. Until an explicit error DTO crosses the bridge,
/// the variant has to be recovered from the message — so it is recovered **here**,
/// in one function, rather than at each call site.
///
/// When a typed error channel exists, this function becomes a `switch` on an enum
/// and every caller keeps working unchanged.
///
/// The order of checks matters: `backendUnavailable` and `modelUnreadable` are
/// matched before the generic fallbacks so a nested cause does not get classified
/// as `invalidState`.
LlamaFailure mapBridgeError(Object error) {
  return LlamaFailure(
    kind: mapBridgeErrorKind(error),
    message: error.toString(),
    cause: error,
  );
}

/// Extracts the stable kind without building the failure.
///
/// Kept separate so the stream path can attach a stack trace to a
/// [LlamaFailure] it constructs rather than to a wrapper.
LlamaFailureKind mapBridgeErrorKind(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('backendunavailable') ||
      text.contains('could not load the llama_native') ||
      text.contains('dynamic library')) {
    return LlamaFailureKind.libraryUnavailable;
  }
  if (text.contains('modelunreadable')) {
    return LlamaFailureKind.modelUnreadable;
  }
  if (text.contains('contextunavailable')) {
    return LlamaFailureKind.contextUnavailable;
  }
  if (text.contains('promptrejected')) {
    return LlamaFailureKind.promptRejected;
  }
  if (text.contains('decodefailed')) {
    return LlamaFailureKind.decodeFailed;
  }
  if (text.contains('grammarinvalid')) {
    return LlamaFailureKind.grammarInvalid;
  }
  if (text.contains('cancelled')) {
    return LlamaFailureKind.cancelled;
  }
  return LlamaFailureKind.invalidState;
}
