// Experimental dev seam — not part of the shipping assistant path.
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

/// 实验性 runtime 的提供方种类。
///
/// 类名不带 `Ai`：目录已经是 `experiments/runtime`，`Ai` 在这里既不精确
/// （它描述的不是"AI"，而是"哪个本地推理后端"），也和 feature flag 里的
/// `onDeviceRuntime` 撞词。
enum RuntimeProviderKind { none, aiToolkit, genUi, custom }

extension RuntimeProviderKindX on RuntimeProviderKind {
  static RuntimeProviderKind parse(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      case 'ai_toolkit':
      case 'aitoolkit':
      case 'toolkit':
        return RuntimeProviderKind.aiToolkit;
      case 'gen_ui':
      case 'genui':
        return RuntimeProviderKind.genUi;
      case 'custom':
        return RuntimeProviderKind.custom;
      default:
        return RuntimeProviderKind.none;
    }
  }
}

/// 从平台环境读到的原始开关。
class RuntimeEnvironment {
  const RuntimeEnvironment({
    required this.enabled,
    required this.provider,
    required this.genUiEnabled,
  });

  factory RuntimeEnvironment.fromPlatform() {
    final enabled = EnvReader.boolValue(
      EnvKey.luminousExperimentalRuntimeEnabled,
      fallback: false,
    );
    final providerValue = EnvReader.string(
      EnvKey.luminousRuntimeProvider,
      fallback: 'none',
    );
    final genUiEnabled = EnvReader.boolValue(
      EnvKey.luminousEnableGenUi,
      fallback: false,
    );

    return RuntimeEnvironment._fromEnvironment(
      enabled: enabled,
      providerValue: providerValue,
      genUiEnabled: genUiEnabled,
    );
  }

  RuntimeEnvironment._fromEnvironment({
    required this.enabled,
    required String providerValue,
    required this.genUiEnabled,
  }) : provider = RuntimeProviderKindX.parse(providerValue);

  final bool enabled;
  final RuntimeProviderKind provider;
  final bool genUiEnabled;
}

/// 解析后的实验配置。
class RuntimeConfig {
  const RuntimeConfig({
    required this.enabled,
    required this.provider,
    required this.genUiEnabled,
  });

  factory RuntimeConfig.fromEnvironment(RuntimeEnvironment environment) {
    return RuntimeConfig(
      enabled: environment.enabled,
      provider: environment.provider,
      genUiEnabled: environment.genUiEnabled,
    );
  }

  final bool enabled;
  final RuntimeProviderKind provider;
  final bool genUiEnabled;

  bool get exposesLocalRuntime =>
      enabled && provider != RuntimeProviderKind.none;
}
