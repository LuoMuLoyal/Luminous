import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

abstract final class AuthMapper {
  /// 登录响应 → [AuthSession]。
  ///
  /// tokens 形参沿用生成类型 [RegisterResponseTokens]:登录响应使用
  /// [LoginResponseTokens]、注册响应使用 [RegisterResponseTokens],两者字段一致
  /// (accessToken/refreshToken/expiresIn),此处仅做属性访问,无需中间类型
  /// (2026-09-03 审查 #7 澄清)。
  static AuthSession toSessionFromLogin(LoginResponse data) {
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

  static AuthSession toSessionFromRegister(RegisterResponse data) {
    final user = data.user;
    final tokens = data.tokens;
    // RegisterResponseUser 不携带 avatar/updatedAt:注册场景无头像来源,
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
