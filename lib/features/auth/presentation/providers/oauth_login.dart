import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/domain/repositories/auth.dart';
import 'package:luminous/features/auth/presentation/services/wechat_oauth.dart';

part 'oauth_apple.dart';
part 'oauth_google.dart';
part 'oauth_qq.dart';
part 'oauth_wechat.dart';
part 'oauth_weibo.dart';

/// State for OAuth login flows (WeChat, QQ, Weibo, Google, Apple).
///
/// Managed by [OAuthLoginController]. This is intentionally a plain Dart class
/// (not freezed) to avoid build_runner dependencies and keep the OAuth state
/// decoupled from the email/password form state.
class OAuthLoginState {
  const OAuthLoginState({
    this.isStartingWechat = false,
    this.isCompletingWechat = false,
    this.wechatAuthorizeUrl,
    this.wechatState,
    this.isStartingQq = false,
    this.isCompletingQq = false,
    this.qqAuthorizeUrl,
    this.qqState,
    this.isStartingWeibo = false,
    this.isCompletingWeibo = false,
    this.weiboAuthorizeUrl,
    this.weiboState,
    this.isStartingGoogle = false,
    this.isCompletingGoogle = false,
    this.googleAuthorizeUrl,
    this.googleState,
    this.isStartingApple = false,
    this.errorMessage,
  });

  final bool isStartingWechat;
  final bool isCompletingWechat;
  final String? wechatAuthorizeUrl;
  final String? wechatState;

  final bool isStartingQq;
  final bool isCompletingQq;
  final String? qqAuthorizeUrl;
  final String? qqState;

  final bool isStartingWeibo;
  final bool isCompletingWeibo;
  final String? weiboAuthorizeUrl;
  final String? weiboState;

  final bool isStartingGoogle;
  final bool isCompletingGoogle;
  final String? googleAuthorizeUrl;
  final String? googleState;

  final bool isStartingApple;
  final String? errorMessage;

  /// Sentinel-based copyWith so nullable fields can be explicitly set to null.
  static const _sentinel = Object();

  OAuthLoginState copyWith({
    bool? isStartingWechat,
    bool? isCompletingWechat,
    Object? wechatAuthorizeUrl = _sentinel,
    Object? wechatState = _sentinel,
    bool? isStartingQq,
    bool? isCompletingQq,
    Object? qqAuthorizeUrl = _sentinel,
    Object? qqState = _sentinel,
    bool? isStartingWeibo,
    bool? isCompletingWeibo,
    Object? weiboAuthorizeUrl = _sentinel,
    Object? weiboState = _sentinel,
    bool? isStartingGoogle,
    bool? isCompletingGoogle,
    Object? googleAuthorizeUrl = _sentinel,
    Object? googleState = _sentinel,
    bool? isStartingApple,
    Object? errorMessage = _sentinel,
  }) {
    return OAuthLoginState(
      isStartingWechat: isStartingWechat ?? this.isStartingWechat,
      isCompletingWechat: isCompletingWechat ?? this.isCompletingWechat,
      wechatAuthorizeUrl: wechatAuthorizeUrl == _sentinel
          ? this.wechatAuthorizeUrl
          : wechatAuthorizeUrl as String?,
      wechatState: wechatState == _sentinel
          ? this.wechatState
          : wechatState as String?,
      isStartingQq: isStartingQq ?? this.isStartingQq,
      isCompletingQq: isCompletingQq ?? this.isCompletingQq,
      qqAuthorizeUrl: qqAuthorizeUrl == _sentinel
          ? this.qqAuthorizeUrl
          : qqAuthorizeUrl as String?,
      qqState: qqState == _sentinel ? this.qqState : qqState as String?,
      isStartingWeibo: isStartingWeibo ?? this.isStartingWeibo,
      isCompletingWeibo: isCompletingWeibo ?? this.isCompletingWeibo,
      weiboAuthorizeUrl: weiboAuthorizeUrl == _sentinel
          ? this.weiboAuthorizeUrl
          : weiboAuthorizeUrl as String?,
      weiboState: weiboState == _sentinel
          ? this.weiboState
          : weiboState as String?,
      isStartingGoogle: isStartingGoogle ?? this.isStartingGoogle,
      isCompletingGoogle: isCompletingGoogle ?? this.isCompletingGoogle,
      googleAuthorizeUrl: googleAuthorizeUrl == _sentinel
          ? this.googleAuthorizeUrl
          : googleAuthorizeUrl as String?,
      googleState: googleState == _sentinel
          ? this.googleState
          : googleState as String?,
      isStartingApple: isStartingApple ?? this.isStartingApple,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Base class that holds shared helpers for [OAuthLoginController] and its
/// provider-specific mixins. Split into part files by OAuth provider so each
/// file stays under 450 lines.
abstract class OAuthLoginControllerBase extends Notifier<OAuthLoginState> {
  WechatOAuthService get _wechat => ref.read(wechatOAuthServiceProvider);
  AuthRepository get _remote => ref.read(authRepositoryProvider);

  /// Resolves a repository [TaskEither] by rethrowing the [LucentFailure]
  /// on Left so the surrounding try/catch projects it into action state.
  Future<T> _resolve<T>(TaskEither<LucentFailure, T> task) async {
    final either = await task.run();
    return either.fold((failure) => throw failure, (value) => value);
  }

  /// Maps an error to a user-facing message and logs it.
  String _mapError(Object error, String tag) {
    ref.read(talkerProvider).error('$tag: failed: $error');
    return LucentErrorMapper.fromObject(error).message;
  }
}

/// Manages all OAuth login flows (WeChat, QQ, Weibo, Google, Apple).
///
/// Provider-specific methods are defined as mixins in part files
/// (`oauth_wechat.dart`, `oauth_qq.dart`, `oauth_weibo.dart`,
/// `oauth_google.dart`, `oauth_apple.dart`).
class OAuthLoginController extends OAuthLoginControllerBase
    with
        OAuthWechatMixin,
        OAuthQqMixin,
        OAuthWeiboMixin,
        OAuthGoogleMixin,
        OAuthAppleMixin {
  @override
  OAuthLoginState build() => const OAuthLoginState();

  /// Clears the error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final oauthLoginProvider =
    NotifierProvider<OAuthLoginController, OAuthLoginState>(
      OAuthLoginController.new,
    );
