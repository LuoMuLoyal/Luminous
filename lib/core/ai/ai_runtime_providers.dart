import 'package:luminous/core/ai/ai_runtime_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_runtime_providers.g.dart';

@riverpod
AiRuntimeEnvironment aiRuntimeEnvironment(Ref ref) {
  return AiRuntimeEnvironment.fromPlatform();
}

@riverpod
AiRuntimeConfig aiRuntimeConfig(Ref ref) {
  final environment = ref.watch(aiRuntimeEnvironmentProvider);
  return AiRuntimeConfig.fromEnvironment(environment);
}
