import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_client_base.dart';
import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_config.dart';

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
      throw const LucentApiException(
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
      throw const LucentApiException(
        message: 'WeChat mobile SDK registration failed.',
      );
    }

    final installed = await fluwx.isWeChatInstalled;
    if (!installed) {
      throw const LucentApiException(message: 'WeChat is not installed.');
    }

    final state = _newState();
    final completer = Completer<String>();
    late final WeChatResponseSubscriber subscriber;
    subscriber = (response) {
      if (response is! WeChatAuthResponse || response.state != state) {
        return;
      }

      if (response.isSuccessful && response.code?.trim().isNotEmpty == true) {
        completer.complete(response.code!.trim());
        return;
      }

      completer.completeError(
        LucentApiException(
          message: response.errStr?.trim().isNotEmpty == true
              ? response.errStr!.trim()
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
        throw const LucentApiException(
          message: 'Could not start WeChat authorization.',
        );
      }

      return await completer.future.timeout(const Duration(minutes: 10));
    } on TimeoutException {
      throw const LucentApiException(
        message: 'WeChat authorization timed out.',
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
