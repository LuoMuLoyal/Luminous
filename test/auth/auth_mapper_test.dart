import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/auth/data/mappers/auth_mapper.dart';

/// Helper to build a LoginResponseDto with minimal required fields.
LoginResponseDto _loginResponse({
  String userId = 'u-1',
  String email = 'test@example.com',
  String? nickname,
  bool emailVerified = false,
  String? emailVerifiedAt,
  String accessToken = 'at-1',
  String refreshToken = 'rt-1',
}) {
  return LoginResponseDto(
    code: 0,
    message: '',
    data: LoginDataDto(
      user: UserFullDto(
        id: userId,
        email: email,
        nickname: nickname ?? email.split('@').first,
        avatar: null,
        emailVerified: emailVerified,
        emailVerifiedAt: emailVerifiedAt,
        createdAt: '2026-06-10T08:00:00.000Z',
        updatedAt: '2026-06-10T08:00:00.000Z',
      ),
      tokens: TokensDto(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: 3600,
      ),
    ),
  );
}

void main() {
  group('AuthMapper.toSessionFromLogin', () {
    test('maps all fields correctly', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginResponse(email: 'user@example.com', nickname: 'TestUser'),
      );

      expect(session.user.id, 'u-1');
      expect(session.user.email, 'user@example.com');
      expect(session.user.nickname, 'TestUser');
      expect(session.accessToken, 'at-1');
      expect(session.refreshToken, 'rt-1');
      expect(session.expiresInSeconds, 3600);
    });

    test('maps emailVerifiedAt when present', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginResponse(
          emailVerified: true,
          emailVerifiedAt: '2026-06-10T08:00:00.000Z',
        ),
      );

      expect(session.user.emailVerifiedAt, isNotNull);
      expect(
        session.user.emailVerifiedAt!.toIso8601String(),
        startsWith('2026-06-10'),
      );
    });

    test('handles null emailVerifiedAt', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginResponse(emailVerified: false, emailVerifiedAt: null),
      );

      expect(session.user.emailVerifiedAt, isNull);
    });

    test('handles null avatar', () {
      final session = AuthMapper.toSessionFromLogin(_loginResponse());

      expect(session.user.avatar, isNull);
    });
  });
}
