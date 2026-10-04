import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
import 'package:luminous/features/auth/presentation/providers/shared/form_mixin.dart';

part 'login.freezed.dart';

enum AuthLoginMode { password, code }

@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String code,
    @Default(AuthLoginMode.password) AuthLoginMode mode,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    int? cooldownSeconds,
    String? emailError,
    String? passwordError,
    String? codeError,

    /// The failure behind the last action, kept as the object so the render
    /// site resolves copy through `userMessageFromError(error, l10n: l10n)`.
    LucentFailure? error,
  }) = _LoginFormState;
}

class LoginFormNotifier extends Notifier<LoginFormState>
    with CooldownTimerMixin<LoginFormState> {
  @override
  LoginFormState build() {
    ref.onDispose(disposeCooldown);
    return const LoginFormState();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, emailError: null, error: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, passwordError: null, error: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, codeError: null, error: null);
  }

  void updateMode(AuthLoginMode mode) {
    state = state.copyWith(mode: mode, error: null);
  }

  void setEmailError(String message) {
    state = state.copyWith(emailError: message);
  }

  bool validate({
    required String emailRequired,
    required String emailInvalid,
    required String passwordRequired,
    required String codeRequired,
  }) {
    final emailError = EmailInput.validate(
      state.email,
      requiredMessage: emailRequired,
      invalidMessage: emailInvalid,
    );

    final String? passwordError;
    final String? codeError;
    if (state.mode == AuthLoginMode.password) {
      passwordError = PasswordInput.validate(state.password, passwordRequired);
      codeError = null;
    } else {
      passwordError = null;
      codeError = CodeInput.validate(state.code, codeRequired);
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      codeError: codeError,
      error: null,
    );

    return emailError == null && passwordError == null && codeError == null;
  }

  bool validateEmailOnly({required String emailRequired}) {
    final email = state.email.trim();
    final emailError = email.isEmpty ? emailRequired : null;
    state = state.copyWith(emailError: emailError, error: null);
    return emailError == null;
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await ref
        .read(authRepositoryProvider)
        .login(
          email: state.email,
          password: state.mode == AuthLoginMode.password
              ? state.password
              : null,
          code: state.mode == AuthLoginMode.code ? state.code : null,
        )
        .run();
    return switch (result) {
      Left(:final value) => _failSubmit(value),
      Right(:final value) => _succeedSubmit(value),
    };
  }

  Future<AuthSession?> _failSubmit(LucentFailure failure) async {
    ref
        .read(talkerProvider)
        .error('LoginFormNotifier.submit: failed: $failure');
    state = state.copyWith(isSubmitting: false, error: failure);
    return null;
  }

  Future<AuthSession?> _succeedSubmit(AuthSession session) async {
    await ref.read(authSessionProvider.notifier).applySession(session);
    state = state.copyWith(isSubmitting: false);
    return session;
  }

  Future<bool> sendCode() async {
    state = state.copyWith(isSendingCode: true, error: null);
    final result = await ref
        .read(authRepositoryProvider)
        .sendVerificationCode(
          email: state.email,
          scene: AuthVerificationScene.login,
        )
        .run();
    return switch (result) {
      Left(:final value) => _failSendCode(value),
      Right(:final value) => _succeedSendCode(value),
    };
  }

  bool _failSendCode(LucentFailure failure) {
    ref
        .read(talkerProvider)
        .error('LoginFormNotifier.sendCode: failed: $failure');
    state = state.copyWith(isSendingCode: false, error: failure);
    return false;
  }

  bool _succeedSendCode(VerificationCooldown value) {
    final cooldown = value.cooldownSeconds;
    state = state.copyWith(isSendingCode: false, cooldownSeconds: cooldown);
    startCooldown(
      cooldown,
      getCooldownSeconds: () => state.cooldownSeconds,
      setCooldownSeconds: (v) => state = state.copyWith(cooldownSeconds: v),
    );
    return true;
  }
}

final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginFormState>(
  LoginFormNotifier.new,
);
