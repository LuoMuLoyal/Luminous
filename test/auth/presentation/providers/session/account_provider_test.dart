import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/presentation/providers/account.dart';

import '../../../test_helpers.dart';

/// Extends [FakeLucentAuthRepository] with overrides for methods used by
/// [AuthAccountNotifier] that the base fake doesn't cover.
class _AccountFakeRemote extends FakeLucentAuthRepository {
  bool fetchAccountCalled = false;
  bool verifyEmailCalled = false;

  @override
  TaskEither<LucentFailure, AuthUser> fetchAccount() {
    fetchAccountCalled = true;
    return TaskEither.right(
      AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-07-11T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-07-11T00:00:00Z'),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, void> verifyEmail({
    required String email,
    required String code,
  }) {
    verifyEmailCalled = true;
    return TaskEither.right(null);
  }
}

/// Fails account operations with a [DioException].
class _FailingAccountRemote extends _AccountFakeRemote {
  @override
  TaskEither<LucentFailure, AuthUser> fetchAccount() {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/account'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/account',
          statusCode: 500,
          code: 'INTERNAL_SERVER_ERROR',
          detail: '服务器错误',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> verifyEmail({
    required String email,
    required String code,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/verify-email'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/verify-email',
          statusCode: 400,
          code: 'AUTH_VERIFICATION_CODE_INVALID',
          detail: '验证码错误',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> updateAccountProfile({
    String? nickname,
    String? avatar,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/account'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/account',
          statusCode: 400,
          code: 'ACCOUNT_NICKNAME_CONFLICT',
          detail: '昵称已被使用',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/change-password'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/change-password',
          statusCode: 400,
          code: 'AUTH_CURRENT_PASSWORD_INVALID',
          detail: '原密码错误',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, void> deleteAccount({
    String? password,
    String? code,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/delete-account'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/delete-account',
          statusCode: 400,
          code: 'AUTH_PASSWORD_INVALID',
          detail: '密码不正确',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> unlinkIdentity({
    required String identityId,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/unlink'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/unlink',
          statusCode: 400,
          code: 'AUTH_IDENTITY_UNLINK_FAILED',
          detail: '无法解绑',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/change-email'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/change-email',
          statusCode: 400,
          code: 'AUTH_EMAIL_CONFLICT',
          detail: '邮箱已被占用',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, VerificationCooldown> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/send-code'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/send-code',
          statusCode: 429,
          code: 'AUTH_LOGIN_RATE_LIMITED',
          detail: '发送过于频繁',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}

class _ElevationTokenInvalidRemote extends _AccountFakeRemote {
  @override
  TaskEither<LucentFailure, AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/change-email'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/change-email',
          statusCode: 403,
          code: 'AUTH_ELEVATION_TOKEN_INVALID',
          detail: 'elevation_token_invalid',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }
}

class _ForbiddenBusinessRemote extends _AccountFakeRemote {
  @override
  TaskEither<LucentFailure, AuthUser> unlinkIdentity({
    required String identityId,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/unlink'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/unlink',
          statusCode: 403,
          code: 'AUTH_LAST_IDENTITY_CANNOT_UNLINK',
          detail: 'Cannot unlink the last sign-in identity',
        ),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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

    test(
      'does not classify an ordinary forbidden business error as PIN failure',
      () async {
        final remote = _ForbiddenBusinessRemote();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(remote),
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container
            .read(authAccountProvider.notifier)
            .unlinkIdentity(identityId: 'id-1');

        expect(result, isFalse);
        expect(
          container.read(authAccountProvider).requiresSecurityElevation,
          isFalse,
        );
      },
    );
  });

  group('AuthAccountNotifier — changeEmail', () {
    test('returns true and applies user on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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

    test(
      'marks an invalid elevation token failure for the page to guide PIN verification',
      () async {
        final remote = _ElevationTokenInvalidRemote();
        final holder = SecurityElevationTokenHolder();
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(remote),
            authSessionProvider.overrideWith(
              () => _SignedInAuthSessionNotifier(),
            ),
            securityElevationTokenHolderProvider.overrideWithValue(holder),
            securityElevationControllerProvider.overrideWith(
              _VerifiedSecurityElevationController.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        final expiresAt = DateTime.now().add(const Duration(minutes: 5));
        container.read(securityElevationControllerProvider);
        holder.set('test-elevation-token', expiresAt);

        final result = await container
            .read(authAccountProvider.notifier)
            .changeEmail(newEmail: 'expired@example.com', code: '123456');

        expect(result, isFalse);
        expect(
          container.read(authAccountProvider).requiresSecurityElevation,
          isTrue,
        );
        expect(
          container.read(securityElevationControllerProvider),
          isA<SecurityElevationUnverified>(),
        );
        expect(holder.token, isNull);
      },
    );
  });

  group('AuthAccountNotifier — changePassword', () {
    test('returns true and clears session on success', () async {
      final remote = _AccountFakeRemote();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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
          authRepositoryProvider.overrideWithValue(remote),
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

class _VerifiedSecurityElevationController extends SecurityElevationController {
  @override
  SecurityElevationState build() {
    return SecurityElevationVerified(
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}
