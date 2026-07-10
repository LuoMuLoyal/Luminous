import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/auth/data/providers/data_providers.dart';

import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/features/auth/presentation/providers/shared/auth_action_runner.dart';

import '../shared/form_mixin.dart';

part 'password_reset_provider.freezed.dart';

@freezed
abstract class PasswordResetState with _$PasswordResetState {
  const factory PasswordResetState({
    @Default('') String email,
    @Default('') String code,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    int? cooldownSeconds,
    String? emailError,
    String? codeError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
    String? successMessage,
  }) = _PasswordResetState;
}

class PasswordResetNotifier extends Notifier<PasswordResetState>
    with CooldownTimerMixin<PasswordResetState> {
  @override
  PasswordResetState build() {
    ref.onDispose(disposeCooldown);
    return const PasswordResetState();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, emailError: null, errorMessage: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, codeError: null, errorMessage: null);
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

  Future<bool> sendResetCode() async {
    state = state.copyWith(
      isSendingCode: true,
      errorMessage: null,
      successMessage: null,
    );
    final (:value, :error) = await runAuthAction(
      ref: ref,
      tag: 'PasswordResetNotifier.sendResetCode',
      action: () => ref
          .read(authRemoteDataSourceProvider)
          .forgotPassword(email: state.email),
    );
    if (error != null) {
      state = state.copyWith(
        isSubmitting: false,
        isSendingCode: false,
        errorMessage: error,
        successMessage: null,
      );
      return false;
    }
    final cooldown = value!.cooldown.toInt();
    state = state.copyWith(isSendingCode: false, successMessage: value.message);
    startCooldown(
      cooldown,
      getCooldownSeconds: () => state.cooldownSeconds,
      setCooldownSeconds: (value) =>
          state = state.copyWith(cooldownSeconds: value),
    );
    return true;
  }

  Future<bool> resetPassword() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    final actionResult = await runAuthAction(
      ref: ref,
      tag: 'PasswordResetNotifier.resetPassword',
      action: () => ref
          .read(authRemoteDataSourceProvider)
          .resetPassword(
            email: state.email,
            code: state.code,
            password: state.password,
          ),
    );
    if (actionResult.error != null) {
      state = state.copyWith(
        isSubmitting: false,
        isSendingCode: false,
        errorMessage: actionResult.error,
        successMessage: null,
      );
      return false;
    }
    state = state.copyWith(isSubmitting: false, successMessage: '');
    return true;
  }
}

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
      PasswordResetNotifier.new,
    );
