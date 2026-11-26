import 'dart:async';
import 'dart:isolate';

import '../../domain/entities/engine_options.dart';
import '../../domain/entities/generation_options.dart';
import '../../domain/entities/model_info.dart';
import '../../domain/failures/llama_failure.dart';
import '../isolate/worker.dart';
import '../isolate/worker_protocol.dart';

/// Main-isolate side of the conversation with the inference worker.
///
/// ## One call in flight
///
/// The protocol allows exactly one outstanding command. That is not a
/// simplification: the worker owns a single `llama_context`, whose KV cache is
/// shared state, so interleaving two generations would mix their tokens. Callers
/// needing concurrency create a second connection (and pay for a second context).
///
/// ## Failure containment
///
/// Every failure mode is converted to [LlamaFailure] here rather than thrown
/// raw: the worker dying, a command timing out, a reply of the wrong shape. Call
/// sites then have one error type to handle, and cannot accidentally await
/// forever on a dead isolate.
final class WorkerConnection {
  WorkerConnection._(this._replyPort, this._errorPort);

  /// Spawns the worker and waits for its command port.
  ///
  /// Returns a connection that is ready to accept commands. Throws
  /// [LlamaFailure] if the isolate fails to start — which on desktop usually
  /// means the shim library is missing from the output directory.
  static Future<WorkerConnection> open() async {
    final replies = ReceivePort();
    final errors = ReceivePort();
    final ready = Completer<SendPort>();

    final connection = WorkerConnection._(replies, errors);
    replies.listen(connection._onReply);

    errors.listen((Object? message) {
      // An error on this port means the isolate terminated unexpectedly. Every
      // pending call must fail; otherwise the caller hangs on a future that can
      // never complete.
      connection._failPending(
        LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'inference worker terminated: $message',
        ),
      );
      if (!ready.isCompleted) {
        ready.completeError(
          LlamaFailure(
            kind: LlamaFailureKind.libraryUnavailable,
            message: 'inference worker failed to start: $message',
          ),
        );
      }
    });

    try {
      await Isolate.spawn(
        workerMain,
        replies.sendPort,
        onError: errors.sendPort,
        onExit: errors.sendPort,
        debugName: 'llama-inference',
      );
    } on Object catch (error) {
      // Close the ports this connection opened, but do not send a dispose
      // command: there is no worker to receive it.
      connection.closePorts();
      throw LlamaFailure(
        kind: LlamaFailureKind.libraryUnavailable,
        message: 'could not spawn the inference worker: $error',
        cause: error,
      );
    }

    connection._commands = await ready.future;
    return connection;
  }

  final ReceivePort _replyPort;
  final ReceivePort _errorPort;

  SendPort? _commands;
  bool _closed = false;

  Completer<Object?>? _pending;
  _TokenSink? _sink;

  /// Loads a model, replacing any previously loaded one.
  Future<void> load(String modelPath, EngineOptions options) {
    return _send(LoadModel(modelPath, options, _replyPort.sendPort));
  }

  /// Reads the loaded model's metadata.
  Future<ModelInfo> info() async {
    final reply = await _send(ReadModelInfo(_replyPort.sendPort));
    return reply as ModelInfo;
  }

  /// Applies the model's chat template; null when the GGUF carries none.
  Future<String?> formatPrompt(
    List<String> roles,
    List<String> contents,
  ) async {
    final reply = await _send(
      FormatPrompt(roles, contents, _replyPort.sendPort),
    );
    if (reply is NoChatTemplate) return null;
    return reply as String;
  }

  /// Streams one completion.
  ///
  /// Emits text pieces and completes with the generated token count. Failures
  /// arrive as [LlamaFailure] on the stream.
  Stream<String> generate(String prompt, GenerationOptions options) {
    final controller = StreamController<String>();
    final sink = _TokenSink(
      onToken: (text) {
        if (!controller.isClosed) controller.add(text);
      },
      onDone: (Object? error) {
        if (controller.isClosed) return;
        if (error != null) {
          controller.addError(error);
          // `addError` leaves the stream open; close it explicitly so a caller
          // awaiting the last token does not hang on a stream that never ends.
        }
        unawaited(controller.close());
      },
    );

    _sink = sink;
    try {
      // Intentionally not awaited: the completion arrives through the sink, one
      // token at a time, and this future settles only at the end.
      unawaited(_send(StartGeneration(prompt, options, _replyPort.sendPort)));
    } on LlamaFailure catch (failure) {
      _sink = null;
      if (!controller.isClosed) {
        controller.addError(failure);
        unawaited(controller.close());
      }
    }

    // Cancelling the subscription stops forwarding to a listener that has gone
    // away, but the native loop keeps running until its token budget is spent;
    // that is llama.cpp's behaviour, and killing it mid-call is not safe.
    controller.onCancel = () {
      if (identical(_sink, sink)) _sink = null;
    };

    return controller.stream;
  }

  /// Clears the KV cache.
  Future<void> reset() => _send(ResetContext(_replyPort.sendPort));

  /// Releases the worker and everything it holds.
  Future<void> close() async {
    if (_closed) return;
    // The dispose command goes out **before** `_closed` is set: `_send` refuses
    // once it is, so flipping the flag first would make the ack unwaitable and
    // leave native handles allocated when the process exits.
    final commands = _commands;
    if (commands != null) {
      try {
        await _send(
          DisposeWorker(_replyPort.sendPort),
        ).timeout(const Duration(seconds: 5), onTimeout: () => null);
      } on Object {
        // The worker may already be gone; disposal must never throw.
      }
    }
    _closed = true;
    _failPending(
      const LlamaFailure(
        kind: LlamaFailureKind.invalidState,
        message: 'inference worker was closed.',
      ),
    );
    closePorts();
  }

  /// Closes the receive ports. Separate from [close] so a caller tearing down
  /// after a crash does not have to re-send a dispose command that cannot land.
  void closePorts() {
    _replyPort.close();
    _errorPort.close();
  }

  void _onReply(Object? message) {
    switch (message) {
      case TokenPiece(:final text):
        _sink?.onToken(text);
      case WorkerOk(:final value):
        if (value is int) {
          // A generation's terminal reply: the token count.
          _finishSink(null);
        } else {
          final pending = _pending;
          _pending = null;
          pending?.complete(value);
        }
      case NoChatTemplate():
        final pending = _pending;
        _pending = null;
        pending?.complete(message);
      case WorkerFailure():
        final failure = message.toFailure();
        if (_sink != null) {
          _finishSink(failure);
        } else {
          final pending = _pending;
          _pending = null;
          pending?.completeError(failure);
        }
      default:
        // `null` is the expected ack for commands whose success carries nothing.
        final pending = _pending;
        _pending = null;
        pending?.complete(message);
    }
  }

  void _finishSink(Object? error) {
    final sink = _sink;
    _sink = null;
    sink?.onDone(error);
  }

  void _failPending(LlamaFailure failure) {
    final pending = _pending;
    _pending = null;
    pending?.completeError(failure);
    _finishSink(failure);
  }

  Future<Object?> _send(WorkerCommand command) {
    if (_closed) {
      return Future.error(
        const LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'The engine has been released.',
        ),
      );
    }
    final commands = _commands;
    if (commands == null) {
      return Future.error(
        const LlamaFailure(
          kind: LlamaFailureKind.invalidState,
          message: 'The inference worker is not ready.',
        ),
      );
    }
    final completer = Completer<Object?>();
    _pending = completer;
    commands.send(command);
    return completer.future;
  }
}

/// Callbacks for one generation's token stream.
final class _TokenSink {
  const _TokenSink({required this.onToken, required this.onDone});

  final void Function(String text) onToken;
  final void Function(Object? error) onDone;
}
