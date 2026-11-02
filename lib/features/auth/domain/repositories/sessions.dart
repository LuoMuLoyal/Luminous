import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/auth/domain/entities/device_session.dart';
import 'package:luminous/shared/domain/failure.dart';

abstract interface class AuthSessionsRepository {
  TaskEither<LucentFailure, List<AuthDeviceSession>> listSessions();

  TaskEither<LucentFailure, void> revokeSession(String sessionId);
}
