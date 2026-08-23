import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/presentation/providers/forms/register.dart';

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

  group('RegisterFormNotifier — field updates', () {
    test('updateEmail sets email and clears errors', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('reg@example.com');
      final state = container.read(registerFormProvider);
      expect(state.email, 'reg@example.com');
      expect(state.emailError, isNull);
      expect(state.errorMessage, isNull);
    });

    test('updatePassword sets password and clears errors', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updatePassword('Pass1234');
      expect(container.read(registerFormProvider).password, 'Pass1234');
      expect(container.read(registerFormProvider).passwordError, isNull);
    });

    test('updateConfirmPassword sets confirmPassword and clears errors', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateConfirmPassword('Pass1234');
      expect(container.read(registerFormProvider).confirmPassword, 'Pass1234');
      expect(container.read(registerFormProvider).confirmPasswordError, isNull);
    });

    test('updateCode sets code and clears errors', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateCode('654321');
      expect(container.read(registerFormProvider).code, '654321');
    });

    test('updateNickname sets nickname and clears errorMessage', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateNickname('Tester');
      expect(container.read(registerFormProvider).nickname, 'Tester');
    });

    test('setEmailError sets the email error message', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.setEmailError('邮箱已存在');
      expect(container.read(registerFormProvider).emailError, '邮箱已存在');
    });
  });

  group('RegisterFormNotifier — validate', () {
    test('returns false for all empty fields', () {
      final notifier = container.read(registerFormProvider.notifier);
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        codeRequired: '请输入验证码',
        passwordRequired: '请输入密码',
        confirmPasswordRequired: '请确认密码',
        passwordsDoNotMatch: '两次密码不一致',
      );
      expect(valid, isFalse);
      final state = container.read(registerFormProvider);
      expect(state.emailError, '请输入邮箱');
      expect(state.codeError, '请输入验证码');
      expect(state.passwordError, '请输入密码');
      expect(state.confirmPasswordError, '请确认密码');
    });

    test('returns false for invalid email', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('bad-email');
      notifier.updateCode('123456');
      notifier.updatePassword('pass');
      notifier.updateConfirmPassword('pass');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        codeRequired: '请输入验证码',
        passwordRequired: '请输入密码',
        confirmPasswordRequired: '请确认密码',
        passwordsDoNotMatch: '两次密码不一致',
      );
      expect(valid, isFalse);
      expect(container.read(registerFormProvider).emailError, '邮箱格式不正确');
    });

    test('returns false for mismatched passwords', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('123456');
      notifier.updatePassword('pass123');
      notifier.updateConfirmPassword('pass456');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        codeRequired: '请输入验证码',
        passwordRequired: '请输入密码',
        confirmPasswordRequired: '请确认密码',
        passwordsDoNotMatch: '两次密码不一致',
      );
      expect(valid, isFalse);
      expect(
        container.read(registerFormProvider).confirmPasswordError,
        '两次密码不一致',
      );
    });

    test('returns true for all valid fields', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('123456');
      notifier.updatePassword('pass123');
      notifier.updateConfirmPassword('pass123');
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        codeRequired: '请输入验证码',
        passwordRequired: '请输入密码',
        confirmPasswordRequired: '请确认密码',
        passwordsDoNotMatch: '两次密码不一致',
      );
      expect(valid, isTrue);
    });
  });

  group('RegisterFormNotifier — validateEmailOnly', () {
    test('returns false for empty email', () {
      final notifier = container.read(registerFormProvider.notifier);
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isFalse);
      expect(container.read(registerFormProvider).emailError, '请输入邮箱');
    });

    test('returns true for non-empty email', () {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('anything');
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isTrue);
    });
  });

  group('RegisterFormNotifier — sendCode', () {
    test(
      'returns true and sets cooldown + successMessage on success',
      () async {
        final notifier = container.read(registerFormProvider.notifier);
        notifier.updateEmail('reg@example.com');

        final result = await notifier.sendCode();

        expect(result, isTrue);
        expect(remote.sentCodeEmail, 'reg@example.com');
        expect(remote.sentCodeScene, AuthVerificationScene.register);
        final state = container.read(registerFormProvider);
        expect(state.isSendingCode, isFalse);
        expect(state.cooldownSeconds, 60);
        expect(state.successMessage, 'sent');
      },
    );

    test('returns false and sets errorMessage on failure', () async {
      container.dispose();
      remote = _FailingLucentAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('reg@example.com');

      final result = await notifier.sendCode();

      expect(result, isFalse);
      expect(container.read(registerFormProvider).isSendingCode, isFalse);
      expect(container.read(registerFormProvider).errorMessage, isNotNull);
    });
  });

  group('RegisterFormNotifier — submit', () {
    test('returns true and clears isSubmitting on success', () async {
      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('reg@example.com');
      notifier.updatePassword('Pass1234');
      notifier.updateCode('123456');
      notifier.updateNickname('NewUser');

      final result = await notifier.submit();

      expect(result, isTrue);
      expect(remote.registerEmail, 'reg@example.com');
      expect(remote.registerPassword, 'Pass1234');
      expect(remote.registerCode, '123456');
      expect(remote.registerNickname, 'NewUser');
      final state = container.read(registerFormProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.successMessage, isNotNull);
    });

    test('returns false and sets errorMessage on failure', () async {
      container.dispose();
      remote = _FailingLucentAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(remote),
          authSessionProvider.overrideWith(() => _NoOpAuthSessionNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(registerFormProvider.notifier);
      notifier.updateEmail('reg@example.com');
      notifier.updatePassword('Pass1234');
      notifier.updateCode('123456');

      final result = await notifier.submit();

      expect(result, isFalse);
      expect(container.read(registerFormProvider).isSubmitting, isFalse);
      expect(container.read(registerFormProvider).errorMessage, isNotNull);
    });
  });
}

class _NoOpAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

class _FailingLucentAuthRepository extends FakeLucentAuthRepository {
  @override
  TaskEither<LucentFailure, AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) {
    return TaskEither.tryCatch(() async {
      throw DioException(
        requestOptions: RequestOptions(path: '/register'),
        type: DioExceptionType.badResponse,
        response: problemResponse(
          path: '/register',
          statusCode: 409,
          code: 'AUTH_EMAIL_ALREADY_REGISTERED',
          detail: '邮箱已注册',
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
