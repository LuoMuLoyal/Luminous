import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

abstract final class AuthMapper {
  static AuthSession toSessionFromLogin(LoginResponseDto data) {
    return _toSession(user: data.user, tokens: data.tokens);
  }

  static AuthSession toSessionFromRegister(RegisterResponseDto data) {
    final user = data.user;
    final tokens = data.tokens;
    // UserBriefDto 不携带 updatedAt,注册场景沿用 createdAt 作为占位。
    return AuthSession(
      user: AuthUser(
        id: user.id,
        email: user.email?.toString(),
        nickname: user.nickname?.toString(),
        avatar: null,
        emailVerifiedAt: parseDateTimeOrNull(user.emailVerifiedAt),
        createdAt: parseDateTimeOrEpoch(user.createdAt),
        updatedAt: parseDateTimeOrEpoch(user.createdAt),
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
        emailVerifiedAt: parseDateTimeOrNull(user.emailVerifiedAt),
        createdAt: parseDateTimeOrEpoch(user.createdAt),
        updatedAt: parseDateTimeOrEpoch(user.updatedAt),
      ),
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresInSeconds: tokens.expiresIn.toInt(),
    );
  }
}
