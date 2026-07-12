import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session/account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';

import '../../../test_helpers.dart';

/// Extends [FakeAuthRemoteDataSource] with overrides for methods used by
/// [AuthAccountNotifier] that the base fake doesn't cover.
class _AccountFakeRemote extends FakeAuthRemoteDataSource {
  bool fetchAccountCalled = false;
  bool verifyEmailCalled = false;

  @override
  Future<AuthUser> fetchAccount() async {
    fetchAccountCalled = true;
    return AuthUser(
      id: 'user-1',
      email: 'user@example.com',
      nickname: 'Lumi',
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-07-11T00:00:00Z'),
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-07-11T00:00:00Z'),
    );
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    verifyEmailCalled = true;
  }
}

/// Fails account operations with a [DioException].
class _FailingAccountRemote extends _AccountFakeRemote {
  @override
  Future<AuthUser> fetchAccount() async {
    throw DioException(
      requestOptions: RequestOptions(path: '/account'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/account'),
        statusCode: 500,
        data: {'code': 500, 'message': '服务器错误', 'data': null},
      ),
    );
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/verify-email'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/verify-email'),
        statusCode: 400,
        data: {'code': 400001, 'message': '验证码错误', 'data': null},
      ),
    );
  }

  @override
  Future<AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/account'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/account'),
        statusCode: 400,
        data: {'code': 400002, 'message': '昵称已被使用', 'data': null},
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/change-password'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/change-password'),
        statusCode: 400,
        data: {'code': 400003, 'message': '原密码错误', 'data': null},
      ),
    );
  }

  @override
  Future<void> deleteAccount({String? password, String? code}) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/delete-account'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/delete-account'),
        statusCode: 400,
        data: {'code': 400004, 'message': '密码不正确', 'data': null},
      ),
    );
  }

  @override
  Future<AuthUser> unlinkIdentity({required String identityId}) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/unlink'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/unlink'),
        statusCode: 400,
        data: {'code': 400005, 'message': '无法解绑', 'data': null},
      ),
    );
  }

  @override
  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/change-email'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/change-email'),
        statusCode: 400,
        data: {'code': 400006, 'message': '邮箱已被占用', 'data': null},
      ),
    );
  }

  @override
  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/send-code'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/send-code'),
        statusCode: 429,
        data: {'code': 429001, 'message': '发送过于频繁', 'data': null},
      ),
    );
  }
}

class _NoOpAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

void main() {
  group('AuthAccountNotifier — sendVerificationCode', () {
    test('sets isSendingCode and cooldown on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.sendVerificationCode(
        email: 'user@example.com',
        scene: AuthVerificationScene.changeEmail,
      );

      expect(result, isTrue);
      final state = container.read(authAccountProvider);
      expect(state.isSendingCode, isFalse);
      expect(state.successMessage, 'sent');
      expect(state.lastCooldownSeconds, 60);
      expect(remote.sentCodeEmail, 'user@example.com');
      expect(remote.sentCodeScene, AuthVerificationScene.changeEmail);
    });

    test('sets errorMessage on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.sendVerificationCode(
        email: 'user@example.com',
        scene: AuthVerificationScene.deleteAccount,
      );

      expect(result, isFalse);
      final state = container.read(authAccountProvider);
      expect(state.isSendingCode, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — verifyEmail', () {
    test('returns true on success and refreshes user', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.verifyEmail(
        email: 'user@example.com',
        code: '123456',
      );

      expect(result, isTrue);
      expect(remote.verifyEmailCalled, isTrue);
      expect(remote.fetchAccountCalled, isTrue);
      final state = container.read(authAccountProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.successMessage, '');
    });

    test('returns false on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.verifyEmail(
        email: 'user@example.com',
        code: 'wrong',
      );

      expect(result, isFalse);
      final state = container.read(authAccountProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — updateProfile', () {
    test('returns true and applies user on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.updateProfile(nickname: 'NewName');

      expect(result, isTrue);
      expect(remote.updateProfileNickname, 'NewName');
      final session = container.read(authSessionProvider);
      expect(session.user?.nickname, 'NewName');
    });

    test('returns false on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.updateProfile(nickname: 'Taken');

      expect(result, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — changeEmail', () {
    test('returns true and applies user on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.changeEmail(
        newEmail: 'new@example.com',
        code: '123456',
      );

      expect(result, isTrue);
      expect(remote.changeEmailNewEmail, 'new@example.com');
      expect(remote.changeEmailCode, '123456');
      final session = container.read(authSessionProvider);
      expect(session.user?.email, 'new@example.com');
    });

    test('returns false when not signed in', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.changeEmail(
        newEmail: 'new@example.com',
        code: '123456',
      );

      expect(result, isFalse);
      expect(
        container.read(authAccountProvider).errorMessage,
        'Not signed in.',
      );
    });

    test('returns false on API failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.changeEmail(
        newEmail: 'taken@example.com',
        code: '123456',
      );

      expect(result, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — changePassword', () {
    test('returns true and clears session on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.changePassword(
        oldPassword: 'old123',
        newPassword: 'new456',
      );

      expect(result, isTrue);
      expect(remote.changePasswordOldPassword, 'old123');
      expect(remote.changePasswordNewPassword, 'new456');
      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isFalse);
    });

    test('returns false on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.changePassword(
        oldPassword: 'wrong',
        newPassword: 'new456',
      );

      expect(result, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — deleteAccount', () {
    test('returns true and clears session on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.deleteAccount(password: 'pass123');

      expect(result, isTrue);
      expect(remote.deleteAccountPassword, 'pass123');
      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isFalse);
    });

    test('returns false on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.deleteAccount(password: 'wrong');

      expect(result, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — unlinkIdentity', () {
    test('returns true and applies user on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.unlinkIdentity(identityId: 'id-1');

      expect(result, isTrue);
      expect(remote.unlinkIdentityId, 'id-1');
    });

    test('returns false on failure', () async {
      final remote = _FailingAccountRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(
            () => _SignedInAuthSessionNotifier(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authAccountProvider.notifier);

      final result = await notifier.unlinkIdentity(identityId: 'id-1');

      expect(result, isFalse);
      expect(container.read(authAccountProvider).errorMessage, isNotNull);
    });
  });

  group('AuthAccountNotifier — initial state', () {
    test('starts with default values', () {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRemoteDataSourceProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(authAccountProvider);

      expect(state.isSubmitting, isFalse);
      expect(state.isSendingCode, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
      expect(state.lastCooldownSeconds, isNull);
    });
  });
}
