import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';

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

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  Timer? _cooldownTimer;

  @override
  PasswordResetState build() {
    ref.onDispose(() {
      _cooldownTimer?.cancel();
    });
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
    final email = state.email.trim();
    final emailError = email.isEmpty
        ? emailRequired
        : _isValidEmail(email)
        ? null
        : emailInvalid;
    final codeError = state.code.trim().isEmpty ? codeRequired : null;
    final passwordError = state.password.trim().isEmpty
        ? passwordRequired
        : null;
    final confirmPasswordError = state.confirmPassword.trim().isEmpty
        ? confirmPasswordRequired
        : state.confirmPassword != state.password
        ? passwordsDoNotMatch
        : null;

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
    final email = state.email.trim();
    final emailError = email.isEmpty ? emailRequired : null;
    state = state.copyWith(emailError: emailError, errorMessage: null);
    return emailError == null;
  }

  static bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
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
        cooldownSeconds: cooldown,
        successMessage: result.message,
      );
      _startCooldownTimer(cooldown);
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  void _startCooldownTimer(int seconds) {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.cooldownSeconds;
      if (current == null || current <= 1) {
        timer.cancel();
        _cooldownTimer = null;
        state = state.copyWith(cooldownSeconds: null);
      } else {
        state = state.copyWith(cooldownSeconds: current - 1);
      }
    });
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
