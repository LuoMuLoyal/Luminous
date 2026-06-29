import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_server.dart';

class WechatDesktopOAuthCallbackListener {
  const WechatDesktopOAuthCallbackListener();

  bool get isSupported => false;

  Future<WechatDesktopOAuthCallbackServer> start() {
    throw UnsupportedError(
      'WeChat desktop OAuth callback listener is not supported.',
    );
  }
}
