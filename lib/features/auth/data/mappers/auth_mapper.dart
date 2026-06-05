import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';

abstract final class AuthMapper {
  static AuthSession toSessionFromLogin(LoginResponseDto response) {
    return _toSession(user: response.data.user, tokens: response.data.tokens);
  }

  static AuthSession toSessionFromRegister(RegisterResponseDto response) {
    final user = response.data.user;
    final tokens = response.data.tokens;
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
