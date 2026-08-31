import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/health_event/data/repositories/lucent.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'health_event.g.dart';

@riverpod
HealthEventRepository healthEventRepository(Ref ref) {
  return LucentHealthEventRepository(
    apiClient: ref.watch(lucentClientProvider).healthEvents,
  );
}
