// Experimental dev seam — not part of the shipping assistant path.
import 'package:luminous/core/experiments/runtime/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
RuntimeEnvironment runtimeEnvironment(Ref ref) {
  return RuntimeEnvironment.fromPlatform();
}

@riverpod
RuntimeConfig runtimeConfig(Ref ref) {
  final environment = ref.watch(runtimeEnvironmentProvider);
  return RuntimeConfig.fromEnvironment(environment);
}
