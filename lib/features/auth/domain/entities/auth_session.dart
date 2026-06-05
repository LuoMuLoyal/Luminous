import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    required String id,
    required String? email,
    required String? nickname,
    required String? avatar,
    required DateTime? emailVerifiedAt,
    @Default(false) bool hasPassword,
    DateTime? lastLoginAt,
    @Default(<AuthLinkedIdentity>[]) List<AuthLinkedIdentity> linkedIdentities,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AuthUser;

  bool get emailVerified => emailVerifiedAt != null;

  factory AuthUser.fromJson(Map<String, Object?> json) =>
      _$AuthUserFromJson(json);
}

@freezed
abstract class AuthLinkedIdentity with _$AuthLinkedIdentity {
  const factory AuthLinkedIdentity({
    required String id,
    required String provider,
    required String? email,
    required DateTime? emailVerifiedAt,
    required DateTime linkedAt,
  }) = _AuthLinkedIdentity;

  factory AuthLinkedIdentity.fromJson(Map<String, Object?> json) =>
      _$AuthLinkedIdentityFromJson(json);
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
