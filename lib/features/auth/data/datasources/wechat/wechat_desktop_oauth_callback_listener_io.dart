import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_server.dart';

class WechatDesktopOAuthCallbackListener {
  const WechatDesktopOAuthCallbackListener();

  bool get isSupported {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux);
  }

  Future<WechatDesktopOAuthCallbackServer> start() async {
    if (!isSupported) {
      throw UnsupportedError(
        'WeChat desktop OAuth callback listener is not supported.',
      );
    }

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final completer = Completer<WechatOAuthCallback>();
    late final StreamSubscription<HttpRequest> subscription;
    subscription = server.listen((request) async {
      final code = request.uri.queryParameters['code']?.trim();
      final state = request.uri.queryParameters['state']?.trim();
      final isCallbackPath = request.uri.path == '/oauth/wechat';
      if (isCallbackPath &&
          code?.isNotEmpty == true &&
          state?.isNotEmpty == true) {
        if (!completer.isCompleted) {
          completer.complete(WechatOAuthCallback(code: code!, state: state!));
        }
        await _closeResponse(request.response, statusCode: HttpStatus.ok);
        return;
      }

      await _closeResponse(request.response, statusCode: HttpStatus.badRequest);
    });

    return WechatDesktopOAuthCallbackServer(
      callbackUri: Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.address,
        port: server.port,
        path: '/oauth/wechat',
      ),
      callback: completer.future,
      close: () async {
        await subscription.cancel();
        await server.close(force: true);
      },
    );
  }

  Future<void> _closeResponse(
    HttpResponse response, {
    required int statusCode,
  }) async {
    response.statusCode = statusCode;
    await response.close();
  }
}
