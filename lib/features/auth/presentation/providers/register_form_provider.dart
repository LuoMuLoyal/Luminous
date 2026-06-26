import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';

part 'register_form_provider.freezed.dart';

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
    String? errorMessage,
    String? successMessage,
  }) = _RegisterFormState;
}

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  Timer? _cooldownTimer;

  @override
  RegisterFormState build() {
    ref.onDispose(() {
      _cooldownTimer?.cancel();
    });
    return const RegisterFormState();
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, errorMessage: null);
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value, errorMessage: null);
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

  Future<bool> sendCode() async {
    state = state.copyWith(
      isSendingCode: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(
            email: state.email,
            scene: AuthVerificationScene.register,
          );
      final cooldown = result.cooldown.toInt();
      state = state.copyWith(
        isSendingCode: false,
        cooldownSeconds: cooldown,
        successMessage: result.message,
      );
      _startCooldownTimer(cooldown);
      return true;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isSendingCode: false,
        errorMessage: apiError.message,
        successMessage: null,
      );
      return false;
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

  Future<bool> submit() async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .register(
            email: state.email,
            password: state.password,
            code: state.code,
            nickname: state.nickname,
          );
      state = state.copyWith(isSubmitting: false, successMessage: '');
      return true;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: apiError.message,
      );
      return false;
    }
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
      RegisterFormNotifier.new,
    );
