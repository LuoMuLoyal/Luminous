import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/auth/data/datasources/remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/data_providers.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/features/auth/presentation/providers/shared/auth_action_runner.dart';
import 'package:luminous/features/auth/presentation/providers/shared/form_mixin.dart';

part 'login_form_provider.freezed.dart';

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
    String? errorMessage,
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
    state = state.copyWith(email: value, emailError: null, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: value,
      passwordError: null,
      errorMessage: null,
    );
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, codeError: null, errorMessage: null);
  }

  void updateMode(AuthLoginMode mode) {
    state = state.copyWith(mode: mode, errorMessage: null);
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
      errorMessage: null,
    );

    return emailError == null && passwordError == null && codeError == null;
  }

  bool validateEmailOnly({required String emailRequired}) {
    final email = state.email.trim();
    final emailError = email.isEmpty ? emailRequired : null;
    state = state.copyWith(emailError: emailError, errorMessage: null);
    return emailError == null;
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final (:value, :error) = await runAuthAction(
      ref: ref,
      tag: 'LoginFormNotifier.submit',
      action: () async {
        final session = await ref
            .read(authRemoteDataSourceProvider)
            .login(
              email: state.email,
              password: state.mode == AuthLoginMode.password
                  ? state.password
                  : null,
              code: state.mode == AuthLoginMode.code ? state.code : null,
            );
        await ref.read(authSessionProvider.notifier).applySession(session);
        return session;
      },
    );
    if (error != null) {
      state = state.copyWith(isSubmitting: false, errorMessage: error);
      return null;
    }
    state = state.copyWith(isSubmitting: false);
    return value;
  }

  Future<bool> sendCode() async {
    state = state.copyWith(isSendingCode: true, errorMessage: null);
    final (:value, :error) = await runAuthAction(
      ref: ref,
      tag: 'LoginFormNotifier.sendCode',
      action: () => ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(
            email: state.email,
            scene: AuthVerificationScene.login,
          ),
    );
    if (error != null) {
      state = state.copyWith(isSendingCode: false, errorMessage: error);
      return false;
    }
    final cooldown = value!.cooldown.toInt();
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
