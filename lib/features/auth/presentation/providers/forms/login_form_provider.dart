import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_server.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/providers/shared/auth_form_mixin.dart';

part 'login_form_provider.freezed.dart';

enum AuthLoginMode { password, code }

@freezed
abstract class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String code,
    @Default('') String wechatCallbackInput,
    @Default('') String qqCallbackInput,
    @Default(AuthLoginMode.password) AuthLoginMode mode,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    @Default(false) bool isStartingWechatLogin,
    @Default(false) bool isCompletingWechatLogin,
    @Default(false) bool isStartingQqLogin,
    @Default(false) bool isCompletingQqLogin,
    @Default(false) bool isStartingAppleLogin,
    int? cooldownSeconds,
    String? emailError,
    String? passwordError,
    String? codeError,
    String? wechatAuthorizeUrl,
    String? wechatState,
    String? qqAuthorizeUrl,
    String? qqState,
    String? errorMessage,
  }) = _LoginFormState;
}

class LoginFormNotifier extends Notifier<LoginFormState>
    with AuthValidationMixin, CooldownTimerMixin<LoginFormState> {
  @override
  LoginFormState build() {
    ref.onDispose(disposeCooldown);
    return const LoginFormState();
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

  void updateCode(String value) {
    state = state.copyWith(code: value, codeError: null, errorMessage: null);
  }

  void updateWechatCallbackInput(String value) {
    state = state.copyWith(wechatCallbackInput: value, errorMessage: null);
  }

  void updateMode(AuthLoginMode mode) {
    state = state.copyWith(mode: mode, errorMessage: null);
  }

  void setEmailError(String message) {
    state = state.copyWith(emailError: message);
  }

  bool validate({
    required String emailRequired,
    required String emailInvalid,
    required String passwordRequired,
    required String codeRequired,
  }) {
    final emailError = validateEmail(
      state.email,
      emailRequired: emailRequired,
      emailInvalid: emailInvalid,
    );

    final String? passwordError;
    final String? codeError;
    if (state.mode == AuthLoginMode.password) {
      passwordError = validatePassword(
        state.password,
        passwordRequired: passwordRequired,
      );
      codeError = null;
    } else {
      passwordError = null;
      codeError = validateCode(state.code, codeRequired: codeRequired);
    }

    state = state.copyWith(
      emailError: emailError,
      passwordError: passwordError,
      codeError: codeError,
      errorMessage: null,
    );

    return emailError == null && passwordError == null && codeError == null;
  }

  bool validateEmailOnly({required String emailRequired}) {
    final email = state.email.trim();
    final emailError = email.isEmpty ? emailRequired : null;
    state = state.copyWith(emailError: emailError, errorMessage: null);
    return emailError == null;
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

  Future<bool> sendCode() async {
    state = state.copyWith(isSendingCode: true, errorMessage: null);
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(
            email: state.email,
            scene: AuthVerificationScene.login,
          );
      final cooldown = result.cooldown.toInt();
      state = state.copyWith(isSendingCode: false, cooldownSeconds: cooldown);
      startCooldown(
        cooldown,
        getCooldownSeconds: () => state.cooldownSeconds,
        setCooldownSeconds: (v) => state = state.copyWith(cooldownSeconds: v),
      );
      return true;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isSendingCode: false,
        errorMessage: apiError.message,
      );
      return false;
    }
  }

  Future<OAuthAuthorizeDataDto?> createWechatWebAuthorizeUrl({
    String? callbackUri,
  }) async {
    state = state.copyWith(isStartingWechatLogin: true, errorMessage: null);
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .createWechatWebAuthorizeUrl(callbackUri: callbackUri);
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

  Future<AuthSession?> startWechatDesktopWebLogin() async {
    final listener = ref.read(wechatDesktopOAuthCallbackListenerProvider);
    if (!listener.isSupported) {
      return null;
    }

    state = state.copyWith(isStartingWechatLogin: true, errorMessage: null);
    WechatDesktopOAuthCallbackServer? server;
    try {
      server = await listener.start();
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .createWechatWebAuthorizeUrl(
            callbackUri: server.callbackUri.toString(),
          );
      state = state.copyWith(
        wechatAuthorizeUrl: result.authorizeUrl,
        wechatState: result.state,
      );

      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(result.authorizeUrl));
      if (!opened) {
        state = state.copyWith(isStartingWechatLogin: false);
        return null;
      }

      final callback = await server.callback.timeout(
        Duration(seconds: result.expiresIn.toInt()),
      );
      if (callback.state != result.state) {
        state = state.copyWith(isStartingWechatLogin: false);
        return null;
      }
      state = state.copyWith(
        isStartingWechatLogin: false,
        isCompletingWechatLogin: true,
      );
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .loginWithWechatWeb(code: callback.code, state: callback.state);
      await ref.read(authSessionProvider.notifier).applySession(session);
      state = state.copyWith(isCompletingWechatLogin: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isStartingWechatLogin: false,
        isCompletingWechatLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    } finally {
      await server?.close();
    }
  }

  Future<AuthSession?> startWechatMobileLogin() async {
    final client = ref.read(wechatMobileAuthClientProvider);
    if (!client.isSupported) {
      return null;
    }

    state = state.copyWith(isStartingWechatLogin: true, errorMessage: null);
    try {
      final code = await client.authorize();
      state = state.copyWith(
        isStartingWechatLogin: false,
        isCompletingWechatLogin: true,
      );
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .loginWithWechatMobile(code: code);
      await ref.read(authSessionProvider.notifier).applySession(session);
      state = state.copyWith(isCompletingWechatLogin: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isStartingWechatLogin: false,
        isCompletingWechatLogin: false,
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

  void updateQqCallbackInput(String value) {
    state = state.copyWith(qqCallbackInput: value, errorMessage: null);
  }

  Future<OAuthAuthorizeDataDto?> createQqAuthorizeUrl({
    String? callbackUri,
  }) async {
    state = state.copyWith(isStartingQqLogin: true, errorMessage: null);
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .createQqAuthorizeUrl(callbackUri: callbackUri);
      state = state.copyWith(
        isStartingQqLogin: false,
        qqAuthorizeUrl: result.authorizeUrl,
        qqState: result.state,
      );
      return result;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isStartingQqLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  Future<AuthSession?> completeQqLogin({
    required String code,
    required String state,
  }) async {
    this.state = this.state.copyWith(
      isCompletingQqLogin: true,
      errorMessage: null,
    );
    try {
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .loginWithQq(code: code, state: state);
      await ref.read(authSessionProvider.notifier).applySession(session);
      this.state = this.state.copyWith(isCompletingQqLogin: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      this.state = this.state.copyWith(
        isCompletingQqLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }

  Future<AuthSession?> loginWithApple({
    required String identityToken,
    String? authorizationCode,
    String? givenName,
    String? familyName,
  }) async {
    state = state.copyWith(isStartingAppleLogin: true, errorMessage: null);
    try {
      final session = await ref
          .read(authRemoteDataSourceProvider)
          .loginWithApple(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            givenName: givenName,
            familyName: familyName,
          );
      await ref.read(authSessionProvider.notifier).applySession(session);
      state = state.copyWith(isStartingAppleLogin: false);
      return session;
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      state = state.copyWith(
        isStartingAppleLogin: false,
        errorMessage: apiError.message,
      );
      return null;
    }
  }
}

final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginFormState>(
  LoginFormNotifier.new,
);
