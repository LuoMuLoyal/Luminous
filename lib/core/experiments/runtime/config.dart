// Experimental dev seam — not part of the shipping assistant path.
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

/// 实验性 runtime 的提供方种类。
///
/// 值是**本地推理后端**，不是"AI"：它回答的问题是「这台设备上跑哪个引擎」，
/// 而不是「有没有 AI」。`localRuntime` 与 feature flag 的 `onDeviceRuntime`
/// 说的是同一件事，两者不再用两套词汇。
enum RuntimeProviderKind { none, localRuntime, genUi, custom }

extension RuntimeProviderKindX on RuntimeProviderKind {
  static RuntimeProviderKind parse(String rawValue) {
    switch (rawValue.trim().toLowerCase()) {
      // 历史别名保留：这些字符串可能已经存在于旧构建的环境变量与
      // SharedPreferences 里，删掉会让老配置静默回落 `none`。
      case 'ai_toolkit':
      case 'aitoolkit':
      case 'toolkit':
      case 'local_runtime':
      case 'localruntime':
        return RuntimeProviderKind.localRuntime;
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
