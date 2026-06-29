import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_listener.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_server.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';

part 'auth_account_provider.freezed.dart';

enum WechatIdentityLinkResult { completed, opened, unsupported }

@freezed
abstract class AuthAccountState with _$AuthAccountState {
  const factory AuthAccountState({
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    String? errorMessage,
    String? successMessage,
    int? lastCooldownSeconds,
  }) = _AuthAccountState;
}

class AuthAccountNotifier extends Notifier<AuthAccountState> {
  @override
  AuthAccountState build() => const AuthAccountState();

  Future<bool> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    state = state.copyWith(
      isSendingCode: true,
      errorMessage: null,
      successMessage: null,
      lastCooldownSeconds: null,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(email: email, scene: scene);
      state = state.copyWith(
        isSendingCode: false,
        successMessage: result.message,
        lastCooldownSeconds: result.cooldown.toInt(),
      );
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .verifyEmail(email: email, code: code);
      final currentUser = ref.read(authSessionProvider).user;
      if (currentUser != null && currentUser.email == email.trim()) {
        final user = await ref
            .read(authRemoteDataSourceProvider)
            .fetchAccount();
        ref.read(authSessionProvider.notifier).applyUser(user);
      }
    });
  }

  Future<bool> updateProfile({String? nickname, String? avatar}) async {
    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .updateAccountProfile(nickname: nickname, avatar: avatar);
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> changeEmail({
    required String newEmail,
    required String code,
  }) async {
    final currentUser = ref.read(authSessionProvider).user;
    if (currentUser == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Not signed in.',
        successMessage: null,
      );
      return false;
    }

    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .changeEmail(
            newEmail: newEmail,
            code: code,
            currentUser: currentUser,
          );
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .changePassword(oldPassword: oldPassword, newPassword: newPassword);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> deleteAccount({required String password}) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .deleteAccount(password: password);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> unlinkIdentity({required String identityId}) async {
    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .unlinkIdentity(identityId: identityId);
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<WechatIdentityLinkResult?> startWechatIdentityLink({
    String? webCallbackUri,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    final mobileClient = ref.read(wechatMobileAuthClientProvider);
    if (mobileClient.isSupported) {
      try {
        final code = await mobileClient.authorize();
        final user = await ref
            .read(authRemoteDataSourceProvider)
            .linkWechatMobileIdentity(code: code);
        ref.read(authSessionProvider.notifier).applyUser(user);
        state = state.copyWith(isSubmitting: false, successMessage: '');
        return WechatIdentityLinkResult.completed;
      } catch (error) {
        return _failWithResult(error);
      }
    }

    final desktopListener = ref.read(
      wechatDesktopOAuthCallbackListenerProvider,
    );
    if (desktopListener.isSupported) {
      return _startWechatDesktopIdentityLink(desktopListener);
    }

    if (webCallbackUri == null || webCallbackUri.trim().isEmpty) {
      state = state.copyWith(isSubmitting: false);
      return WechatIdentityLinkResult.unsupported;
    }

    try {
      final authorize = await ref
          .read(authRemoteDataSourceProvider)
          .createWechatWebIdentityLinkAuthorizeUrl(callbackUri: webCallbackUri);
      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      state = state.copyWith(isSubmitting: false);
      return opened
          ? WechatIdentityLinkResult.opened
          : WechatIdentityLinkResult.unsupported;
    } catch (error) {
      return _failWithResult(error);
    }
  }

  Future<bool> completeWechatWebIdentityLink({
    required String code,
    required String state,
  }) async {
    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .linkWechatWebIdentity(code: code, state: state);
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      await action();
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

  Future<WechatIdentityLinkResult?> _startWechatDesktopIdentityLink(
    WechatDesktopOAuthCallbackListener desktopListener,
  ) async {
    WechatDesktopOAuthCallbackServer? server;
    try {
      server = await desktopListener.start();
      final authorize = await ref
          .read(authRemoteDataSourceProvider)
          .createWechatWebIdentityLinkAuthorizeUrl(
            callbackUri: server.callbackUri.toString(),
          );
      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      if (!opened) {
        state = state.copyWith(isSubmitting: false);
        return WechatIdentityLinkResult.unsupported;
      }

      final callback = await server.callback.timeout(
        Duration(seconds: authorize.expiresIn.toInt()),
      );
      if (callback.state != authorize.state) {
        state = state.copyWith(isSubmitting: false);
        return WechatIdentityLinkResult.unsupported;
      }

      final user = await ref
          .read(authRemoteDataSourceProvider)
          .linkWechatWebIdentity(code: callback.code, state: callback.state);
      ref.read(authSessionProvider.notifier).applyUser(user);
      state = state.copyWith(isSubmitting: false, successMessage: '');
      return WechatIdentityLinkResult.completed;
    } catch (error) {
      return _failWithResult(error);
    } finally {
      await server?.close();
    }
  }

  WechatIdentityLinkResult? _failWithResult(Object error) {
    _fail(error);
    return null;
  }
}

final authAccountProvider =
    NotifierProvider<AuthAccountNotifier, AuthAccountState>(
      AuthAccountNotifier.new,
    );
