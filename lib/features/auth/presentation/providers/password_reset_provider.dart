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
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  bool validatePasswordMatch({required String message}) {
    if (state.password == state.confirmPassword) {
      return true;
    }
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: message,
      successMessage: null,
    );
    return false;
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
