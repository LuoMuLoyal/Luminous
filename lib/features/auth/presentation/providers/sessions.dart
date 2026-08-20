import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/data/providers/sessions.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';

class AuthSessionsController extends AsyncNotifier<List<AuthDeviceSession>> {
  @override
  Future<List<AuthDeviceSession>> build() {
    return ref.watch(authSessionsRepositoryProvider).listSessions();
  }

  Future<bool> revokeSession(AuthDeviceSession session) async {
    final previous = state.asData?.value;
    try {
      await ref.read(authSessionsRepositoryProvider).revokeSession(session.id);
      if (session.isCurrent) {
        await ref.read(authSessionProvider.notifier).logout();
        return true;
      }
      state = AsyncData(
        await ref.read(authSessionsRepositoryProvider).listSessions(),
      );
      return true;
    } catch (error, stackTrace) {
      state = previous == null
          ? AsyncError(error, stackTrace)
          : AsyncData(previous);
      return false;
    }
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authSessionsRepositoryProvider).listSessions(),
    );
  }
}

final authSessionsControllerProvider =
    AsyncNotifierProvider<AuthSessionsController, List<AuthDeviceSession>>(
      AuthSessionsController.new,
    );
