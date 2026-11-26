import 'package:flutter_test/flutter_test.dart';
import 'package:llama_native/llama_native.dart';

/// Domain rules.
///
/// These run without a native library, a model file, or an isolate — which is
/// the point of keeping them in `domain/`: the rules that decide what the app
/// does on cancellation, on a missing template, on bad parameters are all
/// testable in milliseconds.
void main() {
  group('GenerationOptions', () {
    test('rejects a temperature outside the sampler range', () {
      expect(
        () => GenerationOptions(temperature: -0.1),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => GenerationOptions(temperature: 2.5),
        throwsA(isA<RangeError>()),
      );
    });

    test('rejects a topP of zero or above one', () {
      // topP 0 would leave the sampler with an empty candidate set: llama.cpp
      // does not treat it as "greedy", it degenerates.
      expect(() => GenerationOptions(topP: 0), throwsA(isA<RangeError>()));
      expect(() => GenerationOptions(topP: 1.5), throwsA(isA<RangeError>()));
    });

    test('rejects a non-positive repetition penalty', () {
      expect(
        () => GenerationOptions(repeatPenalty: 0),
        throwsA(isA<RangeError>()),
      );
    });

    test('copyWith replaces only the given fields', () {
      final base = GenerationOptions();
      final narrowed = base.copyWith(maxTokens: 64, grammar: 'root ::= "x"');

      expect(narrowed.maxTokens, 64);
      expect(narrowed.grammar, 'root ::= "x"');
      // Everything else is inherited, which is what makes copyWith usable for
      // one-off overrides without restating the defaults.
      expect(narrowed.temperature, base.temperature);
      expect(narrowed.stopSequences, isEmpty);
    });
  });

  group('EngineOptions', () {
    test('rejects a batch larger than the context', () {
      // llama.cpp would fail the decode instead of reporting a bad parameter,
      // and the failure surfaces mid-generation.
      expect(
        () => EngineOptions(contextLength: 512, batchSize: 1024),
        throwsA(isA<RangeError>()),
      );
    });

    test('rejects out-of-range thread and context values', () {
      expect(() => EngineOptions(threads: 0), throwsA(isA<RangeError>()));
      expect(
        () => EngineOptions(contextLength: 128),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('LlamaFailure', () {
    test('only a decode failure is retryable', () {
      // Everything else is configuration: retrying an unreadable model or a bad
      // grammar fails identically, and the app should offer a different action
      // rather than a retry button.
      expect(
        const LlamaFailure(
          kind: LlamaFailureKind.decodeFailed,
          message: 'x',
        ).isRetryable,
        isTrue,
      );
      for (final kind in LlamaFailureKind.values) {
        if (kind == LlamaFailureKind.decodeFailed) continue;
        expect(
          LlamaFailure(kind: kind, message: 'x').isRetryable,
          isFalse,
          reason: '${kind.name} should not be presented as retryable',
        );
      }
    });
  });

  group('CollectGeneration', () {
    test('concatenates pieces into the final text', () async {
      const collect = CollectGeneration();

      final result = await collect(
        stream: Stream.fromIterable(['Hel', 'lo, ', 'wor', 'ld']),
      );

      expect(result.text, 'Hello, world');
      expect(result.completionTokens, 4);
      expect(result.cancelled, isFalse);
    });

    test('keeps partial text when the caller cancels', () async {
      // A stop is a normal end: the user already saw this text, so discarding
      // it would make the screen flicker back.
      const collect = CollectGeneration();

      final result = await collect(
        stream: Stream.fromIterable(['abc', 'def', 'ghi']),
        shouldCancel: (soFar) => soFar.length >= 6,
      );

      expect(result.cancelled, isTrue);
      expect(result.text, 'abcdef');
    });

    test('propagates a stream failure', () async {
      const collect = CollectGeneration();
      final broken = Stream<String>.error(
        const LlamaFailure(
          kind: LlamaFailureKind.decodeFailed,
          message: 'boom',
        ),
      );

      await expectLater(collect(stream: broken), throwsA(isA<LlamaFailure>()));
    });
  });

  group('fallbackChatPrompt', () {
    test('renders a plain transcript ending with the assistant turn', () {
      final prompt = fallbackChatPrompt(const [
        ChatMessage.system('You are concise.'),
        ChatMessage.user('Hi'),
      ]);

      expect(prompt, contains('System: You are concise.'));
      expect(prompt, contains('User: Hi'));
      expect(prompt.trimRight(), endsWith('Assistant:'));
    });
  });

  group('requireLoaded', () {
    test('throws a configuration failure rather than returning null', () {
      expect(
        () => requireLoaded(null),
        throwsA(
          isA<LlamaFailure>().having(
            (failure) => failure.kind,
            'kind',
            LlamaFailureKind.invalidState,
          ),
        ),
      );
    });
  });
}
