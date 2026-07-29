import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/presentation/providers/forms/password_reset.dart';

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

  group('PasswordResetNotifier — field updates', () {
    test('updateEmail sets email and clears errors', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('reset@example.com');
      final state = container.read(passwordResetProvider);
      expect(state.email, 'reset@example.com');
      expect(state.emailError, isNull);
      expect(state.errorMessage, isNull);
    });

    test('updateCode sets code and clears errors', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateCode('888888');
      expect(container.read(passwordResetProvider).code, '888888');
      expect(container.read(passwordResetProvider).codeError, isNull);
    });

    test('updatePassword sets password and clears errors', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updatePassword('NewPass1');
      expect(container.read(passwordResetProvider).password, 'NewPass1');
      expect(container.read(passwordResetProvider).passwordError, isNull);
    });

    test('updateConfirmPassword sets confirmPassword and clears errors', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateConfirmPassword('NewPass1');
      expect(container.read(passwordResetProvider).confirmPassword, 'NewPass1');
      expect(
        container.read(passwordResetProvider).confirmPasswordError,
        isNull,
      );
    });

    test('setEmailError sets the email error message', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.setEmailError('邮箱不存在');
      expect(container.read(passwordResetProvider).emailError, '邮箱不存在');
    });
  });

  group('PasswordResetNotifier — validate', () {
    test('returns false for all empty fields', () {
      final notifier = container.read(passwordResetProvider.notifier);
      final valid = notifier.validate(
        emailRequired: '请输入邮箱',
        emailInvalid: '邮箱格式不正确',
        codeRequired: '请输入验证码',
        passwordRequired: '请输入密码',
        confirmPasswordRequired: '请确认密码',
        passwordsDoNotMatch: '两次密码不一致',
      );
      expect(valid, isFalse);
      final state = container.read(passwordResetProvider);
      expect(state.emailError, '请输入邮箱');
      expect(state.codeError, '请输入验证码');
      expect(state.passwordError, '请输入密码');
      expect(state.confirmPasswordError, '请确认密码');
    });

    test('returns false for invalid email', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('not-email');
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
      expect(container.read(passwordResetProvider).emailError, '邮箱格式不正确');
    });

    test('returns false for mismatched passwords', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('123456');
      notifier.updatePassword('passA');
      notifier.updateConfirmPassword('passB');
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
        container.read(passwordResetProvider).confirmPasswordError,
        '两次密码不一致',
      );
    });

    test('returns true for all valid fields', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('user@example.com');
      notifier.updateCode('123456');
      notifier.updatePassword('NewPass1');
      notifier.updateConfirmPassword('NewPass1');
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

  group('PasswordResetNotifier — validateEmailOnly', () {
    test('returns false for empty email', () {
      final notifier = container.read(passwordResetProvider.notifier);
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isFalse);
      expect(container.read(passwordResetProvider).emailError, '请输入邮箱');
    });

    test('returns true for non-empty email', () {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('anything');
      final valid = notifier.validateEmailOnly(emailRequired: '请输入邮箱');
      expect(valid, isTrue);
    });
  });

  group('PasswordResetNotifier — sendResetCode', () {
    test(
      'returns true and sets cooldown + successMessage on success',
      () async {
        final notifier = container.read(passwordResetProvider.notifier);
        notifier.updateEmail('reset@example.com');

        final result = await notifier.sendResetCode();

        expect(result, isTrue);
        expect(remote.forgotPasswordEmail, 'reset@example.com');
        final state = container.read(passwordResetProvider);
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

      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('reset@example.com');

      final result = await notifier.sendResetCode();

      expect(result, isFalse);
      expect(container.read(passwordResetProvider).isSendingCode, isFalse);
      expect(container.read(passwordResetProvider).errorMessage, isNotNull);
    });
  });

  group('PasswordResetNotifier — resetPassword', () {
    test('returns true and clears isSubmitting on success', () async {
      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('reset@example.com');
      notifier.updateCode('123456');
      notifier.updatePassword('NewPass1');

      final result = await notifier.resetPassword();

      expect(result, isTrue);
      expect(remote.resetPasswordEmail, 'reset@example.com');
      expect(remote.resetPasswordCode, '123456');
      expect(remote.resetPasswordValue, 'NewPass1');
      final state = container.read(passwordResetProvider);
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

      final notifier = container.read(passwordResetProvider.notifier);
      notifier.updateEmail('reset@example.com');
      notifier.updateCode('wrong');
      notifier.updatePassword('NewPass1');

      final result = await notifier.resetPassword();

      expect(result, isFalse);
      expect(container.read(passwordResetProvider).isSubmitting, isFalse);
      expect(container.read(passwordResetProvider).errorMessage, isNotNull);
    });
  });
}

class _NoOpAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

class _FailingLucentAuthRepository extends FakeLucentAuthRepository {
  @override
  Future<VerificationCooldown> forgotPassword({required String email}) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/forgot-password'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/forgot-password'),
        statusCode: 429,
        data: {'code': 429001, 'message': '发送过于频繁', 'data': null},
      ),
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/reset-password'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/reset-password'),
        statusCode: 400,
        data: {'code': 400002, 'message': '验证码错误', 'data': null},
      ),
    );
  }
}
