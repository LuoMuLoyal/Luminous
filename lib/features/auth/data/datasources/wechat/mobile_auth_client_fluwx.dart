import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_client_base.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_config.dart';

class DefaultWechatMobileAuthClient extends WechatMobileAuthClient {
  DefaultWechatMobileAuthClient({Fluwx? fluwx}) : _providedFluwx = fluwx;

  final Fluwx? _providedFluwx;
  Fluwx? _fluwx;

  @override
  bool get isSupported {
    return !kIsWeb &&
        WechatMobileAuthConfig.hasAppId &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  @override
  Future<String> authorize() async {
    if (!isSupported) {
      throw const LucentFailure(
        kind: LucentFailureKind.business,
        code: 'WECHAT_SDK_NOT_CONFIGURED',
        message: 'WeChat mobile SDK login is not configured.',
      );
    }

    final fluwx = _providedFluwx ?? (_fluwx ??= Fluwx());
    final registered = await fluwx.registerApi(
      appId: WechatMobileAuthConfig.appId,
      universalLink: WechatMobileAuthConfig.iosUniversalLink.trim().isEmpty
          ? null
          : WechatMobileAuthConfig.iosUniversalLink.trim(),
    );
    if (!registered) {
      throw const LucentFailure(
        kind: LucentFailureKind.business,
        code: 'WECHAT_SDK_REGISTRATION_FAILED',
        message: 'WeChat mobile SDK registration failed.',
      );
    }

    final installed = await fluwx.isWeChatInstalled;
    if (!installed) {
      throw const LucentFailure(
        kind: LucentFailureKind.business,
        code: 'WECHAT_NOT_INSTALLED',
        message: 'WeChat is not installed.',
      );
    }

    final state = _newState();
    final completer = Completer<String>();
    late final WeChatResponseSubscriber subscriber;
    subscriber = (response) {
      if (response is! WeChatAuthResponse || response.state != state) {
        return;
      }

      final code = response.code?.trim();
      if (response.isSuccessful && code != null && code.isNotEmpty) {
        completer.complete(code);
        return;
      }

      final errStr = response.errStr?.trim();
      completer.completeError(
        LucentFailure(
          kind: LucentFailureKind.business,
          code: 'WECHAT_AUTH_CANCELLED',
          message: errStr != null && errStr.isNotEmpty
              ? errStr
              : 'WeChat authorization was cancelled or failed.',
        ),
      );
    };

    final cancelable = fluwx.addSubscriber(subscriber);
    try {
      final started = await fluwx.authBy(
        which: NormalAuth(scope: 'snsapi_userinfo', state: state),
      );
      if (!started) {
        throw const LucentFailure(
          kind: LucentFailureKind.business,
          code: 'WECHAT_AUTH_START_FAILED',
          message: 'Could not start WeChat authorization.',
        );
      }

      return await completer.future.timeout(const Duration(minutes: 10));
    } on TimeoutException {
      throw LucentFailure.network(
        message: 'WeChat authorization timed out.',
        networkErrorCode: NetworkErrorCode.connectionTimeout,
      );
    } finally {
      cancelable.cancel();
    }
  }

  String _newState() {
    final random = Random.secure();
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      32,
      (_) => alphabet[random.nextInt(alphabet.length)],
      growable: false,
    ).join();
  }
}
