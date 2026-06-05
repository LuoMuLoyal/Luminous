import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String? email,
    required String? nickname,
    required String? avatar,
    required bool emailVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, Object?> json) =>
      _$AuthUserFromJson(json);
}

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, Object?> json) =>
      _$AuthSessionFromJson(json);
}
