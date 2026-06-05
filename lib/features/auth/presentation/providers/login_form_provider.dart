import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

part 'login_form_provider.freezed.dart';

enum AuthLoginMode { password, code }

@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String code,
    @Default('') String wechatCallbackInput,
    @Default(AuthLoginMode.password) AuthLoginMode mode,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    @Default(false) bool isStartingWechatLogin,
    @Default(false) bool isCompletingWechatLogin,
    String? wechatAuthorizeUrl,
    String? wechatState,
    String? errorMessage,
  }) = _LoginFormState;
}

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, errorMessage: null);
  }

  void updateWechatCallbackInput(String value) {
    state = state.copyWith(wechatCallbackInput: value, errorMessage: null);
  }

  void updateMode(AuthLoginMode mode) {
    state = state.copyWith(mode: mode, errorMessage: null);
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
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

  Future<CooldownMessageDto?> sendCode() async {
    state = state.copyWith(isSendingCode: true, errorMessage: null);
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(
            email: state.email,
            scene: AuthVerificationScene.login,
          );
      state = state.copyWith(isSendingCode: false);
      return result;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isSendingCode: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  Future<OAuthAuthorizeDataDto?> createWechatWebAuthorizeUrl() async {
    state = state.copyWith(isStartingWechatLogin: true, errorMessage: null);
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .createWechatWebAuthorizeUrl();
      state = state.copyWith(
        isStartingWechatLogin: false,
        wechatAuthorizeUrl: result.authorizeUrl,
        wechatState: result.state,
      );
      return result;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isStartingWechatLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  Future<AuthSession?> completeWechatWebLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(
      isCompletingWechatLogin: true,
      errorMessage: null,
    );
    try {
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .loginWithWechatWeb(code: code, state: state);
      await ref.read(authSessionProvider.notifier).applySession(session);
      this.state = this.state.copyWith(isCompletingWechatLogin: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      this.state = this.state.copyWith(
        isCompletingWechatLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }
}

final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginFormState>(
  LoginFormNotifier.new,
);
