import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

abstract final class AuthMapper {
  static AuthSession toSessionFromLogin(LoginDataDto data) {
    return _toSession(user: data.user, tokens: data.tokens);
  }

  static AuthSession toSessionFromRegister(RegisterDataDto data) {
    final user = data.user;
    final tokens = data.tokens;
    return AuthSession(
      user: AuthUser(
        id: user.id,
        email: user.email?.toString(),
        nickname: user.nickname?.toString(),
        avatar: null,
        emailVerifiedAt: _parseOptionalDateTime(user.emailVerifiedAt),
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.createdAt),
      ),
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn.toInt(),
    );
  }

  static AuthSession _toSession({
    required UserFullDto user,
    required TokensDto tokens,
  }) {
    return AuthSession(
      user: AuthUser(
        id: user.id,
        email: user.email?.toString(),
        nickname: user.nickname?.toString(),
        avatar: user.avatar?.toString(),
        emailVerifiedAt: _parseOptionalDateTime(user.emailVerifiedAt),
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.updatedAt),
      ),
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn.toInt(),
    );
  }

  static DateTime? _parseOptionalDateTime(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.parse(raw);
  }
}
