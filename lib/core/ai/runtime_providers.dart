import 'package:luminous/core/ai/runtime_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'runtime_providers.g.dart';

@riverpod
AiRuntimeEnvironment aiRuntimeEnvironment(Ref ref) {
  return AiRuntimeEnvironment.fromPlatform();
}

@riverpod
AiRuntimeConfig aiRuntimeConfig(Ref ref) {
  final environment = ref.watch(aiRuntimeEnvironmentProvider);
  return AiRuntimeConfig.fromEnvironment(environment);
}
