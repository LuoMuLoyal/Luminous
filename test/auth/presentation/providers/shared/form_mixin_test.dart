import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/shared/form_mixin.dart';

/// A simple mutable state for the test notifier.
class _TestState {
  const _TestState({this.cooldownSeconds});
  final int? cooldownSeconds;

  _TestState copyWith({int? cooldownSeconds}) =>
      _TestState(cooldownSeconds: cooldownSeconds);
}

/// A test notifier that exercises [CooldownTimerMixin].
class _TestNotifier extends Notifier<_TestState>
    with CooldownTimerMixin<_TestState> {
  @override
  _TestState build() {
    ref.onDispose(disposeCooldown);
    return const _TestState();
  }

  void startTestCooldown(int seconds) {
    startCooldown(
      seconds,
      getCooldownSeconds: () => state.cooldownSeconds,
      setCooldownSeconds: (value) =>
          state = state.copyWith(cooldownSeconds: value),
    );
  }
}

final _testProvider = NotifierProvider<_TestNotifier, _TestState>(
  _TestNotifier.new,
);

void main() {
  group('CooldownTimerMixin', () {
    late ProviderContainer container;
    late _TestNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      notifier = container.read(_testProvider.notifier);
    });

    test('initial cooldownSeconds is null', () {
      expect(container.read(_testProvider).cooldownSeconds, isNull);
    });

    test('startCooldown sets initial seconds immediately', () {
      notifier.startTestCooldown(60);

      expect(container.read(_testProvider).cooldownSeconds, 60);
    });

    test('cooldown decrements to 0 and clears to null', () async {
      notifier.startTestCooldown(3);

      // Initial value
      expect(container.read(_testProvider).cooldownSeconds, 3);

      // Wait for first tick (1 second)
      await Future.delayed(const Duration(milliseconds: 1050));
      expect(container.read(_testProvider).cooldownSeconds, 2);

      await Future.delayed(const Duration(seconds: 1));
      expect(container.read(_testProvider).cooldownSeconds, 1);

      await Future.delayed(const Duration(seconds: 1));
      // After hitting 1, the timer cancels and sets to null
      expect(container.read(_testProvider).cooldownSeconds, isNull);
    });

    test('cooldown with 1 second immediately clears on first tick', () async {
      notifier.startTestCooldown(1);

      expect(container.read(_testProvider).cooldownSeconds, 1);

      await Future.delayed(const Duration(milliseconds: 1050));
      expect(container.read(_testProvider).cooldownSeconds, isNull);
    });

    test('startCooldown cancels previous timer', () async {
      notifier.startTestCooldown(10);
      expect(container.read(_testProvider).cooldownSeconds, 10);

      // Start a new cooldown before the first finishes
      notifier.startTestCooldown(5);
      expect(container.read(_testProvider).cooldownSeconds, 5);

      // Wait and verify only the second timer is active
      await Future.delayed(const Duration(milliseconds: 1050));
      expect(container.read(_testProvider).cooldownSeconds, 4);
    });

    test(
      'disposeCooldown cancels timer and prevents further updates',
      () async {
        notifier.startTestCooldown(10);
        expect(container.read(_testProvider).cooldownSeconds, 10);

        notifier.disposeCooldown();

        // Wait and verify no more updates happen
        await Future.delayed(const Duration(milliseconds: 1050));
        expect(container.read(_testProvider).cooldownSeconds, 10);
      },
    );

    test('cooldown with 0 seconds clears on first tick', () async {
      notifier.startTestCooldown(0);

      // 0 <= 1, so first tick immediately cancels and sets null
      expect(container.read(_testProvider).cooldownSeconds, 0);

      await Future.delayed(const Duration(milliseconds: 1050));
      expect(container.read(_testProvider).cooldownSeconds, isNull);
    });

    test('multiple startCooldown calls only keep the latest', () async {
      notifier.startTestCooldown(100);
      notifier.startTestCooldown(50);
      notifier.startTestCooldown(5);

      expect(container.read(_testProvider).cooldownSeconds, 5);

      await Future.delayed(const Duration(milliseconds: 1050));
      expect(container.read(_testProvider).cooldownSeconds, 4);
    });

    test('invalidate provider cancels timer via onDispose', () async {
      notifier.startTestCooldown(10);
      expect(container.read(_testProvider).cooldownSeconds, 10);

      container.invalidate(_testProvider);

      // Wait to verify the timer was cancelled (no error thrown)
      await Future.delayed(const Duration(milliseconds: 1050));
    });
  });
}
