import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';

abstract interface class AuthSessionsRepository {
  TaskEither<LucentFailure, List<AuthDeviceSession>> listSessions();

  TaskEither<LucentFailure, void> revokeSession(String sessionId);
}
