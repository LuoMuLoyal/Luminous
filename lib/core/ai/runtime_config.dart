import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

enum AiRuntimeProviderKind { none, aiToolkit, genUi, custom }

extension AiRuntimeProviderKindX on AiRuntimeProviderKind {
  static AiRuntimeProviderKind parse(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'ai_toolkit':
      case 'aitoolkit':
      case 'toolkit':
        return AiRuntimeProviderKind.aiToolkit;
      case 'gen_ui':
      case 'genui':
        return AiRuntimeProviderKind.genUi;
      case 'custom':
        return AiRuntimeProviderKind.custom;
      default:
        return AiRuntimeProviderKind.none;
    }
  }
}

class AiRuntimeEnvironment {
  const AiRuntimeEnvironment({
    required this.enabled,
    required this.provider,
    required this.genUiEnabled,
  });

  factory AiRuntimeEnvironment.fromPlatform() {
    final enabled = EnvReader.boolValue(
      EnvKey.luminousExperimentalAiRuntime,
      fallback: false,
    );
    final providerValue = EnvReader.string(
      EnvKey.luminousAiRuntimeProvider,
      fallback: 'none',
    );
    final genUiEnabled = EnvReader.boolValue(
      EnvKey.luminousEnableGenUi,
      fallback: false,
    );

    return AiRuntimeEnvironment._fromEnvironment(
      enabled: enabled,
      providerValue: providerValue,
      genUiEnabled: genUiEnabled,
    );
  }

  AiRuntimeEnvironment._fromEnvironment({
    required this.enabled,
    required String providerValue,
    required this.genUiEnabled,
  }) : provider = AiRuntimeProviderKindX.parse(providerValue);

  final bool enabled;
  final AiRuntimeProviderKind provider;
  final bool genUiEnabled;
}

class AiRuntimeConfig {
  const AiRuntimeConfig({
    required this.enabled,
    required this.provider,
    required this.genUiEnabled,
  });

  factory AiRuntimeConfig.fromEnvironment(AiRuntimeEnvironment environment) {
    return AiRuntimeConfig(
      enabled: environment.enabled,
      provider: environment.provider,
      genUiEnabled: environment.genUiEnabled,
    );
  }

  final bool enabled;
  final AiRuntimeProviderKind provider;
  final bool genUiEnabled;

  bool get exposesLocalRuntime =>
      enabled && provider != AiRuntimeProviderKind.none;
}
