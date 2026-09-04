import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

abstract final class AuthMapper {
  /// 登录响应 → [AuthSession]。
  ///
  /// tokens 形参沿用生成类型 [RegisterResponseDtoTokens]:generated 客户端对
  /// 登录与注册响应的 token 载荷建模为同一个类(`LoginResponseDto.tokens` 与
  /// `RegisterResponseDto.tokens` 均为该类型,无独立的 `LoginResponseDtoTokens`),
  /// 因此这里不需要再引入"共享 tokens"的中间类型(2026-09-03 审查 #7 澄清)。
  static AuthSession toSessionFromLogin(LoginResponseDto data) {
    final user = data.user;
    final tokens = data.tokens;
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

  static AuthSession toSessionFromRegister(RegisterResponseDto data) {
    final user = data.user;
    final tokens = data.tokens;
    // RegisterResponseDtoUser 不携带 avatar/updatedAt:注册场景无头像来源,
    // updatedAt 沿用 createdAt 作为占位。
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
}
