import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/data/providers/sessions.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';

class AuthSessionsController extends AsyncNotifier<List<AuthDeviceSession>> {
  @override
  Future<List<AuthDeviceSession>> build() {
    return _listSessions();
  }

  Future<List<AuthDeviceSession>> _listSessions() async {
    final result = await ref
        .read(authSessionsRepositoryProvider)
        .listSessions()
        .run();
    return result.fold((failure) => throw failure, (value) => value);
  }

  Future<bool> revokeSession(AuthDeviceSession session) async {
    final previous = state.asData?.value;
    final result = await ref
        .read(authSessionsRepositoryProvider)
        .revokeSession(session.id)
        .run();
    return switch (result) {
      Left(:final value) => _revokeFailure(previous, value),
      Right() => _revokeSuccess(session),
    };
  }

  bool _revokeFailure(
    List<AuthDeviceSession>? previous,
    LucentFailure failure,
  ) {
    state = previous == null
        ? AsyncError(failure, StackTrace.current)
        : AsyncData(previous);
    return false;
  }

  Future<bool> _revokeSuccess(AuthDeviceSession session) async {
    if (session.isCurrent) {
      await ref.read(authSessionProvider.notifier).logout();
      return true;
    }
    state = AsyncData(await _listSessions());
    return true;
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_listSessions);
  }
}

final authSessionsControllerProvider =
    AsyncNotifierProvider<AuthSessionsController, List<AuthDeviceSession>>(
      AuthSessionsController.new,
    );
