import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/experiments/runtime/config.dart';
import 'package:luminous/core/experiments/runtime/providers.dart';
import '../../../helpers/kv_test_store.dart';

void main() {
  setUp(() {
    KvTestStore.install();
  });

  group('RuntimeProviderKind', () {
    test('parses known provider names', () {
      expect(
        RuntimeProviderKindX.parse('ai_toolkit'),
        RuntimeProviderKind.aiToolkit,
      );
      expect(RuntimeProviderKindX.parse('gen_ui'), RuntimeProviderKind.genUi);
      expect(RuntimeProviderKindX.parse('custom'), RuntimeProviderKind.custom);
    });

    test('falls back to none for unknown values', () {
      expect(RuntimeProviderKindX.parse('lucent'), RuntimeProviderKind.none);
    });
  });

  group('runtimeConfigProvider', () {
    test('defaults to disabled local runtime', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final config = container.read(runtimeConfigProvider);

      expect(config.enabled, isFalse);
      expect(config.provider, RuntimeProviderKind.none);
      expect(config.genUiEnabled, isFalse);
      expect(config.exposesLocalRuntime, isFalse);
    });

    test('reflects overridden experiment environment', () {
      final container = ProviderContainer(
        overrides: [
          runtimeEnvironmentProvider.overrideWithValue(
            const RuntimeEnvironment(
              enabled: true,
              provider: RuntimeProviderKind.aiToolkit,
              genUiEnabled: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final config = container.read(runtimeConfigProvider);

      expect(config.enabled, isTrue);
      expect(config.provider, RuntimeProviderKind.aiToolkit);
      expect(config.genUiEnabled, isTrue);
      expect(config.exposesLocalRuntime, isTrue);
    });
  });
}
