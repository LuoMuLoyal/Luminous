import 'package:flutter_test/flutter_test.dart';
import 'package:llama_native/llama_native.dart';

/// A [LlamaBridge] that records calls and replays scripted behaviour.
///
/// This is the payoff of the injected seam: every rule in `RustLlamaEngine` —
/// released-state handling, empty-input guards, error translation, stream
/// flattening — is exercised here without a model file or a native library.
final class FakeBridge implements LlamaBridge {
  FakeBridge({
    this.info = const ModelInfo(
      architecture: 'qwen3',
      name: 'fake',
      trainedContextLength: 4096,
      embeddingSize: 1024,
      layerCount: 24,
      hasChatTemplate: true,
    ),
    this.templateResult = 'PROMPT',
    this.tokenScript = const ['He', 'llo'],
    this.failAfterPieces,
    this.loadError,
  });

  final ModelInfo info;
  final String? templateResult;

  /// Pieces to emit before [failAfterPieces] (if any) fires.
  final List<String> tokenScript;
  final Object? failAfterPieces;
  final Object? loadError;

  int loadCalls = 0;
  int infoCalls = 0;
  int formatCalls = 0;
  int generateCalls = 0;
  int releaseCalls = 0;
  String? lastPrompt;
  GenerationOptions? lastOptions;

  @override
  Future<Object> loadSession({
    required String modelPath,
    required EngineOptions options,
  }) async {
    loadCalls += 1;
    if (loadError != null) throw loadError!;
    return Object();
  }

  @override
  Future<ModelInfo> sessionInfo(Object session) async {
    infoCalls += 1;
    return info;
  }

  @override
  Future<String?> formatChatPrompt({
    required Object session,
    required List<ChatMessage> messages,
  }) async {
    formatCalls += 1;
    return templateResult;
  }

  @override
  Stream<TokenEvent> generate({
    required Object session,
    required String prompt,
    required GenerationOptions options,
  }) async* {
    generateCalls += 1;
    lastPrompt = prompt;
    lastOptions = options;
    for (final piece in tokenScript) {
      yield TokenEvent.piece(piece);
    }
    final failure = failAfterPieces;
    if (failure != null) {
      yield TokenEvent.failure(failure);
    }
  }

  @override
  Future<void> releaseSession(Object session) async {
    releaseCalls += 1;
  }
}

void main() {
  group('RustLlamaEngine', () {
    test('open loads a session and reports model info', () async {
      final bridge = FakeBridge();
      final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

      final info = await engine.info();

      expect(bridge.loadCalls, 1);
      expect(info.architecture, 'qwen3');
      expect(info.trainedContextLength, 4096);
      expect(info.hasChatTemplate, isTrue);
    });

    test('open translates a bridge failure into LlamaFailure', () async {
      // A bridge that throws a raw error must not leak it to the app: callers
      // branch on LlamaFailureKind, and a raw exception has no kind.
      final bridge = FakeBridge(
        loadError: Exception('ModelUnreadable: no such file'),
      );

      await expectLater(
        RustLlamaEngine.open(bridge, 'missing.gguf'),
        throwsA(
          isA<LlamaFailure>().having(
            (failure) => failure.kind,
            'kind',
            LlamaFailureKind.modelUnreadable,
          ),
        ),
      );
    });

    test('generate yields pieces in order', () async {
      final bridge = FakeBridge(tokenScript: const ['a', 'b', 'c']);
      final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

      final pieces = await engine.generate('hi').toList();

      expect(pieces, ['a', 'b', 'c']);
      expect(bridge.lastPrompt, 'hi');
    });

    test(
      'a mid-stream failure surfaces after the pieces already emitted',
      () async {
        // The important behaviour: a local model can fail after it has already
        // produced text, and the app must be able to keep that text.
        final bridge = FakeBridge(
          tokenScript: const ['Hello'],
          failAfterPieces: Exception('DecodeFailed: kv cache exhausted'),
        );
        final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

        final seen = <String>[];
        Object? caught;
        try {
          await for (final piece in engine.generate('hi')) {
            seen.add(piece);
          }
        } on Object catch (error) {
          caught = error;
        }

        expect(seen, ['Hello']);
        expect(
          caught,
          isA<LlamaFailure>().having(
            (failure) => failure.kind,
            'kind',
            LlamaFailureKind.decodeFailed,
          ),
        );
      },
    );

    test('an empty prompt is rejected without calling the bridge', () async {
      final bridge = FakeBridge();
      final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

      await expectLater(
        engine.generate('').toList(),
        throwsA(
          isA<LlamaFailure>().having(
            (failure) => failure.kind,
            'kind',
            LlamaFailureKind.promptRejected,
          ),
        ),
      );
      expect(bridge.generateCalls, 0);
    });

    test(
      'an empty conversation is rejected without calling the bridge',
      () async {
        final bridge = FakeBridge();
        final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

        await expectLater(
          engine.formatChatPrompt(const []),
          throwsA(isA<LlamaFailure>()),
        );
        expect(bridge.formatCalls, 0);
      },
    );

    test('release is idempotent and the bridge is called once', () async {
      final bridge = FakeBridge();
      final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

      await engine.release();
      await engine.release();

      expect(bridge.releaseCalls, 1);
    });

    test('a released engine refuses further work', () async {
      final bridge = FakeBridge();
      final engine = await RustLlamaEngine.open(bridge, 'model.gguf');
      await engine.release();

      await expectLater(
        engine.info(),
        throwsA(
          isA<LlamaFailure>().having(
            (failure) => failure.kind,
            'kind',
            LlamaFailureKind.invalidState,
          ),
        ),
      );
      await expectLater(
        engine.generate('hi').toList(),
        throwsA(isA<LlamaFailure>()),
      );
      // The guards run before the bridge, so nothing reached native code.
      expect(bridge.infoCalls, 0);
      expect(bridge.generateCalls, 0);
    });

    test(
      'a missing chat template is reported as null, not as a failure',
      () async {
        // Models without a template are supported via `fallbackChatPrompt`; that
        // path only works if "no template" is distinguishable from "call failed".
        final bridge = FakeBridge(templateResult: null);
        final engine = await RustLlamaEngine.open(bridge, 'model.gguf');

        final prompt = await engine.formatChatPrompt(const [
          ChatMessage.user('hi'),
        ]);

        expect(prompt, isNull);
      },
    );
  });

  group('mapBridgeErrorKind', () {
    test('recognises each Rust variant by its Display prefix', () {
      // The generated bridge has no typed error channel, so the variant is
      // recovered from the message. This test pins that mapping: it is the one
      // place that breaks if the Rust `Display` impls change.
      const cases = {
        'BackendUnavailable: no backend': LlamaFailureKind.libraryUnavailable,
        'ModelUnreadable: bad gguf': LlamaFailureKind.modelUnreadable,
        'ContextUnavailable: oom': LlamaFailureKind.contextUnavailable,
        'PromptRejected: empty': LlamaFailureKind.promptRejected,
        'DecodeFailed: bad batch': LlamaFailureKind.decodeFailed,
        'GrammarInvalid: root missing': LlamaFailureKind.grammarInvalid,
        'Cancelled': LlamaFailureKind.cancelled,
        'something else entirely': LlamaFailureKind.invalidState,
      };

      for (final entry in cases.entries) {
        expect(
          mapBridgeErrorKind(Exception(entry.key)),
          entry.value,
          reason: entry.key,
        );
      }
    });
  });
}
