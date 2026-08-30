import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';

import '../shared/form_mixin.dart';

part 'password_reset.freezed.dart';

@freezed
abstract class PasswordResetState with _$PasswordResetState {
  const factory PasswordResetState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    int? cooldownSeconds,
    String? emailError,
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
    required String passwordRequired,
    required String confirmPasswordRequired,
    required String passwordsDoNotMatch,
  }) {
    final emailError = EmailInput.validate(
      state.email,
      requiredMessage: emailRequired,
      invalidMessage: emailInvalid,
    );
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
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      errorMessage: null,
    );

    return emailError == null &&
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
    final result = await ref
        .read(authRepositoryProvider)
        .forgotPassword(email: state.email)
        .run();
    return switch (result) {
      Left(:final value) => _failSendResetCode(value),
      Right(:final value) => _succeedSendResetCode(value),
    };
  }

  bool _failSendResetCode(LucentFailure failure) {
    ref
        .read(talkerProvider)
        .error('PasswordResetNotifier.sendResetCode: failed: $failure');
    state = state.copyWith(
      isSubmitting: false,
      isSendingCode: false,
      errorMessage: failure.message,
      successMessage: null,
    );
    return false;
  }

  bool _succeedSendResetCode(VerificationCooldown value) {
    final cooldown = value.cooldownSeconds;
    state = state.copyWith(isSendingCode: false, successMessage: value.message);
    startCooldown(
      cooldown,
      getCooldownSeconds: () => state.cooldownSeconds,
      setCooldownSeconds: (v) => state = state.copyWith(cooldownSeconds: v),
    );
    return true;
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(token: token, password: password)
        .run();
    return switch (result) {
      Left(:final value) => _failResetPassword(value),
      Right() => _succeedResetPassword(),
    };
  }

  bool _failResetPassword(LucentFailure failure) {
    ref
        .read(talkerProvider)
        .error('PasswordResetNotifier.resetPassword: failed: $failure');
    state = state.copyWith(
      isSubmitting: false,
      isSendingCode: false,
      errorMessage: failure.message,
      successMessage: null,
    );
    return false;
  }

  bool _succeedResetPassword() {
    state = state.copyWith(isSubmitting: false, successMessage: '');
    return true;
  }
}

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
      PasswordResetNotifier.new,
    );
