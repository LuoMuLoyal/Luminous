import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_event.g.dart';

@Riverpod(keepAlive: true)
class ActiveHealthEvent extends _$ActiveHealthEvent {
  @override
  Future<HealthEvent?> build() {
    return authGuarded(
      ref: ref,
      fetch: () => ref.watch(healthEventRepositoryProvider).fetchActive(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => authGuarded(
        ref: ref,
        fetch: () => ref.read(healthEventRepositoryProvider).fetchActive(),
      ),
    );
  }
}
