library;

import 'dart:isolate';

import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/failures/llama_failure.dart';

/// Messages between the main isolate and the inference worker.
///
/// ## Why the protocol is its own file
///
/// Both sides must agree on it, and they live in different isolates where a
/// mismatch is not a compile error but a silent hang. Keeping the vocabulary in
/// one place makes the contract reviewable, and `sealed` makes the worker's
/// switch exhaustive — a new command that nobody handles fails to compile.
///
/// Everything here is a **plain value**: only primitives, typed lists and value
/// classes cross an isolate boundary. Anything holding FFI pointers or native
/// handles must stay worker-side, which is why the replies never carry them.
/// A command sent to the worker.
sealed class WorkerCommand {
  const WorkerCommand(this.replyPort);

  /// Port the worker sends its replies to.
  final SendPort replyPort;
}

/// Initialise the native backend. Sent once, implicitly by the first load.
final class InitBackend extends WorkerCommand {
  const InitBackend(super.replyPort);
}

/// Load a model and allocate its context, replacing whatever was loaded.
final class LoadModel extends WorkerCommand {
  const LoadModel(this.modelPath, this.options, super.replyPort);

  final String modelPath;
  final EngineOptions options;
}

/// Read the loaded model's metadata.
final class ReadModelInfo extends WorkerCommand {
  const ReadModelInfo(super.replyPort);
}

/// Apply the model's chat template.
final class FormatPrompt extends WorkerCommand {
  const FormatPrompt(this.roles, this.contents, super.replyPort);

  /// Parallel arrays rather than `ChatMessage` objects: the worker only needs
  /// the two strings, and passing the entity would couple the wire format to a
  /// domain class.
  final List<String> roles;
  final List<String> contents;
}

/// Stream a completion.
final class StartGeneration extends WorkerCommand {
  const StartGeneration(this.prompt, this.options, super.replyPort);

  final String prompt;
  final GenerationOptions options;
}

/// Clear the KV cache.
final class ResetContext extends WorkerCommand {
  const ResetContext(super.replyPort);
}

/// Release everything and stop the worker.
final class DisposeWorker extends WorkerCommand {
  const DisposeWorker(super.replyPort);
}

/// A message from the worker back to the main isolate.
sealed class WorkerReply {
  const WorkerReply();
}

/// One decoded token piece.
///
/// A piece is not a word: it is whatever the tokenizer produced, and a multi-byte
/// character can span pieces. Consumers concatenate.
final class TokenPiece extends WorkerReply {
  const TokenPiece(this.text);
  final String text;
}

/// Terminal success, carrying whatever the command produced.
final class WorkerOk<T> extends WorkerReply {
  const WorkerOk(this.value);
  final T value;
}

/// Terminal failure, carrying the domain failure's fields.
///
/// The [LlamaFailure] itself is reconstructed on the main isolate: it holds an
/// optional `cause` which may be an arbitrary object, and sending that across a
/// boundary is how isolate send failures happen at runtime.
final class WorkerFailure extends WorkerReply {
  const WorkerFailure({
    required this.kind,
    required this.message,
    this.causeDescription,
  });

  final LlamaFailureKind kind;
  final String message;
  final String? causeDescription;

  LlamaFailure toFailure() =>
      LlamaFailure(kind: kind, message: message, cause: causeDescription);
}

/// "The model has no chat template."
///
/// A distinct reply rather than a null success, so the caller can tell "this
/// model ships no template, use the fallback" from "the call failed".
final class NoChatTemplate extends WorkerReply {
  const NoChatTemplate();
}

/// Maps a negative shim return code onto a failure kind.
///
/// The numeric codes are the shim's (`llama_shim.h`); this is the single place
/// they become domain vocabulary, so a change in the C layer has exactly one Dart
/// site to update.
LlamaFailureKind failureKindForShimCode(int code) => switch (code) {
  -1 => LlamaFailureKind.modelUnreadable,
  -2 => LlamaFailureKind.contextUnavailable,
  -3 => LlamaFailureKind.promptRejected,
  -4 => LlamaFailureKind.decodeFailed,
  -5 => LlamaFailureKind.grammarInvalid,
  -6 => LlamaFailureKind.cancelled,
  -7 => LlamaFailureKind.invalidState,
  _ => LlamaFailureKind.invalidState,
};
