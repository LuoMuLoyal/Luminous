import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/ai/ai_runtime_config.dart';

final aiRuntimeEnvironmentProvider = Provider<AiRuntimeEnvironment>((ref) {
  return AiRuntimeEnvironment.fromPlatform();
});

final aiRuntimeConfigProvider = Provider<AiRuntimeConfig>((ref) {
  final environment = ref.watch(aiRuntimeEnvironmentProvider);
  return AiRuntimeConfig.fromEnvironment(environment);
});
