import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import '../../domain/entities/model_info.dart';
import '../../domain/failures/llama_failure.dart';
import '../ffi/llama_shim_bindings.dart';
import 'worker_protocol.dart';

/// Worker isolate entry point: owns every native handle.
///
/// ## Why the handles live here and nowhere else
///
/// `Pointer` values are not sendable across isolates, and a native handle used
/// from two isolates at once is undefined behaviour. Confining model and context
/// to this isolate is what makes the engine safe: the main isolate never sees a
/// pointer, it sees commands and values.
///
/// ## Lifetime
///
/// Exactly one model and one context at a time. Loading again releases the old
/// pair first — that is the rule that prevents the KV cache from accumulating
/// across model switches, which on a phone is how an app reaches the kernel's
/// kill threshold after a few model changes.
void workerMain(SendPort commandsPort) {
  final commands = ReceivePort();
  commandsPort.send(commands.sendPort);

  LlamaShim? shim;
  Pointer<Void> model = nullptr;
  Pointer<Void> context = nullptr;

  /// Frees the context then the model, in that order: a context borrows its
  /// model, so the reverse order is a use-after-free.
  void release() {
    final lib = shim;
    if (lib == null) return;
    if (context != nullptr) {
      lib.contextFree(context);
      context = nullptr;
    }
    if (model != nullptr) {
      lib.modelFree(model);
      model = nullptr;
    }
  }

  /// Loads the shim on first use, mapping a dlopen failure to a domain failure.
  LlamaShim requireShim(WorkerCommand command) {
    final existing = shim;
    if (existing != null) return existing;

    try {
      final loaded = LlamaShim.open();
      final err = malloc<Uint8>(512);
      try {
        final code = loaded.backendInit(err, 512);
        if (code != 0) {
          throw LlamaFailure(
            kind: LlamaFailureKind.libraryUnavailable,
            message: decodeErrorBuffer(err, 512),
          );
        }
      } finally {
        malloc.free(err);
      }
      shim = loaded;
      return loaded;
    } on LlamaFailure {
      rethrow;
    } on Object catch (error) {
      throw LlamaFailure(
        kind: LlamaFailureKind.libraryUnavailable,
        message: 'could not open ${LlamaShim.defaultLibraryName}: $error',
        cause: error,
      );
    }
  }

  /// Runs [body], converting any throw into a [WorkerFailure] reply.
  void handle(WorkerCommand command, void Function() body) {
    try {
      body();
    } on LlamaFailure catch (failure) {
      command.replyPort.send(
        WorkerFailure(
          kind: failure.kind,
          message: failure.message,
          causeDescription: failure.cause?.toString(),
        ),
      );
    } on Object catch (error) {
      // Anything else is a bug or a native fault. Reporting it as a failure
      // keeps the main isolate alive; letting it escape kills the isolate and
      // strands every pending call.
      command.replyPort.send(
        WorkerFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'unexpected error in the inference worker: $error',
        ),
      );
    }
  }

  commands.listen((Object? message) {
    if (message is! WorkerCommand) return;

    switch (message) {
      case InitBackend():
        handle(message, () {
          requireShim(message);
          message.replyPort.send(const WorkerOk<void>(null));
        });

      case LoadModel(:final modelPath, :final options):
        handle(message, () {
          final lib = requireShim(message);
          release();

          final pathPtr = toNativeUtf8(modelPath);
          final err = malloc<Uint8>(512);
          try {
            final loaded = lib.modelLoad(
              pathPtr,
              options.gpuLayers,
              options.useMmap ? 1 : 0,
              err,
              512,
            );
            if (loaded == nullptr) {
              throw LlamaFailure(
                kind: LlamaFailureKind.modelUnreadable,
                message: decodeErrorBuffer(err, 512),
              );
            }
            model = loaded;

            final created = lib.contextNew(
              model,
              options.contextLength,
              options.threads,
              options.batchSize,
              err,
              512,
            );
            if (created == nullptr) {
              release();
              throw LlamaFailure(
                kind: LlamaFailureKind.contextUnavailable,
                message: decodeErrorBuffer(err, 512),
              );
            }
            context = created;

            message.replyPort.send(const WorkerOk<void>(null));
          } finally {
            malloc.free(pathPtr);
            malloc.free(err);
          }
        });

      case ReadModelInfo():
        handle(message, () {
          final lib = requireShim(message);
          if (model == nullptr) {
            throw const LlamaFailure(
              kind: LlamaFailureKind.invalidState,
              message: 'No model is loaded.',
            );
          }
          final buffer = malloc<Uint8>(4096);
          try {
            final written = lib.modelMeta(model, buffer, 4096);
            if (written < 0) {
              throw const LlamaFailure(
                kind: LlamaFailureKind.modelUnreadable,
                message: 'Could not read model metadata.',
              );
            }
            message.replyPort.send(
              WorkerOk<ModelInfo>(_parseInfo(buffer, written)),
            );
          } finally {
            malloc.free(buffer);
          }
        });

      case FormatPrompt(:final roles, :final contents):
        handle(message, () {
          final lib = requireShim(message);
          if (model == nullptr) {
            throw const LlamaFailure(
              kind: LlamaFailureKind.invalidState,
              message: 'No model is loaded.',
            );
          }
          final json = _messagesJson(roles, contents);
          final jsonPtr = toNativeUtf8(json);
          try {
            final needed = lib.applyTemplate(model, jsonPtr, 1, nullptr, 0);
            if (needed < 0) {
              // -1 here means "this GGUF has no template", which is a distinct
              // answer from a failure: the caller falls back to its own format.
              message.replyPort.send(const NoChatTemplate());
              return;
            }
            final out = malloc<Uint8>(needed + 1);
            try {
              final written = lib.applyTemplate(
                model,
                jsonPtr,
                1,
                out,
                needed + 1,
              );
              if (written < 0) {
                message.replyPort.send(const NoChatTemplate());
                return;
              }
              message.replyPort.send(
                WorkerOk<String>(decodeUtf8(out, written)),
              );
            } finally {
              malloc.free(out);
            }
          } finally {
            malloc.free(jsonPtr);
          }
        });

      case StartGeneration(:final prompt, :final options):
        handle(message, () {
          final lib = requireShim(message);
          if (context == nullptr || model == nullptr) {
            throw const LlamaFailure(
              kind: LlamaFailureKind.invalidState,
              message: 'No model is loaded.',
            );
          }

          final promptPtr = toNativeUtf8(prompt);
          final grammarPtr = options.grammar == null
              ? nullptr
              : toNativeUtf8(options.grammar!);
          final stopPtr = options.stopSequences.isEmpty
              ? nullptr
              : toNativeUtf8(_stopsJson(options.stopSequences));
          final err = malloc<Uint8>(512);

          try {
            final callback = NativeCallable<TokenCallbackNative>.isolateLocal(
              _forwardToken,
              exceptionalReturn: 1,
            );
            try {
              final generated = lib.generate(
                context,
                model,
                promptPtr,
                _byteLength(prompt),
                options.maxTokens,
                options.temperature,
                options.topP,
                options.topK,
                options.repeatPenalty,
                options.repeatLastN,
                grammarPtr,
                stopPtr,
                callback.nativeFunction,
                // The reply port is the token sink: each callback forwards one
                // piece straight to the main isolate, which keeps the UI
                // painting while the native loop runs.
                _portHandle(message.replyPort.send),
                err,
                512,
              );

              if (generated < 0) {
                final failure = LlamaFailure(
                  kind: failureKindForShimCode(generated),
                  message: decodeErrorBuffer(err, 512),
                );
                message.replyPort.send(
                  WorkerFailure(kind: failure.kind, message: failure.message),
                );
              } else {
                message.replyPort.send(WorkerOk<int>(generated));
              }
            } finally {
              callback.close();
              // Scope the sink to this one call: a later generation must not
              // inherit a port that its caller has stopped listening to.
              _tokenSink = null;
            }
          } finally {
            malloc.free(promptPtr);
            if (grammarPtr != nullptr) malloc.free(grammarPtr);
            if (stopPtr != nullptr) malloc.free(stopPtr);
            malloc.free(err);
          }
        });

      case ResetContext():
        handle(message, () {
          final lib = requireShim(message);
          if (context != nullptr) lib.contextReset(context);
          message.replyPort.send(const WorkerOk<void>(null));
        });

      case DisposeWorker():
        release();
        shim?.backendFree();
        shim = null;
        message.replyPort.send(const WorkerOk<void>(null));
        commands.close();
    }
  });
}

/// Per-token callback, invoked synchronously by the native loop.
///
/// `user_data` carries the main isolate's reply port as a raw integer handle,
/// because a `SendPort` cannot be embedded in a native pointer. The port is
/// closed over in [_portHandle] for the duration of one generation.
int _forwardToken(Pointer<Uint8> piece, int length, Pointer<Void> userData) {
  final sink = _tokenSink;
  if (sink == null) return 1; // No listener: ask the native loop to stop.
  if (length <= 0) return 0;
  sink(TokenPiece(decodeUtf8(piece, length)));
  return 0;
}

/// Where the current generation writes its tokens.
///
/// Set for exactly the duration of one `llama_shim_generate` call and cleared
/// afterwards. A C callback cannot capture a Dart closure, so the sink has to
/// travel through module state; scoping it to one call is what keeps that safe.
void Function(WorkerReply reply)? _tokenSink;

/// Installs [sink] as the token destination and returns the (ignored) user-data
/// pointer the shim signature requires.
Pointer<Void> _portHandle(void Function(WorkerReply reply) sink) {
  _tokenSink = sink;
  return nullptr;
}

/// Parses the metadata JSON the shim emits.
ModelInfo _parseInfo(Pointer<Uint8> buffer, int length) {
  final raw = decodeUtf8(buffer, length);
  // A hand-rolled read rather than `jsonDecode`: this runs once per load, and
  // the shape is fixed by `llama_shim.cpp`.
  return ModelInfo(
    architecture: _stringField(raw, 'architecture'),
    name: _stringField(raw, 'name'),
    trainedContextLength: _intField(raw, 'n_ctx_train'),
    embeddingSize: _intField(raw, 'n_embd'),
    layerCount: _intField(raw, 'n_layers'),
    hasChatTemplate: _stringField(raw, 'chat_template').isNotEmpty,
  );
}

String _stringField(String json, String key) {
  final at = json.indexOf('"$key":"');
  if (at < 0) return '';
  final start = at + key.length + 4;
  final end = json.indexOf('"', start);
  if (end < 0) return '';
  return json
      .substring(start, end)
      .replaceAll(r'\"', '"')
      .replaceAll(r'\\', r'\');
}

int _intField(String json, String key) {
  final at = json.indexOf('"$key":');
  if (at < 0) return 0;
  final start = at + key.length + 3;
  var end = start;
  while (end < json.length && '0123456789-'.contains(json[end])) {
    end++;
  }
  return int.tryParse(json.substring(start, end)) ?? 0;
}

/// Encodes `[{role, content}, …]` for the shim's template call.
///
/// Escapes only what the shim's reader needs, because the shim parses this
/// itself: the two files are the contract, and a full JSON encoder here would
/// produce shapes the C side does not handle.
String _messagesJson(List<String> roles, List<String> contents) {
  final buffer = StringBuffer('[');
  for (var i = 0; i < roles.length; i++) {
    if (i > 0) buffer.write(',');
    buffer.write('{"role":"');
    buffer.write(_escape(roles[i]));
    buffer.write('","content":"');
    buffer.write(_escape(contents[i]));
    buffer.write('"}');
  }
  buffer.write(']');
  return buffer.toString();
}

String _stopsJson(List<String> stops) {
  final buffer = StringBuffer('[');
  for (var i = 0; i < stops.length; i++) {
    if (i > 0) buffer.write(',');
    buffer.write('"');
    buffer.write(_escape(stops[i]));
    buffer.write('"');
  }
  buffer.write(']');
  return buffer.toString();
}

String _escape(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll('"', r'\"')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r')
    .replaceAll('\t', r'\t');

/// UTF-8 byte length, without allocating the encoded bytes.
///
/// The shim takes an explicit length rather than reading to a terminator, which
/// is what lets a prompt contain a NUL byte safely.
int _byteLength(String text) {
  var length = 0;
  for (final rune in text.runes) {
    if (rune < 0x80) {
      length += 1;
    } else if (rune < 0x800) {
      length += 2;
    } else if (rune < 0x10000) {
      length += 3;
    } else {
      length += 4;
    }
  }
  return length;
}
