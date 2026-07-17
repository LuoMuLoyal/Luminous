import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/forms/login.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';

import '../../test_helpers.dart';

void main() {
  late FakeLucentAuthRepository remote;
  late ProviderContainer container;

  setUp(() {
    remote = FakeLucentAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
      ],
    );
    addTearDown(container.dispose);
  });

  group('LoginFormNotifier — field updates', () {
    test('updateEmail sets email and clears errors', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('test@example.com');
      final state = container.read(loginFormProvider);
      expect(state.email, 'test@example.com');
      expect(state.emailError, isNull);
      expect(state.errorMessage, isNull);
    });

    test('updatePassword sets password and clears errors', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updatePassword('secret123');
      final state = container.read(loginFormProvider);
      expect(state.password, 'secret123');
      expect(state.passwordError, isNull);
    });

    test('updateCode sets code and clears errors', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateCode('123456');
      final state = container.read(loginFormProvider);
      expect(state.code, '123456');
      expect(state.codeError, isNull);
    });

    test('updateMode switches mode and clears errorMessage', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateMode(AuthLoginMode.code);
      expect(container.read(loginFormProvider).mode, AuthLoginMode.code);

      notifier.updateMode(AuthLoginMode.password);
      expect(container.read(loginFormProvider).mode, AuthLoginMode.password);
    });

    test('setEmailError sets the email error message', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.setEmailError('邮箱已被注册');
      expect(container.read(loginFormProvider).emailError, '邮箱已被注册');
    });
  });

  group('LoginFormNotifier — validate (password mode)', () {
    test('returns false and sets errors for empty fields', () {
      final notifier = container.read(loginFormProvider.notifier);
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        passwordRequired: '请输入密码',
        codeRequired: '请输入验证码',
      );
      expect(valid, isFalse);
      final state = container.read(loginFormProvider);
      expect(state.emailError, '请输入邮箱');
      expect(state.passwordError, '请输入密码');
    });

    test('returns false for invalid email format', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('not-an-email');
      notifier.updatePassword('pass123');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        passwordRequired: '请输入密码',
        codeRequired: '请输入验证码',
      );
      expect(valid, isFalse);
      expect(container.read(loginFormProvider).emailError, '邮箱格式不正确');
      expect(container.read(loginFormProvider).passwordError, isNull);
    });

    test('returns true for valid email + password', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updatePassword('pass123');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        passwordRequired: '请输入密码',
        codeRequired: '请输入验证码',
      );
      expect(valid, isTrue);
      final state = container.read(loginFormProvider);
      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
    });
  });

  group('LoginFormNotifier — validate (code mode)', () {
    test('returns false for empty code', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateMode(AuthLoginMode.code);
      notifier.updateEmail('user@example.com');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        passwordRequired: '请输入密码',
        codeRequired: '请输入验证码',
      );
      expect(valid, isFalse);
      expect(container.read(loginFormProvider).codeError, '请输入验证码');
      expect(container.read(loginFormProvider).passwordError, isNull);
    });

    test('returns true for valid email + code', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateMode(AuthLoginMode.code);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('123456');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        passwordRequired: '请输入密码',
        codeRequired: '请输入验证码',
      );
      expect(valid, isTrue);
    });
  });

  group('LoginFormNotifier — validateEmailOnly', () {
    test('returns false for empty email', () {
      final notifier = container.read(loginFormProvider.notifier);
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isFalse);
      expect(container.read(loginFormProvider).emailError, '请输入邮箱');
    });

    test('returns true for non-empty email (no format check)', () {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('anything');
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isTrue);
      expect(container.read(loginFormProvider).emailError, isNull);
    });
  });

  group('LoginFormNotifier — submit', () {
    test('returns session and clears isSubmitting on success', () async {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updatePassword('pass123');

      final session = await notifier.submit();

      expect(session, isNotNull);
      expect(remote.loginEmail, 'user@example.com');
      expect(remote.loginPassword, 'pass123');
      expect(remote.loginCode, isNull);
      expect(container.read(loginFormProvider).isSubmitting, isFalse);
      expect(container.read(loginFormProvider).errorMessage, isNull);
    });

    test('returns null and sets errorMessage on failure', () async {
      container.dispose();
      remote = _FailingLucentAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updatePassword('wrong');

      final session = await notifier.submit();

      expect(session, isNull);
      expect(container.read(loginFormProvider).isSubmitting, isFalse);
      expect(container.read(loginFormProvider).errorMessage, isNotNull);
    });

    test('sends code (not password) in code mode', () async {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateMode(AuthLoginMode.code);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('999999');

      await notifier.submit();

      expect(remote.loginPassword, isNull);
      expect(remote.loginCode, '999999');
    });
  });

  group('LoginFormNotifier — sendCode', () {
    test('returns true and sets cooldown on success', () async {
      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('user@example.com');

      final result = await notifier.sendCode();

      expect(result, isTrue);
      expect(remote.sentCodeEmail, 'user@example.com');
      expect(remote.sentCodeScene, AuthVerificationScene.login);
      final state = container.read(loginFormProvider);
      expect(state.isSendingCode, isFalse);
      expect(state.cooldownSeconds, 60);
    });

    test('returns false and sets errorMessage on failure', () async {
      remote = _FailingLucentAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginFormProvider.notifier);
      notifier.updateEmail('user@example.com');

      final result = await notifier.sendCode();

      expect(result, isFalse);
      expect(container.read(loginFormProvider).isSendingCode, isFalse);
      expect(container.read(loginFormProvider).errorMessage, isNotNull);
    });
  });
}

/// A no-op [AuthSessionNotifier] that skips the real build() which wires
/// up the Dio client — not needed for form provider tests.
class _NoOpAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

/// Fails all network operations with a [DioException].
class _FailingLucentAuthRepository extends FakeLucentAuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/login'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/login'),
        statusCode: 401,
        data: {'code': 401005, 'message': '密码错误', 'data': null},
      ),
    );
  }

  @override
  Future<VerificationCooldown> sendVerificationCode({
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
