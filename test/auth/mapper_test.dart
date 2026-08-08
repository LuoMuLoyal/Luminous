import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/auth/data/mappers/auth.dart';

/// Helper to build a LoginDataDto with minimal required fields.
LoginDataDto _loginData({
  String userId = 'u-1',
  String email = 'test@example.com',
  String? nickname,
  bool emailVerified = false,
  String? emailVerifiedAt,
  String accessToken = 'at-1',
  String refreshToken = 'rt-1',
  String createdAt = '2026-06-10T08:00:00.000Z',
  String updatedAt = '2026-06-10T08:00:00.000Z',
}) {
  return LoginDataDto(
    user: UserFullDto(
      id: userId,
      email: email,
      nickname: nickname ?? email.split('@').first,
      avatar: null,
      emailVerified: emailVerified,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ),
    tokens: TokensDto(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 3600,
    ),
  );
}

void main() {
  group('AuthMapper.toSessionFromLogin', () {
    test('maps all fields correctly', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginData(email: 'user@example.com', nickname: 'TestUser'),
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
        _loginData(
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
        _loginData(emailVerified: false, emailVerifiedAt: null),
      );

      expect(session.user.emailVerifiedAt, isNull);
    });

    test('handles null avatar', () {
      final session = AuthMapper.toSessionFromLogin(_loginData());

      expect(session.user.avatar, isNull);
    });

    test('maps malformed emailVerifiedAt to null instead of crashing', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginData(emailVerified: true, emailVerifiedAt: 'not-a-date'),
      );

      expect(session.user.emailVerifiedAt, isNull);
    });

    test('maps malformed createdAt to epoch instead of crashing', () {
      final session = AuthMapper.toSessionFromLogin(
        _loginData(createdAt: 'not-a-date', updatedAt: 'not-a-date'),
      );

      expect(session.user.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
      expect(session.user.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
