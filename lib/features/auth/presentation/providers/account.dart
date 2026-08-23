import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/auth_verification_scene.dart';
import 'package:luminous/features/auth/domain/entities/verification_code.dart';
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
    @Default(false) bool requiresSecurityElevation,
  }) = _AuthAccountState;
}

class AuthAccountNotifier extends Notifier<AuthAccountState>
    with CooldownTimerMixin<AuthAccountState> {
  @override
  AuthAccountState build() {
    ref.onDispose(disposeCooldown);
    return const AuthAccountState();
  }

  /// Resolves a repository [TaskEither] by rethrowing the [LucentFailure]
  /// on Left so the surrounding try/catch / [_run] projects it into
  /// action state.
  Future<T> _resolve<T>(TaskEither<LucentFailure, T> task) async {
    final either = await task.run();
    return either.fold((failure) => throw failure, (value) => value);
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
      requiresSecurityElevation: false,
    );
    final result = await ref
        .read(authRepositoryProvider)
        .sendVerificationCode(email: email, scene: scene)
        .run();
    return switch (result) {
      Left(:final value) => _failSendCode(value),
      Right(:final value) => _succeedSendCode(value),
    };
  }

  bool _failSendCode(LucentFailure failure) {
    final requiresSecurityElevation = _isSecurityElevationFailure(failure);
    if (requiresSecurityElevation) {
      ref.read(securityElevationControllerProvider.notifier).clear();
    }
    ref
        .read(talkerProvider)
        .error('AuthAccountNotifier.sendVerificationCode: failed: $failure');
    state = state.copyWith(
      isSendingCode: false,
      errorMessage: failure.message,
      successMessage: null,
      requiresSecurityElevation: requiresSecurityElevation,
    );
    return false;
  }

  bool _succeedSendCode(VerificationCooldown result) {
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
  }

  Future<bool> verifyEmail({required String token}) async {
    return _run(() async {
      await _resolve(
        ref.read(authRepositoryProvider).verifyEmail(token: token),
      );
      final user = await _resolve(
        ref.read(authRepositoryProvider).fetchAccount(),
      );
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> updateProfile({String? nickname, String? avatar}) async {
    return _run(() async {
      final user = await _resolve(
        ref
            .read(authRepositoryProvider)
            .updateAccountProfile(nickname: nickname, avatar: avatar),
      );
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
        requiresSecurityElevation: false,
      );
      return false;
    }

    return _run(() async {
      final user = await _resolve(
        ref
            .read(authRepositoryProvider)
            .changeEmail(
              newEmail: newEmail,
              code: code,
              currentUser: currentUser,
            ),
      );
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _run(() async {
      await _resolve(
        ref
            .read(authRepositoryProvider)
            .changePassword(oldPassword: oldPassword, newPassword: newPassword),
      );
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> deleteAccount({String? password, String? code}) async {
    return _run(() async {
      await _resolve(
        ref
            .read(authRepositoryProvider)
            .deleteAccount(password: password, code: code),
      );
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> unlinkIdentity({required String identityId}) async {
    return _run(() async {
      final user = await _resolve(
        ref.read(authRepositoryProvider).unlinkIdentity(identityId: identityId),
      );
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
      requiresSecurityElevation: false,
    );

    final wechat = ref.read(wechatOAuthServiceProvider);
    final remote = ref.read(authRepositoryProvider);

    // 1. Try mobile SDK
    try {
      final code = await wechat.tryMobileAuth();
      if (code != null) {
        final user = await _resolve(
          remote.linkWechatMobileIdentity(code: code),
        );
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
          final user = await _resolve(
            remote.linkWechatWebIdentity(
              code: result.code,
              state: result.state,
            ),
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
      final user = await _resolve(
        ref
            .read(authRepositoryProvider)
            .linkWechatWebIdentity(code: code, state: state),
      );
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
      requiresSecurityElevation: false,
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
    final requiresSecurityElevation = _isSecurityElevationFailure(apiError);
    if (requiresSecurityElevation) {
      ref.read(securityElevationControllerProvider.notifier).clear();
    }
    state = state.copyWith(
      isSubmitting: false,
      isSendingCode: false,
      errorMessage: apiError.message,
      successMessage: null,
      requiresSecurityElevation: requiresSecurityElevation,
    );
    return false;
  }

  bool _isSecurityElevationFailure(LucentFailure error) {
    if (error.statusCode != 403) {
      return false;
    }

    final message = error.message.trim().toLowerCase();
    // Match the precise target error detail phrases. Avoid broad substring
    // matches like 'elevation token', which could also match another 403.
    return message.contains('elevation_token_invalid') ||
        message.contains('安全验证令牌') ||
        message.contains('安全提升令牌');
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
