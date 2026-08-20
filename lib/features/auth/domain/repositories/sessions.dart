import 'package:luminous/features/auth/domain/entities/device_session.dart';

abstract interface class AuthSessionsRepository {
  Future<List<AuthDeviceSession>> listSessions();

  Future<void> revokeSession(String sessionId);
}
