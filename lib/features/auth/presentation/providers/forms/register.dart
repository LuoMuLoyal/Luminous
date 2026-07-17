import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';

import 'package:luminous/core/forms/validators.dart';

import '../shared/form_mixin.dart';

part 'register.freezed.dart';

@freezed
abstract class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String code,
    @Default('') String nickname,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    int? cooldownSeconds,
    String? emailError,
    String? codeError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    String? successMessage,
  }) = _RegisterFormState;
}

class RegisterFormNotifier extends Notifier<RegisterFormState>
    with CooldownTimerMixin<RegisterFormState> {
  @override
  RegisterFormState build() {
    ref.onDispose(disposeCooldown);
    return const RegisterFormState();
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

  void updateConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordError: null,
      errorMessage: null,
    );
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, codeError: null, errorMessage: null);
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value, errorMessage: null);
  }

  void setEmailError(String message) {
    state = state.copyWith(emailError: message);
  }

  bool validate({
    required String emailRequired,
    required String emailInvalid,
    required String codeRequired,
    required String passwordRequired,
    required String confirmPasswordRequired,
    required String passwordsDoNotMatch,
  }) {
    final emailError = EmailInput.validate(
      state.email,
      requiredMessage: emailRequired,
      invalidMessage: emailInvalid,
    );
    final codeError = CodeInput.validate(state.code, codeRequired);
    final passwordError = PasswordInput.validate(
      state.password,
      passwordRequired,
    );
    final confirmPasswordError = ConfirmPasswordInput.validate(
      state.confirmPassword,
      state.password,
      requiredMessage: confirmPasswordRequired,
      mismatchMessage: passwordsDoNotMatch,
    );

    state = state.copyWith(
      emailError: emailError,
      codeError: codeError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      errorMessage: null,
    );

    return emailError == null &&
        codeError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  bool validateEmailOnly({required String emailRequired}) {
    final emailError = state.email.trim().isEmpty ? emailRequired : null;
    state = state.copyWith(emailError: emailError, errorMessage: null);
    return emailError == null;
  }

  Future<bool> sendCode() async {
    state = state.copyWith(
      isSendingCode: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await runGuarded(
      ref: ref,
      tag: 'RegisterFormNotifier.sendCode',
      action: () => ref
          .read(authRepositoryProvider)
          .sendVerificationCode(
            email: state.email,
            scene: AuthVerificationScene.register,
          ),
    );
    switch (result) {
      case Failure(:final error):
        state = state.copyWith(
          isSendingCode: false,
          errorMessage: error.message,
          successMessage: null,
        );
        return false;
      case Success(:final value):
        final cooldown = value.cooldownSeconds;
        state = state.copyWith(
          isSendingCode: false,
          successMessage: value.message,
        );
        startCooldown(
          cooldown,
          getCooldownSeconds: () => state.cooldownSeconds,
          setCooldownSeconds: (v) => state = state.copyWith(cooldownSeconds: v),
        );
        return true;
    }
  }

  Future<bool> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await runGuarded(
      ref: ref,
      tag: 'RegisterFormNotifier.submit',
      action: () => ref
          .read(authRepositoryProvider)
          .register(
            email: state.email,
            password: state.password,
            code: state.code,
            nickname: state.nickname,
          ),
    );
    switch (result) {
      case Failure(:final error):
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        return false;
      case Success():
        state = state.copyWith(isSubmitting: false, successMessage: '');
        return true;
    }
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
      RegisterFormNotifier.new,
    );
