import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/experiments/runtime/config.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

void main() {
  setUp(() {
    EnvReader.clearTestValues();
  });

  tearDown(() {
    EnvReader.clearTestValues();
  });

  group('RuntimeProviderKindX.parse', () {
    test('parses "ai_toolkit" as aiToolkit', () {
      expect(
        RuntimeProviderKindX.parse('ai_toolkit'),
        RuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "aitoolkit" as aiToolkit', () {
      expect(
        RuntimeProviderKindX.parse('aitoolkit'),
        RuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "toolkit" as aiToolkit', () {
      expect(
        RuntimeProviderKindX.parse('toolkit'),
        RuntimeProviderKind.aiToolkit,
      );
    });

    test('parses "gen_ui" as genUi', () {
      expect(RuntimeProviderKindX.parse('gen_ui'), RuntimeProviderKind.genUi);
    });

    test('parses "genui" as genUi', () {
      expect(RuntimeProviderKindX.parse('genui'), RuntimeProviderKind.genUi);
    });

    test('parses "custom" as custom', () {
      expect(RuntimeProviderKindX.parse('custom'), RuntimeProviderKind.custom);
    });

    test('parses unknown value as none', () {
      expect(RuntimeProviderKindX.parse('unknown'), RuntimeProviderKind.none);
    });

    test('parses empty string as none', () {
      expect(RuntimeProviderKindX.parse(''), RuntimeProviderKind.none);
    });

    test('trims and lowercases input', () {
      expect(
        RuntimeProviderKindX.parse('  AI_TOOLKIT  '),
        RuntimeProviderKind.aiToolkit,
      );
      expect(
        RuntimeProviderKindX.parse('  Custom  '),
        RuntimeProviderKind.custom,
      );
    });
  });

  group('RuntimeConfig', () {
    test('exposesLocalRuntime is false when disabled', () {
      const config = RuntimeConfig(
        enabled: false,
        provider: RuntimeProviderKind.aiToolkit,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isFalse);
    });

    test('exposesLocalRuntime is false when provider is none', () {
      const config = RuntimeConfig(
        enabled: true,
        provider: RuntimeProviderKind.none,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isFalse);
    });

    test(
      'exposesLocalRuntime is true when enabled and provider is not none',
      () {
        const config = RuntimeConfig(
          enabled: true,
          provider: RuntimeProviderKind.aiToolkit,
          genUiEnabled: false,
        );
        expect(config.exposesLocalRuntime, isTrue);
      },
    );

    test('exposesLocalRuntime is true for genUi provider', () {
      const config = RuntimeConfig(
        enabled: true,
        provider: RuntimeProviderKind.genUi,
        genUiEnabled: true,
      );
      expect(config.exposesLocalRuntime, isTrue);
    });

    test('exposesLocalRuntime is true for custom provider', () {
      const config = RuntimeConfig(
        enabled: true,
        provider: RuntimeProviderKind.custom,
        genUiEnabled: false,
      );
      expect(config.exposesLocalRuntime, isTrue);
    });

    test('fromEnvironment copies values from environment', () {
      const env = RuntimeEnvironment(
        enabled: true,
        provider: RuntimeProviderKind.aiToolkit,
        genUiEnabled: true,
      );
      final config = RuntimeConfig.fromEnvironment(env);
      expect(config.enabled, isTrue);
      expect(config.provider, RuntimeProviderKind.aiToolkit);
      expect(config.genUiEnabled, isTrue);
    });
  });

  group('RuntimeEnvironment.fromPlatform', () {
    test('reads enabled from env', () {
      EnvReader.setTestValue(EnvKey.luminousExperimentalRuntimeEnabled, 'true');
      final env = RuntimeEnvironment.fromPlatform();
      expect(env.enabled, isTrue);
    });

    test('reads provider from env', () {
      EnvReader.setTestValue(EnvKey.luminousRuntimeProvider, 'ai_toolkit');
      final env = RuntimeEnvironment.fromPlatform();
      expect(env.provider, RuntimeProviderKind.aiToolkit);
    });

    test('reads genUiEnabled from env', () {
      EnvReader.setTestValue(EnvKey.luminousEnableGenUi, 'true');
      final env = RuntimeEnvironment.fromPlatform();
      expect(env.genUiEnabled, isTrue);
    });

    test('defaults when no env values set', () {
      final env = RuntimeEnvironment.fromPlatform();
      expect(env.enabled, isFalse);
      expect(env.provider, RuntimeProviderKind.none);
      expect(env.genUiEnabled, isFalse);
    });

    test('parses provider string through RuntimeProviderKindX', () {
      EnvReader.setTestValue(EnvKey.luminousRuntimeProvider, 'gen_ui');
      final env = RuntimeEnvironment.fromPlatform();
      expect(env.provider, RuntimeProviderKind.genUi);
    });
  });
}
