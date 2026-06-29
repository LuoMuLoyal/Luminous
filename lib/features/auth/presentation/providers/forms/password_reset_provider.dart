import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';

import '../shared/auth_form_mixin.dart';

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
    with AuthValidationMixin, CooldownTimerMixin<PasswordResetState> {
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
    final emailError = validateEmail(
      state.email,
      emailRequired: emailRequired,
      emailInvalid: emailInvalid,
    );
    final codeError = validateCode(state.code, codeRequired: codeRequired);
    final passwordError = validatePassword(
      state.password,
      passwordRequired: passwordRequired,
    );
    final confirmPasswordError = validateConfirmPassword(
      state.password,
      state.confirmPassword,
      confirmPasswordRequired: confirmPasswordRequired,
      passwordsDoNotMatch: passwordsDoNotMatch,
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
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .forgotPassword(email: state.email);
      final cooldown = result.cooldown.toInt();
      state = state.copyWith(
        isSendingCode: false,
        successMessage: result.message,
      );
      startCooldown(
        cooldown,
        getCooldownSeconds: () => state.cooldownSeconds,
        setCooldownSeconds: (value) =>
            state = state.copyWith(cooldownSeconds: value),
      );
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<bool> resetPassword() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .resetPassword(
            email: state.email,
            code: state.code,
            password: state.password,
          );
      state = state.copyWith(isSubmitting: false, successMessage: '');
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  bool _fail(Object error) {
    final apiError = LucentErrorMapper.fromObject(error);
    state = state.copyWith(
      isSubmitting: false,
      isSendingCode: false,
      errorMessage: apiError.message,
      successMessage: null,
    );
    return false;
  }
}

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
      PasswordResetNotifier.new,
    );
