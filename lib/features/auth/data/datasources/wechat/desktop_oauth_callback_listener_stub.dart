import 'package:luminous/core/errors/client_error_code.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/data/datasources/wechat/desktop_oauth_callback_server.dart';

class WechatDesktopOAuthCallbackListener {
  const WechatDesktopOAuthCallbackListener();

  bool get isSupported => false;

  Future<WechatDesktopOAuthCallbackServer> start() {
    // isSupported 为 false 时调用方不会 start；真走到这里必须抛可本地化的失败。
    throw LucentFailure.client(
      clientErrorCode: ClientErrorCode.wechatDesktopUnsupported,
      message: 'WeChat desktop OAuth callback listener is not supported.',
    );
  }
}
