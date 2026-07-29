import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/ai/runtime_config.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

void main() {
  setUp(() {
    EnvReader.clearTestValues();
  });

  tearDown(() {
    EnvReader.clearTestValues();
  });

  group('AiRuntimeProviderKindX.parse', () {
    test('parses "ai_toolkit" as aiToolkit', () {
      expect(
        AiRuntimeProviderKindX.parse('ai_toolkit'),
        AiRuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "aitoolkit" as aiToolkit', () {
      expect(
        AiRuntimeProviderKindX.parse('aitoolkit'),
        AiRuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "toolkit" as aiToolkit', () {
      expect(
        AiRuntimeProviderKindX.parse('toolkit'),
        AiRuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "gen_ui" as genUi', () {
      expect(
        AiRuntimeProviderKindX.parse('gen_ui'),
        AiRuntimeProviderKind.genUi,
      );
    });

    test('parses "genui" as genUi', () {
      expect(
        AiRuntimeProviderKindX.parse('genui'),
        AiRuntimeProviderKind.genUi,
      );
    });

    test('parses "custom" as custom', () {
      expect(
        AiRuntimeProviderKindX.parse('custom'),
        AiRuntimeProviderKind.custom,
      );
    });

    test('parses unknown value as none', () {
      expect(
        AiRuntimeProviderKindX.parse('unknown'),
        AiRuntimeProviderKind.none,
      );
    });

    test('parses empty string as none', () {
      expect(AiRuntimeProviderKindX.parse(''), AiRuntimeProviderKind.none);
    });

    test('trims and lowercases input', () {
      expect(
        AiRuntimeProviderKindX.parse('  AI_TOOLKIT  '),
        AiRuntimeProviderKind.aiToolkit,
      );
      expect(
        AiRuntimeProviderKindX.parse('  Custom  '),
        AiRuntimeProviderKind.custom,
      );
    });
  });

  group('AiRuntimeConfig', () {
    test('exposesLocalRuntime is false when disabled', () {
      const config = AiRuntimeConfig(
        enabled: false,
        provider: AiRuntimeProviderKind.aiToolkit,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isFalse);
    });

    test('exposesLocalRuntime is false when provider is none', () {
      const config = AiRuntimeConfig(
        enabled: true,
        provider: AiRuntimeProviderKind.none,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isFalse);
    });

    test(
      'exposesLocalRuntime is true when enabled and provider is not none',
      () {
        const config = AiRuntimeConfig(
          enabled: true,
          provider: AiRuntimeProviderKind.aiToolkit,
          genUiEnabled: false,
        );
        expect(config.exposesLocalRuntime, isTrue);
      },
    );

    test('exposesLocalRuntime is true for genUi provider', () {
      const config = AiRuntimeConfig(
        enabled: true,
        provider: AiRuntimeProviderKind.genUi,
        genUiEnabled: true,
      );
      expect(config.exposesLocalRuntime, isTrue);
    });

    test('exposesLocalRuntime is true for custom provider', () {
      const config = AiRuntimeConfig(
        enabled: true,
        provider: AiRuntimeProviderKind.custom,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isTrue);
    });

    test('fromEnvironment copies values from environment', () {
      const env = AiRuntimeEnvironment(
        enabled: true,
        provider: AiRuntimeProviderKind.aiToolkit,
        genUiEnabled: true,
      );
      final config = AiRuntimeConfig.fromEnvironment(env);
      expect(config.enabled, isTrue);
      expect(config.provider, AiRuntimeProviderKind.aiToolkit);
      expect(config.genUiEnabled, isTrue);
    });
  });

  group('AiRuntimeEnvironment.fromPlatform', () {
    test('reads enabled from env', () {
      EnvReader.setTestValue(EnvKey.luminousExperimentalAiRuntime, 'true');
      final env = AiRuntimeEnvironment.fromPlatform();
      expect(env.enabled, isTrue);
    });

    test('reads provider from env', () {
      EnvReader.setTestValue(EnvKey.luminousAiRuntimeProvider, 'ai_toolkit');
      final env = AiRuntimeEnvironment.fromPlatform();
      expect(env.provider, AiRuntimeProviderKind.aiToolkit);
    });

    test('reads genUiEnabled from env', () {
      EnvReader.setTestValue(EnvKey.luminousEnableGenUi, 'true');
      final env = AiRuntimeEnvironment.fromPlatform();
      expect(env.genUiEnabled, isTrue);
    });

    test('defaults when no env values set', () {
      final env = AiRuntimeEnvironment.fromPlatform();
      expect(env.enabled, isFalse);
      expect(env.provider, AiRuntimeProviderKind.none);
      expect(env.genUiEnabled, isFalse);
    });

    test('parses provider string through AiRuntimeProviderKindX', () {
      EnvReader.setTestValue(EnvKey.luminousAiRuntimeProvider, 'gen_ui');
      final env = AiRuntimeEnvironment.fromPlatform();
      expect(env.provider, AiRuntimeProviderKind.genUi);
    });
  });
}
