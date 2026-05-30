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
    @Default(false) bool isSubmitting,
    int? cooldownSeconds,
    String? errorMessage,
    String? successMessage,
  }) = _PasswordResetState;
}

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  Future<bool> sendResetCode() async {
    state = state.copyWith(
      isSubmitting: true,
      cooldownSeconds: null,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .forgotPassword(email: state.email);
      state = state.copyWith(
        isSubmitting: false,
        cooldownSeconds: result.cooldown.toInt(),
        successMessage: result.message,
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
