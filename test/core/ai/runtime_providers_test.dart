import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/ai/runtime_config.dart';
import 'package:luminous/core/ai/runtime_providers.dart';

void main() {
  group('AiRuntimeProviderKind', () {
    test('parses known provider names', () {
      expect(
        AiRuntimeProviderKindX.parse('ai_toolkit'),
        AiRuntimeProviderKind.aiToolkit,
      );
      expect(
        AiRuntimeProviderKindX.parse('gen_ui'),
        AiRuntimeProviderKind.genUi,
      );
      expect(
        AiRuntimeProviderKindX.parse('custom'),
        AiRuntimeProviderKind.custom,
      );
    });

    test('falls back to none for unknown values', () {
      expect(
        AiRuntimeProviderKindX.parse('lucent'),
        AiRuntimeProviderKind.none,
      );
    });
  });

  group('aiRuntimeConfigProvider', () {
    test('defaults to disabled local runtime', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final config = container.read(aiRuntimeConfigProvider);

      expect(config.enabled, isFalse);
      expect(config.provider, AiRuntimeProviderKind.none);
      expect(config.genUiEnabled, isFalse);
      expect(config.exposesLocalRuntime, isFalse);
    });

    test('reflects overridden experiment environment', () {
      final container = ProviderContainer(
        overrides: [
          aiRuntimeEnvironmentProvider.overrideWithValue(
            const AiRuntimeEnvironment(
              enabled: true,
              provider: AiRuntimeProviderKind.aiToolkit,
              genUiEnabled: true,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final config = container.read(aiRuntimeConfigProvider);

      expect(config.enabled, isTrue);
      expect(config.provider, AiRuntimeProviderKind.aiToolkit);
      expect(config.genUiEnabled, isTrue);
      expect(config.exposesLocalRuntime, isTrue);
    });
  });
}
