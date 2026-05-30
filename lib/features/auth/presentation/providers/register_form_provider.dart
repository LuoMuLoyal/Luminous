import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

part 'register_form_provider.freezed.dart';

@freezed
abstract class RegisterFormState with _$RegisterFormState {
  const factory RegisterFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String nickname,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _RegisterFormState;
}

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value, errorMessage: null);
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .register(
            email: state.email,
            password: state.password,
            nickname: state.nickname,
          );
      await ref.read(authSessionProvider.notifier).applySession(session);
      state = state.copyWith(isSubmitting: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }
}

final registerFormProvider =
    NotifierProvider<RegisterFormNotifier, RegisterFormState>(
      RegisterFormNotifier.new,
    );
