import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/providers/shared/form_mixin.dart';
import 'package:luminous/features/auth/presentation/services/wechat_oauth.dart';

part 'account.freezed.dart';

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

class AuthAccountNotifier extends Notifier<AuthAccountState>
    with CooldownTimerMixin<AuthAccountState> {
  @override
  AuthAccountState build() {
    ref.onDispose(disposeCooldown);
    return const AuthAccountState();
  }

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
          .read(authRepositoryProvider)
          .sendVerificationCode(email: email, scene: scene);
      state = state.copyWith(
        isSendingCode: false,
        successMessage: result.message,
      );
      startCooldown(
        result.cooldownSeconds,
        getCooldownSeconds: () => state.lastCooldownSeconds,
        setCooldownSeconds: (value) =>
            state = state.copyWith(lastCooldownSeconds: value),
      );
      return true;
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('AuthAccountNotifier.sendVerificationCode: failed: $error');
      return _fail(error);
    }
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .verifyEmail(email: email, code: code);
      final currentUser = ref.read(authSessionProvider).user;
      if (currentUser != null && currentUser.email == email.trim()) {
        final user = await ref.read(authRepositoryProvider).fetchAccount();
        ref.read(authSessionProvider.notifier).applyUser(user);
      }
    });
  }

  Future<bool> updateProfile({String? nickname, String? avatar}) async {
    return _run(() async {
      final user = await ref
          .read(authRepositoryProvider)
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
          .read(authRepositoryProvider)
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
          .read(authRepositoryProvider)
          .changePassword(oldPassword: oldPassword, newPassword: newPassword);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> deleteAccount({String? password, String? code}) async {
    return _run(() async {
      await ref
          .read(authRepositoryProvider)
          .deleteAccount(password: password, code: code);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> unlinkIdentity({required String identityId}) async {
    return _run(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .unlinkIdentity(identityId: identityId);
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  /// Starts the WeChat identity linking flow.
  ///
  /// Delegates platform detection (mobile → desktop → web) to
  /// [WechatOAuthService], then calls the appropriate linking API.
  Future<WechatIdentityLinkResult?> startWechatIdentityLink({
    String? webCallbackUri,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    final wechat = ref.read(wechatOAuthServiceProvider);
    final remote = ref.read(authRepositoryProvider);

    // 1. Try mobile SDK
    try {
      final code = await wechat.tryMobileAuth();
      if (code != null) {
        final user = await remote.linkWechatMobileIdentity(code: code);
        ref.read(authSessionProvider.notifier).applyUser(user);
        state = state.copyWith(isSubmitting: false, successMessage: '');
        return WechatIdentityLinkResult.completed;
      }
    } catch (error) {
      ref
          .read(talkerProvider)
          .error(
            'AuthAccountNotifier.startWechatIdentityLink.mobile: failed: $error',
          );
      return _failWithResult(error);
    }

    // 2. Try desktop loopback (only if supported)
    final desktopListener = ref.read(
      wechatDesktopOAuthCallbackListenerProvider,
    );
    if (desktopListener.isSupported) {
      try {
        final result = await wechat.tryDesktopAuth(forIdentityLink: true);
        if (result != null) {
          final user = await remote.linkWechatWebIdentity(
            code: result.code,
            state: result.state,
          );
          ref.read(authSessionProvider.notifier).applyUser(user);
          state = state.copyWith(isSubmitting: false, successMessage: '');
          return WechatIdentityLinkResult.completed;
        }
        // Desktop supported but failed (browser or state mismatch)
        state = state.copyWith(isSubmitting: false);
        return WechatIdentityLinkResult.unsupported;
      } catch (error) {
        ref
            .read(talkerProvider)
            .error(
              'AuthAccountNotifier.startWechatIdentityLink.desktop: failed: $error',
            );
        return _failWithResult(error);
      }
    }

    // 3. Web fallback
    if (webCallbackUri == null || webCallbackUri.trim().isEmpty) {
      state = state.copyWith(isSubmitting: false);
      return WechatIdentityLinkResult.unsupported;
    }

    try {
      final authorize = await wechat.createWebAuthorizeUrl(
        callbackUri: webCallbackUri,
        forIdentityLink: true,
      );
      final opened = await ref
          .read(externalUrlLauncherProvider)
          .open(Uri.parse(authorize.authorizeUrl));
      state = state.copyWith(isSubmitting: false);
      return opened
          ? WechatIdentityLinkResult.opened
          : WechatIdentityLinkResult.unsupported;
    } catch (error) {
      ref
          .read(talkerProvider)
          .error(
            'AuthAccountNotifier.startWechatIdentityLink.web: failed: $error',
          );
      return _failWithResult(error);
    }
  }

  Future<bool> completeWechatWebIdentityLink({
    required String code,
    required String state,
  }) async {
    return _run(() async {
      final user = await ref
          .read(authRepositoryProvider)
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
      ref
          .read(talkerProvider)
          .error('AuthAccountNotifier._run: failed: $error');
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

  WechatIdentityLinkResult? _failWithResult(Object error) {
    _fail(error);
    return null;
  }
}

final authAccountProvider =
    NotifierProvider<AuthAccountNotifier, AuthAccountState>(
      AuthAccountNotifier.new,
    );
